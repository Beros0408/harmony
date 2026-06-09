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
router = APIRouter(tags=["Appels Bloqués"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class BlockedCallItem(BaseModel):
    phone_number: str
    blocked_at: datetime.datetime
    list_mode: Optional[str] = None
    latency_ms: Optional[int] = None

    @field_validator("phone_number", mode="before")
    @classmethod
    def not_blank(cls, v: object) -> str:
        if not isinstance(v, str) or not v.strip():
            raise ValueError("Ce champ ne peut pas être vide.")
        return v.strip()

    @field_validator("list_mode", mode="before")
    @classmethod
    def valid_list_mode(cls, v: object) -> Optional[str]:
        if v is None:
            return None
        if v not in ("blacklist", "whitelist"):
            raise ValueError("list_mode doit être 'blacklist' ou 'whitelist'.")
        return v


class BatchUploadRequest(BaseModel):
    calls: list[BlockedCallItem]

    @field_validator("calls", mode="before")
    @classmethod
    def not_empty(cls, v: object) -> list:
        if not isinstance(v, list) or len(v) == 0:
            raise ValueError("La liste d'appels ne peut pas être vide.")
        return v


class BatchUploadResponse(BaseModel):
    inserted: int
    skipped: int


class BlockedCallResponse(BaseModel):
    id: str
    child_id: str
    phone_number: str
    blocked_at: datetime.datetime
    list_mode: Optional[str]
    latency_ms: Optional[int]
    created_at: datetime.datetime


class BlockedCallListResponse(BaseModel):
    calls: list[BlockedCallResponse]


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/blocked-calls/{child_id}",
    response_model=BatchUploadResponse,
    status_code=status.HTTP_200_OK,
    summary="Upload batch d'appels bloqués (enfant → backend)",
)
async def upload_blocked_calls(
    child_id: UUID,
    payload: BatchUploadRequest,
    db: AsyncSession = Depends(get_db),
) -> BatchUploadResponse:
    try:
        total = len(payload.calls)
        if total == 0:
            return BatchUploadResponse(inserted=0, skipped=0)

        rows = [
            {
                "child_id": str(child_id),
                "phone_number": call.phone_number,
                "blocked_at": call.blocked_at,
                "list_mode": call.list_mode,
                "latency_ms": call.latency_ms,
            }
            for call in payload.calls
        ]

        inserted_count = 0
        for row in rows:
            result = await db.execute(
                text(
                    """
                    INSERT INTO public.blocked_call_logs
                        (child_id, phone_number, blocked_at, list_mode, latency_ms)
                    VALUES (
                        CAST(:child_id AS uuid),
                        :phone_number,
                        :blocked_at,
                        :list_mode,
                        :latency_ms
                    )
                    ON CONFLICT ON CONSTRAINT uq_blocked_call DO NOTHING
                    RETURNING id
                    """
                ),
                row,
            )
            if result.fetchone() is not None:
                inserted_count += 1

        skipped = total - inserted_count
        logger.info(
            "blocked_calls_uploaded",
            child_id=str(child_id),
            total=total,
            inserted=inserted_count,
            skipped=skipped,
        )
        return BatchUploadResponse(inserted=inserted_count, skipped=skipped)
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("blocked_calls_upload_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'upload des appels bloques.",
        ) from exc


@router.get(
    "/blocked-calls/{child_id}",
    response_model=BlockedCallListResponse,
    summary="Liste des appels bloqués d'un enfant (lecture parent)",
)
async def get_blocked_calls(
    child_id: UUID,
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> BlockedCallListResponse:
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, child_id::text, phone_number,
                       blocked_at, list_mode, latency_ms, created_at
                FROM public.blocked_call_logs
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY blocked_at DESC
                LIMIT :limit OFFSET :offset
                """
            ),
            {"child_id": str(child_id), "limit": limit, "offset": offset},
        )
        calls = [
            BlockedCallResponse(
                id=row.id,
                child_id=row.child_id,
                phone_number=row.phone_number,
                blocked_at=row.blocked_at,
                list_mode=row.list_mode,
                latency_ms=row.latency_ms,
                created_at=row.created_at,
            )
            for row in result.fetchall()
        ]
        logger.info("blocked_calls_fetched", child_id=str(child_id), count=len(calls))
        return BlockedCallListResponse(calls=calls)
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("blocked_calls_fetch_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des appels bloqués.",
        ) from exc
