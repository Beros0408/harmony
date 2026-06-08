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
router = APIRouter(prefix="/locations", tags=["Géolocalisation"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class LocationCreateRequest(BaseModel):
    latitude: float
    longitude: float
    accuracy: Optional[float] = None
    recorded_at: Optional[datetime.datetime] = None


class LocationResponse(BaseModel):
    id: str
    child_id: str
    latitude: float
    longitude: float
    accuracy: Optional[float]
    recorded_at: datetime.datetime
    created_at: datetime.datetime


class LocationListResponse(BaseModel):
    child_id: str
    points: list[LocationResponse]


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/{child_id}",
    response_model=LocationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Insère un point de position GPS pour un enfant",
)
async def post_location(
    child_id: UUID,
    payload: LocationCreateRequest,
    db: AsyncSession = Depends(get_db),
) -> LocationResponse:
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        recorded_at = payload.recorded_at or now

        result = await db.execute(
            text("""
                INSERT INTO public.locations
                    (child_id, latitude, longitude, accuracy, recorded_at, created_at)
                VALUES
                    (:child_id, :latitude, :longitude, :accuracy, :recorded_at, :now)
                RETURNING
                    id::text, child_id::text, latitude, longitude, accuracy,
                    recorded_at, created_at
            """),
            {
                "child_id": str(child_id),
                "latitude": payload.latitude,
                "longitude": payload.longitude,
                "accuracy": payload.accuracy,
                "recorded_at": recorded_at,
                "now": now,
            },
        )
        row = result.fetchone()
        logger.info("location_inserted", child_id=str(child_id))
        return LocationResponse(
            id=row.id,
            child_id=row.child_id,
            latitude=row.latitude,
            longitude=row.longitude,
            accuracy=row.accuracy,
            recorded_at=row.recorded_at,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("location_insert_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'insertion de la position.",
        ) from exc


@router.get(
    "/latest/{child_id}",
    response_model=Optional[LocationResponse],
    summary="Dernière position GPS d'un enfant (null si aucune)",
)
async def get_latest_location(
    child_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> Optional[LocationResponse]:
    try:
        result = await db.execute(
            text("""
                SELECT
                    id::text, child_id::text, latitude, longitude, accuracy,
                    recorded_at, created_at
                FROM public.locations
                WHERE child_id = :child_id
                ORDER BY recorded_at DESC
                LIMIT 1
            """),
            {"child_id": str(child_id)},
        )
        row = result.fetchone()
        if row is None:
            logger.info("location_latest_absent", child_id=str(child_id))
            return None
        logger.info("location_latest_fetched", child_id=str(child_id))
        return LocationResponse(
            id=row.id,
            child_id=row.child_id,
            latitude=row.latitude,
            longitude=row.longitude,
            accuracy=row.accuracy,
            recorded_at=row.recorded_at,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("location_latest_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération de la dernière position.",
        ) from exc


@router.get(
    "/history/{child_id}",
    response_model=LocationListResponse,
    summary="Historique des positions GPS (N derniers points, récents d'abord)",
)
async def get_location_history(
    child_id: UUID,
    limit: int = Query(default=50, ge=1, le=200, description="Nombre de points (max 200)"),
    db: AsyncSession = Depends(get_db),
) -> LocationListResponse:
    try:
        result = await db.execute(
            text("""
                SELECT
                    id::text, child_id::text, latitude, longitude, accuracy,
                    recorded_at, created_at
                FROM public.locations
                WHERE child_id = :child_id
                ORDER BY recorded_at DESC
                LIMIT :limit
            """),
            {"child_id": str(child_id), "limit": limit},
        )
        rows = result.fetchall()
        points = [
            LocationResponse(
                id=row.id,
                child_id=row.child_id,
                latitude=row.latitude,
                longitude=row.longitude,
                accuracy=row.accuracy,
                recorded_at=row.recorded_at,
                created_at=row.created_at,
            )
            for row in rows
        ]
        logger.info(
            "location_history_fetched",
            child_id=str(child_id),
            count=len(points),
        )
        return LocationListResponse(child_id=str(child_id), points=points)
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("location_history_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération de l'historique des positions.",
        ) from exc
