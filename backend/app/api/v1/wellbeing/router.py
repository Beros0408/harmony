import datetime
import json
from typing import Optional

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/wellbeing", tags=["Bien-être numérique"])

_SPIKE_THRESHOLD = 1.5   # +50 % au-dessus de la moyenne → anomalie
_MIN_HISTORY_DAYS = 3    # minimum de jours avec données pour déclencher l'analyse


# ─── Schémas ─────────────────────────────────────────────────────────────────

class SignalRecord(BaseModel):
    id: str
    child_id: str
    signal_type: str
    severity: str
    source: str
    details: Optional[dict] = None
    signal_date: datetime.date
    created_at: datetime.datetime


class AlertRecord(BaseModel):
    id: str
    child_id: str
    signal_id: str
    title: str
    message: str
    severity: str
    status: str
    created_at: datetime.datetime
    read_at: Optional[datetime.datetime] = None


class AnalyzeResponse(BaseModel):
    analyzed: bool
    anomaly_detected: bool
    signal: Optional[SignalRecord] = None
    reason: str


# ─── Helpers internes ────────────────────────────────────────────────────────

def _format_duration(seconds: int) -> str:
    """Formate des secondes en 'XhYY' ou 'Y min' pour les messages d'alerte."""
    h = seconds // 3600
    m = (seconds % 3600) // 60
    if h > 0:
        return f"{h}h{m:02d}"
    return f"{m} min"


async def _upsert_signal(
    db: AsyncSession,
    child_id: str,
    signal_date: datetime.date,
    details: dict,
) -> SignalRecord:
    """Insère ou met à jour le signal usage_spike (idempotent sur child_id, signal_type, signal_date)."""
    result = await db.execute(
        text(
            """
            INSERT INTO public.wellbeing_signals
                (child_id, signal_type, severity, source, details, signal_date)
            VALUES (CAST(:child_id AS uuid), 'usage_spike', 'vigilance', 'screen_time',
                    CAST(:details AS jsonb), :signal_date)
            ON CONFLICT (child_id, signal_type, signal_date) DO UPDATE
                SET details  = EXCLUDED.details,
                    severity = EXCLUDED.severity,
                    source   = EXCLUDED.source
            RETURNING id::text, child_id::text, signal_type, severity, source,
                      details, signal_date, created_at
            """
        ),
        {
            "child_id": child_id,
            "details": json.dumps(details),
            "signal_date": signal_date,
        },
    )
    row = result.fetchone()
    return SignalRecord(
        id=row[0],
        child_id=row[1],
        signal_type=row[2],
        severity=row[3],
        source=row[4],
        details=row[5],
        signal_date=row[6],
        created_at=row[7],
    )


async def _ensure_alert(
    db: AsyncSession,
    child_id: str,
    signal: SignalRecord,
    usage_seconds: int,
    moyenne_seconds: float,
    nb_jours: int,
) -> None:
    """Crée l'alerte liée au signal, sauf si elle existe déjà (idempotence via signal_id)."""
    existing = await db.execute(
        text(
            "SELECT id FROM public.wellbeing_alerts"
            " WHERE signal_id = CAST(:signal_id AS uuid) LIMIT 1"
        ),
        {"signal_id": signal.id},
    )
    if existing.fetchone() is not None:
        return

    pct = round((usage_seconds / moyenne_seconds - 1.0) * 100)
    duration_str = _format_duration(usage_seconds)
    title = "Temps d'écran en hausse"
    message = (
        f"L'usage d'aujourd'hui ({duration_str}) dépasse de {pct} % "
        f"la moyenne des {nb_jours} derniers jours enregistrés. "
        "Pas d'inquiétude — c'est simplement un moment pour en discuter ensemble."
    )

    await db.execute(
        text(
            """
            INSERT INTO public.wellbeing_alerts
                (child_id, signal_id, title, message, severity, status)
            VALUES (CAST(:child_id AS uuid), CAST(:signal_id AS uuid),
                    :title, :message, 'vigilance', 'sent')
            """
        ),
        {
            "child_id": child_id,
            "signal_id": signal.id,
            "title": title,
            "message": message,
        },
    )


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/analyze/{child_id}",
    response_model=AnalyzeResponse,
    status_code=status.HTTP_200_OK,
    summary="Analyse l'usage du jour et génère un signal/alerte si anomalie détectée",
)
async def analyze(
    child_id: str,
    date: Optional[datetime.date] = Query(default=None),
    db: AsyncSession = Depends(get_db),
) -> AnalyzeResponse:
    """
    Compare l'usage global du jour J à la moyenne des 7 jours précédents.
    Déclenche un signal 'usage_spike' si usage_J > moyenne * 1.5 et qu'il y a
    au moins 3 jours d'historique. Idempotent : re-exécuter le même jour met à
    jour les détails du signal sans créer de doublon.
    """
    try:
        target_date = date or datetime.date.today()
        hist_from = target_date - datetime.timedelta(days=7)
        hist_to   = target_date - datetime.timedelta(days=1)

        # Usage global du jour J (tous packages confondus)
        today_res = await db.execute(
            text(
                """
                SELECT COALESCE(SUM(duration_seconds), 0)
                FROM public.screen_time_usage
                WHERE child_id = CAST(:child_id AS uuid)
                  AND usage_date = :target_date
                """
            ),
            {"child_id": child_id, "target_date": target_date},
        )
        usage_today = int(today_res.scalar())

        # Totaux journaliers sur J-7..J-1 — seuls les jours avec données sont comptés
        hist_res = await db.execute(
            text(
                """
                SELECT usage_date, SUM(duration_seconds) AS total
                FROM public.screen_time_usage
                WHERE child_id = CAST(:child_id AS uuid)
                  AND usage_date BETWEEN :hist_from AND :hist_to
                GROUP BY usage_date
                HAVING SUM(duration_seconds) > 0
                ORDER BY usage_date
                """
            ),
            {"child_id": child_id, "hist_from": hist_from, "hist_to": hist_to},
        )
        hist_rows = hist_res.fetchall()
        nb_jours = len(hist_rows)

        if nb_jours < _MIN_HISTORY_DAYS:
            return AnalyzeResponse(
                analyzed=True,
                anomaly_detected=False,
                signal=None,
                reason="historique_insuffisant",
            )

        moyenne = sum(int(row[1]) for row in hist_rows) / nb_jours
        ratio = round(usage_today / moyenne, 2) if moyenne > 0 else 0.0

        if usage_today <= moyenne * _SPIKE_THRESHOLD:
            return AnalyzeResponse(
                analyzed=True,
                anomaly_detected=False,
                signal=None,
                reason="aucune_anomalie",
            )

        details = {
            "usage_jour_seconds": usage_today,
            "moyenne_seconds": round(moyenne, 2),
            "ratio": ratio,
            "nb_jours_historique": nb_jours,
        }
        signal = await _upsert_signal(db, child_id, target_date, details)
        await _ensure_alert(db, child_id, signal, usage_today, moyenne, nb_jours)

        logger.info(
            "wellbeing_spike_detected",
            child_id=child_id,
            date=str(target_date),
            ratio=ratio,
            nb_jours=nb_jours,
        )
        return AnalyzeResponse(
            analyzed=True,
            anomaly_detected=True,
            signal=signal,
            reason="usage_spike",
        )
    except Exception as exc:
        logger.error("wellbeing_analyze_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'analyse du bien-être numérique.",
        ) from exc


@router.get(
    "/alerts/{child_id}",
    response_model=list[AlertRecord],
    summary="Liste les alertes d'un enfant, les plus récentes en premier",
)
async def get_alerts(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[AlertRecord]:
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, child_id::text, signal_id::text,
                       title, message, severity, status, created_at, read_at
                FROM public.wellbeing_alerts
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY created_at DESC
                """
            ),
            {"child_id": child_id},
        )
        rows = result.fetchall()
        return [
            AlertRecord(
                id=row[0],
                child_id=row[1],
                signal_id=row[2],
                title=row[3],
                message=row[4],
                severity=row[5],
                status=row[6],
                created_at=row[7],
                read_at=row[8],
            )
            for row in rows
        ]
    except Exception as exc:
        logger.error("wellbeing_alerts_get_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la lecture des alertes.",
        ) from exc


@router.post(
    "/alerts/{alert_id}/read",
    status_code=status.HTTP_200_OK,
    summary="Passe le statut d'une alerte à 'read' et renseigne read_at",
)
async def mark_alert_read(
    alert_id: str,
    db: AsyncSession = Depends(get_db),
) -> dict[str, bool]:
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        result = await db.execute(
            text(
                """
                UPDATE public.wellbeing_alerts
                SET status = 'read', read_at = :read_at
                WHERE id = CAST(:alert_id AS uuid)
                  AND status != 'read'
                RETURNING id
                """
            ),
            {"alert_id": alert_id, "read_at": now},
        )
        if result.fetchone() is None:
            check = await db.execute(
                text(
                    "SELECT id FROM public.wellbeing_alerts"
                    " WHERE id = CAST(:alert_id AS uuid)"
                ),
                {"alert_id": alert_id},
            )
            if check.fetchone() is None:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Alerte introuvable.",
                )
        logger.info("wellbeing_alert_read", alert_id=alert_id)
        return {"updated": True}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("wellbeing_alert_read_error", error=str(exc), alert_id=alert_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la mise à jour de l'alerte.",
        ) from exc
