import datetime
from typing import Any
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/privacy", tags=["RGPD – Vie privée"])


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _serialize(v: Any) -> Any:
    """Rend un scalaire JSON-sérialisable (date/time → ISO, UUID → str)."""
    if hasattr(v, "isoformat"):
        return v.isoformat()
    if isinstance(v, UUID):
        return str(v)
    return v


def _row_to_dict(row) -> dict:
    return {k: _serialize(v) for k, v in row._mapping.items()}


# ─── Schémas réponse ─────────────────────────────────────────────────────────

class DeleteResponse(BaseModel):
    deleted: bool
    child_id: str
    tables_touched: dict[str, int]
    export_reminder: str


class PurgeResponse(BaseModel):
    purged: bool
    retention_days: int
    cutoff_date: str
    rows_deleted: dict[str, int]


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.get(
    "/export/{child_id}",
    summary="Exporte toutes les données d'un enfant (RGPD – droit d'accès)",
)
async def export_child_data(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> dict:
    """
    Rassemble toutes les données liées à child_id dans un seul objet JSON structuré
    par table. Chaque SELECT filtre strictement sur child_id.
    """
    try:
        now = datetime.datetime.now(datetime.timezone.utc)

        async def _one(sql: str) -> dict | None:
            r = await db.execute(text(sql), {"child_id": child_id})
            row = r.fetchone()
            return _row_to_dict(row) if row else None

        async def _many(sql: str) -> list[dict]:
            r = await db.execute(text(sql), {"child_id": child_id})
            return [_row_to_dict(row) for row in r.fetchall()]

        payload = {
            "export_date": now.isoformat(),
            "child_id": child_id,
            "profile": await _one(
                "SELECT * FROM public.profiles"
                " WHERE id = CAST(:child_id AS uuid)"
            ),
            "family_links": await _many(
                "SELECT * FROM public.family_links"
                " WHERE child_id = CAST(:child_id AS uuid)"
            ),
            "screen_time_usage": await _many(
                "SELECT * FROM public.screen_time_usage"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY usage_date DESC"
            ),
            "screen_time_limits": await _many(
                "SELECT * FROM public.screen_time_limits"
                " WHERE child_id = CAST(:child_id AS uuid)"
            ),
            "screen_time_bonus": await _many(
                "SELECT * FROM public.screen_time_bonus"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY bonus_date DESC"
            ),
            "fitness_activity": await _many(
                "SELECT * FROM public.fitness_activity"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY activity_date DESC"
            ),
            "wellbeing_signals": await _many(
                "SELECT * FROM public.wellbeing_signals"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY signal_date DESC"
            ),
            "wellbeing_alerts": await _many(
                "SELECT * FROM public.wellbeing_alerts"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY created_at DESC"
            ),
            "lock_schedules": await _many(
                "SELECT * FROM public.lock_schedules"
                " WHERE child_id = CAST(:child_id AS uuid)"
            ),
            "device_commands": await _many(
                "SELECT * FROM public.device_commands"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY created_at DESC"
            ),
            "content_filter": await _one(
                "SELECT * FROM public.content_filter"
                " WHERE child_id = CAST(:child_id AS uuid)"
            ),
            "unlink_requests": await _many(
                "SELECT * FROM public.unlink_requests"
                " WHERE child_id = CAST(:child_id AS uuid)"
                " ORDER BY created_at DESC"
            ),
        }

        logger.info("privacy_export_generated", child_id=child_id)
        return payload

    except Exception as exc:
        logger.error("privacy_export_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'export des données.",
        ) from exc


@router.delete(
    "/data/{child_id}",
    response_model=DeleteResponse,
    summary="Supprime toutes les données d'un enfant (RGPD – droit à l'effacement)",
)
async def delete_child_data(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> DeleteResponse:
    """
    Supprime toutes les données liées à child_id dans toutes les tables, dans une
    transaction atomique (tout ou rien). Filtre strict sur child_id à chaque DELETE.
    Ne supprime PAS le compte/profil du parent.
    """
    try:
        # table et col sont des littéraux codés en dur — jamais issus d'une entrée externe.
        async def _del(table: str, col: str = "child_id") -> int:
            r = await db.execute(
                text(f"DELETE FROM public.{table} WHERE {col} = CAST(:child_id AS uuid)"),
                {"child_id": child_id},
            )
            return r.rowcount

        touched: dict[str, int] = {}

        # wellbeing_alerts avant wellbeing_signals : signal_id référence wellbeing_signals.id
        touched["wellbeing_alerts"]   = await _del("wellbeing_alerts")
        touched["wellbeing_signals"]  = await _del("wellbeing_signals")
        touched["screen_time_usage"]  = await _del("screen_time_usage")
        touched["screen_time_limits"] = await _del("screen_time_limits")
        touched["screen_time_bonus"]  = await _del("screen_time_bonus")
        touched["fitness_activity"]   = await _del("fitness_activity")
        touched["lock_schedules"]     = await _del("lock_schedules")
        touched["device_commands"]    = await _del("device_commands")
        touched["content_filter"]     = await _del("content_filter")
        touched["unlink_requests"]    = await _del("unlink_requests")
        touched["family_links"]       = await _del("family_links")
        # Filtre sur id (= child_id) — ne touche aucun autre profil
        touched["profiles"]           = await _del("profiles", col="id")

        logger.info("privacy_data_deleted", child_id=child_id, tables=touched)

        return DeleteResponse(
            deleted=True,
            child_id=child_id,
            tables_touched=touched,
            export_reminder=(
                "Proposer l'export RGPD (/privacy/export/{child_id})"
                " avant toute suppression côté UI."
            ),
        )

    except Exception as exc:
        logger.error("privacy_delete_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la suppression des données.",
        ) from exc


@router.post(
    "/purge",
    response_model=PurgeResponse,
    summary="Purge les données historiques dépassant la durée de rétention (RGPD)",
)
async def purge_old_data(
    retention_days: int = Query(default=90, ge=1, description="Durée de rétention en jours"),
    child_id: str | None = Query(default=None, description="Si fourni, purge uniquement cet enfant"),
    db: AsyncSession = Depends(get_db),
) -> PurgeResponse:
    """
    Supprime les lignes historiques dont la date dépasse retention_days jours.
    Tables concernées : screen_time_usage, fitness_activity, wellbeing_signals,
    wellbeing_alerts, device_commands. Transaction atomique via get_db.
    """
    try:
        cutoff = datetime.date.today() - datetime.timedelta(days=retention_days)

        # (table, colonne_date) — littéraux codés en dur, jamais issus d'une entrée externe
        _HISTORY_TABLES: list[tuple[str, str]] = [
            ("screen_time_usage", "usage_date"),
            ("fitness_activity",  "activity_date"),
            ("wellbeing_signals", "signal_date"),
            ("wellbeing_alerts",  "created_at"),
            ("device_commands",   "created_at"),
        ]

        rows_deleted: dict[str, int] = {}

        for table, date_col in _HISTORY_TABLES:
            if child_id is not None:
                sql = (
                    f"DELETE FROM public.{table}"
                    f" WHERE {date_col} < CAST(:cutoff AS date)"
                    f" AND child_id = CAST(:child_id AS uuid)"
                )
                params: dict = {"cutoff": cutoff, "child_id": child_id}
            else:
                sql = (
                    f"DELETE FROM public.{table}"
                    f" WHERE {date_col} < CAST(:cutoff AS date)"
                )
                params = {"cutoff": cutoff}

            r = await db.execute(text(sql), params)
            rows_deleted[table] = r.rowcount

        logger.info(
            "privacy_purge_done",
            retention_days=retention_days,
            cutoff=cutoff.isoformat(),
            child_id=child_id,
            rows_deleted=rows_deleted,
        )

        return PurgeResponse(
            purged=True,
            retention_days=retention_days,
            cutoff_date=cutoff.isoformat(),
            rows_deleted=rows_deleted,
        )

    except Exception as exc:
        logger.error("privacy_purge_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la purge des données.",
        ) from exc
