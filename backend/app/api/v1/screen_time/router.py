import datetime
from typing import Optional
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
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
