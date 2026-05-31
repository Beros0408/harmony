from datetime import datetime, timezone
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, field_validator
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/schedules", tags=["Planification horaire"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class CreateScheduleRequest(BaseModel):
    child_id: UUID
    label: str
    start_time: str   # format "HH:MM"
    end_time: str     # format "HH:MM"
    days_of_week: list[int]   # 1=lundi ... 7=dimanche

    @field_validator("start_time", "end_time", mode="before")
    @classmethod
    def validate_time_format(cls, v: object) -> str:
        if not isinstance(v, str):
            raise ValueError("L'heure doit être une chaîne.")
        parts = v.strip().split(":")
        if len(parts) != 2 or not all(p.isdigit() for p in parts):
            raise ValueError("Format d'heure invalide. Utiliser HH:MM.")
        return v.strip()

    @field_validator("days_of_week", mode="before")
    @classmethod
    def validate_days(cls, v: object) -> list:
        if not isinstance(v, list) or not v:
            raise ValueError("Au moins un jour doit être sélectionné.")
        if not all(isinstance(d, int) and 1 <= d <= 7 for d in v):
            raise ValueError("Les jours doivent être des entiers entre 1 (lun) et 7 (dim).")
        return v


class ScheduleItem(BaseModel):
    id: str
    child_id: str
    label: str
    start_time: str   # "HH:MM"
    end_time: str     # "HH:MM"
    days_of_week: list[int]
    active: bool


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Crée une plage horaire de verrouillage automatique",
)
async def create_schedule(
    payload: CreateScheduleRequest,
    db: AsyncSession = Depends(get_db),
) -> dict:
    try:
        schedule_id = uuid4()
        now = datetime.now(timezone.utc)
        # Sérialise la liste Python en littéral tableau PostgreSQL : '{1,2,5}'
        days_str = "{" + ",".join(str(d) for d in payload.days_of_week) + "}"

        await db.execute(
            text(
                """
                INSERT INTO public.lock_schedules
                    (id, child_id, label, start_time, end_time, days_of_week, active, created_at)
                VALUES (
                    CAST(:id AS uuid),
                    CAST(:child_id AS uuid),
                    :label,
                    CAST(:start_time AS time),
                    CAST(:end_time AS time),
                    CAST(:days_of_week AS int[]),
                    true,
                    :created_at
                )
                """
            ),
            {
                "id": str(schedule_id),
                "child_id": str(payload.child_id),
                "label": payload.label.strip(),
                "start_time": payload.start_time,
                "end_time": payload.end_time,
                "days_of_week": days_str,
                "created_at": now,
            },
        )

        logger.info(
            "schedule_created",
            schedule_id=str(schedule_id),
            child_id=str(payload.child_id),
            label=payload.label,
        )
        return {"schedule_id": str(schedule_id)}

    except Exception as exc:
        logger.error("create_schedule_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la création de la plage horaire.",
        ) from exc


@router.get(
    "",
    response_model=list[ScheduleItem],
    summary="Liste les plages horaires d'un enfant",
)
async def get_schedules(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[ScheduleItem]:
    try:
        result = await db.execute(
            text(
                """
                SELECT
                    id::text,
                    child_id::text,
                    label,
                    to_char(start_time, 'HH24:MI') AS start_time,
                    to_char(end_time, 'HH24:MI')   AS end_time,
                    days_of_week,
                    active
                FROM public.lock_schedules
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY start_time ASC
                """
            ),
            {"child_id": child_id},
        )
        rows = result.fetchall()
        return [
            ScheduleItem(
                id=row[0],
                child_id=row[1],
                label=row[2],
                start_time=row[3],
                end_time=row[4],
                days_of_week=list(row[5]) if row[5] else [],
                active=row[6],
            )
            for row in rows
        ]

    except Exception as exc:
        logger.error("get_schedules_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des plages.",
        ) from exc


@router.delete(
    "/{schedule_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Supprime une plage horaire",
)
async def delete_schedule(
    schedule_id: str,
    db: AsyncSession = Depends(get_db),
) -> None:
    try:
        result = await db.execute(
            text(
                """
                DELETE FROM public.lock_schedules
                WHERE id = CAST(:schedule_id AS uuid)
                RETURNING id
                """
            ),
            {"schedule_id": schedule_id},
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plage horaire introuvable.",
            )
        logger.info("schedule_deleted", schedule_id=schedule_id)

    except HTTPException:
        raise
    except Exception as exc:
        logger.error("delete_schedule_error", error=str(exc), schedule_id=schedule_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la suppression.",
        ) from exc
