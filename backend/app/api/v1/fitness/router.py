import datetime
from typing import Optional
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, field_validator
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/fitness", tags=["Fitness"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class ActivityUpsertRequest(BaseModel):
    activity_date: Optional[datetime.date] = None
    steps: int = 0
    active_minutes: int = 0
    distance_meters: int = 0
    source: str = "device"

    @field_validator("steps", "active_minutes", "distance_meters")
    @classmethod
    def validate_non_negative(cls, v: int) -> int:
        if v < 0:
            raise ValueError("doit être >= 0")
        return v

    @field_validator("source")
    @classmethod
    def validate_source(cls, v: str) -> str:
        if v not in ("device", "manual", "test"):
            raise ValueError("source doit être 'device', 'manual' ou 'test'")
        return v


class ActivityResponse(BaseModel):
    id: str
    child_id: str
    activity_date: datetime.date
    steps: int
    active_minutes: int
    distance_meters: int
    source: str
    created_at: datetime.datetime
    updated_at: datetime.datetime


class DailySummary(BaseModel):
    activity_date: datetime.date
    steps: int
    active_minutes: int
    distance_meters: int


class SummaryResponse(BaseModel):
    child_id: str
    days: list[DailySummary]
    total_steps: int
    average_steps_per_day: float


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.put(
    "/activity/{child_id}",
    response_model=ActivityResponse,
    summary="Upsert activité fitness d'un enfant pour une date donnée",
)
async def upsert_activity(
    child_id: UUID,
    payload: ActivityUpsertRequest,
    db: AsyncSession = Depends(get_db),
) -> ActivityResponse:
    try:
        today = datetime.date.today()
        activity_date = payload.activity_date or today
        now = datetime.datetime.now(datetime.timezone.utc)

        result = await db.execute(
            text("""
                INSERT INTO public.fitness_activity
                    (child_id, activity_date, steps, active_minutes, distance_meters, source,
                     created_at, updated_at)
                VALUES
                    (:child_id, :activity_date, :steps, :active_minutes, :distance_meters,
                     :source, :now, :now)
                ON CONFLICT (child_id, activity_date) DO UPDATE
                    SET steps            = EXCLUDED.steps,
                        active_minutes   = EXCLUDED.active_minutes,
                        distance_meters  = EXCLUDED.distance_meters,
                        source           = EXCLUDED.source,
                        updated_at       = EXCLUDED.updated_at
                RETURNING
                    id::text, child_id::text, activity_date,
                    steps, active_minutes, distance_meters, source,
                    created_at, updated_at
            """),
            {
                "child_id": str(child_id),
                "activity_date": activity_date,
                "steps": payload.steps,
                "active_minutes": payload.active_minutes,
                "distance_meters": payload.distance_meters,
                "source": payload.source,
                "now": now,
            },
        )
        row = result.fetchone()
        logger.info(
            "fitness_activity_upserted",
            child_id=str(child_id),
            activity_date=str(activity_date),
        )
        return ActivityResponse(
            id=row.id,
            child_id=row.child_id,
            activity_date=row.activity_date,
            steps=row.steps,
            active_minutes=row.active_minutes,
            distance_meters=row.distance_meters,
            source=row.source,
            created_at=row.created_at,
            updated_at=row.updated_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("fitness_upsert_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'enregistrement de l'activité fitness.",
        ) from exc


@router.get(
    "/activity/{child_id}",
    response_model=ActivityResponse,
    summary="Activité fitness d'un enfant pour un jour donné (zéros si absent)",
)
async def get_activity(
    child_id: UUID,
    date: Optional[datetime.date] = Query(default=None, description="Date YYYY-MM-DD (défaut aujourd'hui)"),
    db: AsyncSession = Depends(get_db),
) -> ActivityResponse:
    try:
        target_date = date or datetime.date.today()
        now = datetime.datetime.now(datetime.timezone.utc)

        result = await db.execute(
            text("""
                SELECT
                    id::text, child_id::text, activity_date,
                    steps, active_minutes, distance_meters, source,
                    created_at, updated_at
                FROM public.fitness_activity
                WHERE child_id = :child_id
                  AND activity_date = :activity_date
            """),
            {"child_id": str(child_id), "activity_date": target_date},
        )
        row = result.fetchone()

        if row is None:
            logger.info(
                "fitness_activity_absent",
                child_id=str(child_id),
                activity_date=str(target_date),
            )
            return ActivityResponse(
                id="00000000-0000-0000-0000-000000000000",
                child_id=str(child_id),
                activity_date=target_date,
                steps=0,
                active_minutes=0,
                distance_meters=0,
                source="device",
                created_at=now,
                updated_at=now,
            )

        return ActivityResponse(
            id=row.id,
            child_id=row.child_id,
            activity_date=row.activity_date,
            steps=row.steps,
            active_minutes=row.active_minutes,
            distance_meters=row.distance_meters,
            source=row.source,
            created_at=row.created_at,
            updated_at=row.updated_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("fitness_get_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération de l'activité fitness.",
        ) from exc


@router.get(
    "/summary/{child_id}",
    response_model=SummaryResponse,
    summary="Résumé fitness sur N jours (défaut 7) avec total et moyenne de pas",
)
async def get_summary(
    child_id: UUID,
    days: int = Query(default=7, ge=1, le=365, description="Nombre de jours à inclure"),
    db: AsyncSession = Depends(get_db),
) -> SummaryResponse:
    try:
        today = datetime.date.today()
        since = today - datetime.timedelta(days=days - 1)

        result = await db.execute(
            text("""
                SELECT
                    activity_date,
                    steps,
                    active_minutes,
                    distance_meters
                FROM public.fitness_activity
                WHERE child_id = :child_id
                  AND activity_date >= :since
                  AND activity_date <= :today
                ORDER BY activity_date DESC
            """),
            {"child_id": str(child_id), "since": since, "today": today},
        )
        rows = result.fetchall()

        daily = [
            DailySummary(
                activity_date=row.activity_date,
                steps=row.steps,
                active_minutes=row.active_minutes,
                distance_meters=row.distance_meters,
            )
            for row in rows
        ]

        total_steps = sum(d.steps for d in daily)
        average_steps = round(total_steps / len(daily), 2) if daily else 0.0

        logger.info(
            "fitness_summary_fetched",
            child_id=str(child_id),
            days=days,
            total_steps=total_steps,
        )
        return SummaryResponse(
            child_id=str(child_id),
            days=daily,
            total_steps=total_steps,
            average_steps_per_day=average_steps,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("fitness_summary_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors du calcul du résumé fitness.",
        ) from exc
