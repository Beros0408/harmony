from datetime import datetime, timezone
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/content-filter", tags=["Filtrage de contenu"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class ContentFilterRequest(BaseModel):
    child_id: UUID
    enabled: bool


class ContentFilterResponse(BaseModel):
    child_id: str
    enabled: bool
    updated_at: datetime


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.put(
    "",
    response_model=ContentFilterResponse,
    summary="Définit l'état du filtrage de contenu pour un enfant (parent → backend)",
)
async def set_content_filter(
    payload: ContentFilterRequest,
    db: AsyncSession = Depends(get_db),
) -> ContentFilterResponse:
    """
    Upsert : crée ou met à jour la ligne content_filter pour child_id.
    Un seul enregistrement par enfant suffit car c'est un état persistant on/off.
    """
    try:
        now = datetime.now(timezone.utc)
        result = await db.execute(
            text(
                """
                INSERT INTO public.content_filter (child_id, enabled, updated_at)
                VALUES (CAST(:child_id AS uuid), :enabled, :updated_at)
                ON CONFLICT (child_id) DO UPDATE
                    SET enabled    = EXCLUDED.enabled,
                        updated_at = EXCLUDED.updated_at
                RETURNING child_id::text, enabled, updated_at
                """
            ),
            {
                "child_id": str(payload.child_id),
                "enabled": payload.enabled,
                "updated_at": now,
            },
        )
        row = result.fetchone()
        logger.info(
            "content_filter_updated",
            child_id=str(payload.child_id),
            enabled=payload.enabled,
        )
        return ContentFilterResponse(
            child_id=row[0],
            enabled=row[1],
            updated_at=row[2],
        )
    except Exception as exc:
        logger.error("content_filter_set_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la mise à jour du filtrage.",
        ) from exc


@router.get(
    "",
    response_model=ContentFilterResponse,
    summary="Lit l'état du filtrage de contenu pour un enfant (backend ← enfant/parent)",
)
async def get_content_filter(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> ContentFilterResponse:
    """
    Retourne l'état actuel du filtrage.
    Si aucune ligne n'existe encore (premier appel), retourne enabled=False par défaut.
    """
    try:
        result = await db.execute(
            text(
                """
                SELECT child_id::text, enabled, updated_at
                FROM public.content_filter
                WHERE child_id = CAST(:child_id AS uuid)
                """
            ),
            {"child_id": child_id},
        )
        row = result.fetchone()
        if row is None:
            return ContentFilterResponse(
                child_id=child_id,
                enabled=False,
                updated_at=datetime.now(timezone.utc),
            )
        return ContentFilterResponse(
            child_id=row[0],
            enabled=row[1],
            updated_at=row[2],
        )
    except Exception as exc:
        logger.error("content_filter_get_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération du filtrage.",
        ) from exc
