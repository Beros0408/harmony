import datetime
from typing import Optional
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, field_validator, model_validator
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/screen-time", tags=["Temps d'écran"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class UsageEntry(BaseModel):
    package_name: str
    app_label: Optional[str] = None
    category: Optional[str] = None
    duration_seconds: int
    usage_date: datetime.date


class UsageBatchRequest(BaseModel):
    child_id: UUID
    entries: list[UsageEntry]


class UsageBatchResponse(BaseModel):
    processed: int


class UsageRecord(BaseModel):
    child_id: str
    package_name: str
    app_label: Optional[str]
    category: Optional[str]
    duration_seconds: int
    usage_date: datetime.date
    updated_at: datetime.datetime


class AppSummary(BaseModel):
    package_name: str
    app_label: Optional[str]
    category: Optional[str]
    duration_seconds: int


class SummaryResponse(BaseModel):
    child_id: str
    usage_date: datetime.date
    total_seconds: int
    top_apps: list[AppSummary]
    total_by_category: dict[str, int]


# ─── Schémas — limites ────────────────────────────────────────────────────────

class LimitRequest(BaseModel):
    child_id: UUID
    scope: str
    package_name: Optional[str] = None
    limit_seconds: int

    @field_validator("scope")
    @classmethod
    def validate_scope(cls, v: str) -> str:
        if v not in ("global", "app"):
            raise ValueError("scope doit être 'global' ou 'app'")
        return v

    @field_validator("limit_seconds")
    @classmethod
    def validate_limit_non_negative(cls, v: int) -> int:
        if v < 0:
            raise ValueError("limit_seconds doit être >= 0")
        return v

    @model_validator(mode="after")
    def validate_package_name_required_for_app(self) -> "LimitRequest":
        if self.scope == "app" and not self.package_name:
            raise ValueError("package_name est requis quand scope='app'")
        return self


class LimitRecord(BaseModel):
    id: str
    child_id: str
    scope: str
    package_name: Optional[str]
    limit_seconds: int
    created_at: datetime.datetime
    updated_at: datetime.datetime


# ─── Schémas — bonus ─────────────────────────────────────────────────────────

class BonusRequest(BaseModel):
    child_id: UUID
    bonus_date: datetime.date
    bonus_seconds: int

    @field_validator("bonus_seconds")
    @classmethod
    def validate_bonus_non_negative(cls, v: int) -> int:
        if v < 0:
            raise ValueError("bonus_seconds doit être >= 0")
        return v


class BonusResponse(BaseModel):
    child_id: str
    bonus_date: datetime.date
    bonus_seconds: int


# ─── Schémas — statut ─────────────────────────────────────────────────────────

class LimitStatusItem(BaseModel):
    id: str
    scope: str
    package_name: Optional[str]
    limit_seconds: int
    bonus_seconds: int
    used_seconds: int
    remaining_seconds: int
    exceeded: bool


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/usage",
    response_model=UsageBatchResponse,
    status_code=status.HTTP_200_OK,
    summary="Remonte l'usage applicatif d'un enfant (batch upsert journalier)",
)
async def post_usage(
    payload: UsageBatchRequest,
    db: AsyncSession = Depends(get_db),
) -> UsageBatchResponse:
    """
    Upsert en lot : remplace duration_seconds si (child_id, package_name, usage_date) existe déjà.
    L'enfant envoie le cumul du jour, pas un delta.
    """
    if not payload.entries:
        return UsageBatchResponse(processed=0)

    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        count = 0
        for entry in payload.entries:
            await db.execute(
                text(
                    """
                    INSERT INTO public.screen_time_usage
                        (child_id, package_name, app_label, category,
                         duration_seconds, usage_date, updated_at)
                    VALUES (CAST(:child_id AS uuid), :package_name, :app_label, :category,
                            :duration_seconds, :usage_date, :updated_at)
                    ON CONFLICT (child_id, package_name, usage_date) DO UPDATE
                        SET duration_seconds = EXCLUDED.duration_seconds,
                            app_label        = EXCLUDED.app_label,
                            category         = EXCLUDED.category,
                            updated_at       = EXCLUDED.updated_at
                    """
                ),
                {
                    "child_id": str(payload.child_id),
                    "package_name": entry.package_name,
                    "app_label": entry.app_label,
                    "category": entry.category,
                    "duration_seconds": entry.duration_seconds,
                    "usage_date": entry.usage_date,
                    "updated_at": now,
                },
            )
            count += 1
        logger.info("screen_time_upserted", child_id=str(payload.child_id), count=count)
        return UsageBatchResponse(processed=count)
    except Exception as exc:
        logger.error("screen_time_post_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la remontée du temps d'écran.",
        ) from exc


@router.get(
    "/usage/{child_id}",
    response_model=list[UsageRecord],
    summary="Lit l'usage applicatif d'un enfant, filtrable par date ou plage",
)
async def get_usage(
    child_id: str,
    date: Optional[datetime.date] = Query(default=None),
    from_: Optional[datetime.date] = Query(default=None, alias="from"),
    to: Optional[datetime.date] = Query(default=None),
    db: AsyncSession = Depends(get_db),
) -> list[UsageRecord]:
    """
    Sans paramètre → jour courant (UTC).
    ?date=YYYY-MM-DD → un jour précis.
    ?from=YYYY-MM-DD&to=YYYY-MM-DD → plage inclusive.
    """
    try:
        today = datetime.date.today()

        if date is not None:
            date_from = date
            date_to = date
        elif from_ is not None or to is not None:
            date_from = from_ or today
            date_to = to or today
        else:
            date_from = today
            date_to = today

        result = await db.execute(
            text(
                """
                SELECT
                    child_id::text,
                    package_name,
                    app_label,
                    category,
                    duration_seconds,
                    usage_date,
                    updated_at
                FROM public.screen_time_usage
                WHERE child_id = CAST(:child_id AS uuid)
                  AND usage_date BETWEEN :date_from AND :date_to
                ORDER BY duration_seconds DESC
                """
            ),
            {"child_id": child_id, "date_from": date_from, "date_to": date_to},
        )
        rows = result.fetchall()
        return [
            UsageRecord(
                child_id=row[0],
                package_name=row[1],
                app_label=row[2],
                category=row[3],
                duration_seconds=row[4],
                usage_date=row[5],
                updated_at=row[6],
            )
            for row in rows
        ]
    except Exception as exc:
        logger.error("screen_time_get_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la lecture du temps d'écran.",
        ) from exc


@router.get(
    "/usage/{child_id}/summary",
    response_model=SummaryResponse,
    summary="Résumé agrégé du temps d'écran d'un enfant pour un jour donné",
)
async def get_usage_summary(
    child_id: str,
    date: Optional[datetime.date] = Query(default=None),
    db: AsyncSession = Depends(get_db),
) -> SummaryResponse:
    """
    Retourne total journalier, top apps (décroissant), total par catégorie.
    Paramètre ?date=YYYY-MM-DD, défaut = aujourd'hui.
    """
    try:
        target_date = date or datetime.date.today()

        result = await db.execute(
            text(
                """
                SELECT
                    package_name,
                    app_label,
                    category,
                    duration_seconds
                FROM public.screen_time_usage
                WHERE child_id = CAST(:child_id AS uuid)
                  AND usage_date = :usage_date
                ORDER BY duration_seconds DESC
                """
            ),
            {"child_id": child_id, "usage_date": target_date},
        )
        rows = result.fetchall()

        total_seconds = sum(row[3] for row in rows)

        top_apps = [
            AppSummary(
                package_name=row[0],
                app_label=row[1],
                category=row[2],
                duration_seconds=row[3],
            )
            for row in rows
        ]

        total_by_category: dict[str, int] = {}
        for row in rows:
            cat = row[2] or "other"
            total_by_category[cat] = total_by_category.get(cat, 0) + row[3]

        return SummaryResponse(
            child_id=child_id,
            usage_date=target_date,
            total_seconds=total_seconds,
            top_apps=top_apps,
            total_by_category=total_by_category,
        )
    except Exception as exc:
        logger.error("screen_time_summary_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors du résumé du temps d'écran.",
        ) from exc


# ─── Endpoints — limites ──────────────────────────────────────────────────────

@router.put(
    "/limits",
    response_model=LimitRecord,
    status_code=status.HTTP_200_OK,
    summary="Définit ou met à jour une limite de temps d'écran (upsert)",
)
async def put_limit(
    payload: LimitRequest,
    db: AsyncSession = Depends(get_db),
) -> LimitRecord:
    """
    Upsert selon le scope :
      - 'global' : une seule limite par enfant (clé = child_id).
      - 'app'    : une limite par (child_id, package_name).
    Le package_name est ignoré/forcé à NULL pour le scope 'global'.
    """
    try:
        now = datetime.datetime.now(datetime.timezone.utc)

        if payload.scope == "global":
            result = await db.execute(
                text(
                    """
                    INSERT INTO public.screen_time_limits
                        (child_id, scope, package_name, limit_seconds, updated_at)
                    VALUES (CAST(:child_id AS uuid), 'global', NULL, :limit_seconds, :updated_at)
                    ON CONFLICT (child_id) WHERE scope = 'global' DO UPDATE
                        SET limit_seconds = EXCLUDED.limit_seconds,
                            updated_at    = EXCLUDED.updated_at
                    RETURNING id::text, child_id::text, scope, package_name,
                              limit_seconds, created_at, updated_at
                    """
                ),
                {
                    "child_id": str(payload.child_id),
                    "limit_seconds": payload.limit_seconds,
                    "updated_at": now,
                },
            )
        else:  # scope == 'app'
            result = await db.execute(
                text(
                    """
                    INSERT INTO public.screen_time_limits
                        (child_id, scope, package_name, limit_seconds, updated_at)
                    VALUES (CAST(:child_id AS uuid), 'app', :package_name, :limit_seconds, :updated_at)
                    ON CONFLICT (child_id, package_name) WHERE scope = 'app' DO UPDATE
                        SET limit_seconds = EXCLUDED.limit_seconds,
                            updated_at    = EXCLUDED.updated_at
                    RETURNING id::text, child_id::text, scope, package_name,
                              limit_seconds, created_at, updated_at
                    """
                ),
                {
                    "child_id": str(payload.child_id),
                    "package_name": payload.package_name,
                    "limit_seconds": payload.limit_seconds,
                    "updated_at": now,
                },
            )

        row = result.fetchone()
        logger.info(
            "screen_time_limit_upserted",
            child_id=str(payload.child_id),
            scope=payload.scope,
        )
        return LimitRecord(
            id=row[0],
            child_id=row[1],
            scope=row[2],
            package_name=row[3],
            limit_seconds=row[4],
            created_at=row[5],
            updated_at=row[6],
        )
    except Exception as exc:
        logger.error("screen_time_limit_put_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la mise à jour de la limite.",
        ) from exc


@router.get(
    "/limits/{child_id}",
    response_model=list[LimitRecord],
    summary="Retourne toutes les limites d'un enfant (globale + par app)",
)
async def get_limits(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[LimitRecord]:
    """
    Retourne la limite globale (scope='global') et toutes les limites par app
    (scope='app') définies pour cet enfant. Utilisé par l'app enfant et le parent.
    """
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, child_id::text, scope, package_name,
                       limit_seconds, created_at, updated_at
                FROM public.screen_time_limits
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY scope DESC, package_name
                """
            ),
            {"child_id": child_id},
        )
        rows = result.fetchall()
        return [
            LimitRecord(
                id=row[0],
                child_id=row[1],
                scope=row[2],
                package_name=row[3],
                limit_seconds=row[4],
                created_at=row[5],
                updated_at=row[6],
            )
            for row in rows
        ]
    except Exception as exc:
        logger.error("screen_time_limits_get_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la lecture des limites.",
        ) from exc


@router.delete(
    "/limits/{limit_id}",
    status_code=status.HTTP_200_OK,
    summary="Supprime une limite de temps d'écran",
)
async def delete_limit(
    limit_id: str,
    db: AsyncSession = Depends(get_db),
) -> dict[str, bool]:
    try:
        result = await db.execute(
            text(
                """
                DELETE FROM public.screen_time_limits
                WHERE id = CAST(:limit_id AS uuid)
                RETURNING id
                """
            ),
            {"limit_id": limit_id},
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Limite introuvable.",
            )
        logger.info("screen_time_limit_deleted", limit_id=limit_id)
        return {"deleted": True}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("screen_time_limit_delete_error", error=str(exc), limit_id=limit_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la suppression de la limite.",
        ) from exc


# ─── Endpoints — bonus ────────────────────────────────────────────────────────

@router.put(
    "/bonus",
    response_model=BonusResponse,
    status_code=status.HTTP_200_OK,
    summary="Octroie ou ajuste le temps bonus du jour pour un enfant (upsert)",
)
async def put_bonus(
    payload: BonusRequest,
    db: AsyncSession = Depends(get_db),
) -> BonusResponse:
    """
    Upsert sur (child_id, bonus_date) : un seul bonus par enfant par jour.
    Le parent peut ajuster le bonus du jour ou le remettre à 0 (bonus_seconds=0).
    Le bonus s'applique uniquement à la limite de scope 'global'.
    """
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        result = await db.execute(
            text(
                """
                INSERT INTO public.screen_time_bonus
                    (child_id, bonus_date, bonus_seconds, updated_at)
                VALUES (CAST(:child_id AS uuid), :bonus_date, :bonus_seconds, :updated_at)
                ON CONFLICT (child_id, bonus_date) DO UPDATE
                    SET bonus_seconds = EXCLUDED.bonus_seconds,
                        updated_at    = EXCLUDED.updated_at
                RETURNING child_id::text, bonus_date, bonus_seconds
                """
            ),
            {
                "child_id": str(payload.child_id),
                "bonus_date": payload.bonus_date,
                "bonus_seconds": payload.bonus_seconds,
                "updated_at": now,
            },
        )
        row = result.fetchone()
        logger.info(
            "screen_time_bonus_upserted",
            child_id=str(payload.child_id),
            bonus_seconds=payload.bonus_seconds,
        )
        return BonusResponse(
            child_id=row[0],
            bonus_date=row[1],
            bonus_seconds=row[2],
        )
    except Exception as exc:
        logger.error("screen_time_bonus_put_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'enregistrement du bonus.",
        ) from exc


@router.get(
    "/bonus/{child_id}",
    response_model=BonusResponse,
    summary="Retourne le bonus de temps d'écran du jour pour un enfant (0 si aucun)",
)
async def get_bonus(
    child_id: str,
    date: Optional[datetime.date] = Query(default=None),
    db: AsyncSession = Depends(get_db),
) -> BonusResponse:
    """
    Retourne le bonus défini pour la date donnée (défaut = aujourd'hui).
    Retourne bonus_seconds=0 si aucun bonus n'a été accordé pour ce jour.
    """
    try:
        target_date = date or datetime.date.today()
        result = await db.execute(
            text(
                """
                SELECT child_id::text, bonus_date, bonus_seconds
                FROM public.screen_time_bonus
                WHERE child_id = CAST(:child_id AS uuid)
                  AND bonus_date = :bonus_date
                """
            ),
            {"child_id": child_id, "bonus_date": target_date},
        )
        row = result.fetchone()
        if row is None:
            return BonusResponse(
                child_id=child_id,
                bonus_date=target_date,
                bonus_seconds=0,
            )
        return BonusResponse(
            child_id=row[0],
            bonus_date=row[1],
            bonus_seconds=row[2],
        )
    except Exception as exc:
        logger.error("screen_time_bonus_get_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la lecture du bonus.",
        ) from exc


# ─── Endpoint — statut croisé usage × limites (+ bonus global) ───────────────

@router.get(
    "/status/{child_id}",
    response_model=list[LimitStatusItem],
    summary="Croise l'usage du jour avec les limites : remaining_seconds et exceeded",
)
async def get_status(
    child_id: str,
    date: Optional[datetime.date] = Query(default=None),
    db: AsyncSession = Depends(get_db),
) -> list[LimitStatusItem]:
    """
    Retourne, pour chaque limite définie sur cet enfant, le cumul d'usage correspondant
    sur la journée [date] (défaut = aujourd'hui), le temps restant et le dépassement.
    Pour la limite globale, le bonus du jour est intégré dans le calcul :
      remaining = limit_seconds + bonus_seconds - used_seconds
    Les limites par app ne sont pas affectées par le bonus.
    """
    try:
        target_date = date or datetime.date.today()

        # Bonus du jour — s'applique uniquement au scope 'global'
        bonus_res = await db.execute(
            text(
                """
                SELECT COALESCE(bonus_seconds, 0)
                FROM public.screen_time_bonus
                WHERE child_id = CAST(:child_id AS uuid)
                  AND bonus_date = :usage_date
                """
            ),
            {"child_id": child_id, "usage_date": target_date},
        )
        bonus_row = bonus_res.fetchone()
        global_bonus: int = int(bonus_row[0]) if bonus_row else 0

        result = await db.execute(
            text(
                """
                WITH daily_total AS (
                    SELECT COALESCE(SUM(duration_seconds), 0) AS total
                    FROM public.screen_time_usage
                    WHERE child_id = CAST(:child_id AS uuid)
                      AND usage_date = :usage_date
                ),
                app_usage AS (
                    SELECT package_name, SUM(duration_seconds) AS duration
                    FROM public.screen_time_usage
                    WHERE child_id = CAST(:child_id AS uuid)
                      AND usage_date = :usage_date
                    GROUP BY package_name
                )
                SELECT
                    l.id::text,
                    l.scope,
                    l.package_name,
                    l.limit_seconds,
                    CASE
                        WHEN l.scope = 'global'
                            THEN (SELECT total FROM daily_total)
                        ELSE COALESCE(au.duration, 0)
                    END AS used_seconds
                FROM public.screen_time_limits l
                LEFT JOIN app_usage au
                    ON l.scope = 'app' AND au.package_name = l.package_name
                WHERE l.child_id = CAST(:child_id AS uuid)
                ORDER BY l.scope DESC, l.package_name
                """
            ),
            {"child_id": child_id, "usage_date": target_date},
        )
        rows = result.fetchall()

        items = []
        for row in rows:
            limit_s   = row[3]
            used_s    = int(row[4])
            scope     = row[1]
            # Le bonus ne s'applique qu'au quota global
            bonus     = global_bonus if scope == "global" else 0
            effective = limit_s + bonus
            remaining = max(0, effective - used_s)
            items.append(
                LimitStatusItem(
                    id=row[0],
                    scope=scope,
                    package_name=row[2],
                    limit_seconds=limit_s,
                    bonus_seconds=bonus,
                    used_seconds=used_s,
                    remaining_seconds=remaining,
                    exceeded=used_s >= effective,
                )
            )
        return items
    except Exception as exc:
        logger.error("screen_time_status_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors du calcul du statut.",
        ) from exc
