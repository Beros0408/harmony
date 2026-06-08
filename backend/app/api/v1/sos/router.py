import datetime
from typing import Optional
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/sos", tags=["SOS"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class SosTriggerRequest(BaseModel):
    child_id: UUID
    latitude: float
    longitude: float
    accuracy: Optional[float] = None


class SosEventResponse(BaseModel):
    id: str
    child_id: str
    latitude: float
    longitude: float
    accuracy: Optional[float]
    triggered_at: datetime.datetime
    status: str
    created_at: datetime.datetime


class SosEventListResponse(BaseModel):
    child_id: str
    events: list[SosEventResponse]


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/trigger",
    response_model=SosEventResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Déclenche une alerte SOS pour un enfant",
)
async def trigger_sos(
    payload: SosTriggerRequest,
    db: AsyncSession = Depends(get_db),
) -> SosEventResponse:
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        result = await db.execute(
            text("""
                INSERT INTO public.sos_events
                    (child_id, latitude, longitude, accuracy, triggered_at, status, created_at)
                VALUES
                    (:child_id, :latitude, :longitude, :accuracy, :now, 'active', :now)
                RETURNING
                    id::text, child_id::text, latitude, longitude, accuracy,
                    triggered_at, status, created_at
            """),
            {
                "child_id": str(payload.child_id),
                "latitude": payload.latitude,
                "longitude": payload.longitude,
                "accuracy": payload.accuracy,
                "now": now,
            },
        )
        row = result.fetchone()
        logger.info("sos_triggered", child_id=str(payload.child_id))
        return SosEventResponse(
            id=row.id,
            child_id=row.child_id,
            latitude=row.latitude,
            longitude=row.longitude,
            accuracy=row.accuracy,
            triggered_at=row.triggered_at,
            status=row.status,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_trigger_error", error=str(exc), child_id=str(payload.child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors du déclenchement de l'alerte SOS.",
        ) from exc


@router.get(
    "/active/{child_id}",
    response_model=SosEventListResponse,
    summary="Alertes SOS actives d'un enfant (récentes d'abord)",
)
async def get_active_sos(
    child_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> SosEventListResponse:
    try:
        result = await db.execute(
            text("""
                SELECT
                    id::text, child_id::text, latitude, longitude, accuracy,
                    triggered_at, status, created_at
                FROM public.sos_events
                WHERE child_id = :child_id
                  AND status = 'active'
                ORDER BY triggered_at DESC
            """),
            {"child_id": str(child_id)},
        )
        rows = result.fetchall()
        events = [
            SosEventResponse(
                id=row.id,
                child_id=row.child_id,
                latitude=row.latitude,
                longitude=row.longitude,
                accuracy=row.accuracy,
                triggered_at=row.triggered_at,
                status=row.status,
                created_at=row.created_at,
            )
            for row in rows
        ]
        logger.info("sos_active_fetched", child_id=str(child_id), count=len(events))
        return SosEventListResponse(child_id=str(child_id), events=events)
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_active_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des alertes SOS actives.",
        ) from exc


@router.post(
    "/{event_id}/acknowledge",
    response_model=SosEventResponse,
    summary="Accuse réception d'une alerte SOS (passe à 'acknowledged')",
)
async def acknowledge_sos(
    event_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> SosEventResponse:
    try:
        result = await db.execute(
            text("""
                UPDATE public.sos_events
                SET status = 'acknowledged'
                WHERE id = :event_id
                  AND status = 'active'
                RETURNING
                    id::text, child_id::text, latitude, longitude, accuracy,
                    triggered_at, status, created_at
            """),
            {"event_id": str(event_id)},
        )
        row = result.fetchone()
        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Alerte SOS introuvable ou déjà traitée.",
            )
        logger.info("sos_acknowledged", event_id=str(event_id))
        return SosEventResponse(
            id=row.id,
            child_id=row.child_id,
            latitude=row.latitude,
            longitude=row.longitude,
            accuracy=row.accuracy,
            triggered_at=row.triggered_at,
            status=row.status,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_acknowledge_error", error=str(exc), event_id=str(event_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'accusé de réception de l'alerte SOS.",
        ) from exc
