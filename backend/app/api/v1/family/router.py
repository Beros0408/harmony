from datetime import datetime

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/family", tags=["Famille"])


class ChildItem(BaseModel):
    child_id: str
    full_name: str
    role: str
    created_at: datetime


class ChildStatusResponse(BaseModel):
    linked: bool


@router.get(
    "/children",
    response_model=list[ChildItem],
    summary="Liste les enfants appairés d'un parent (jointure family_links + profiles)",
)
async def get_children(
    parent_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[ChildItem]:
    try:
        result = await db.execute(
            text(
                """
                SELECT
                    p.id::text   AS child_id,
                    p.full_name,
                    p.role,
                    p.created_at
                FROM public.family_links fl
                JOIN public.profiles p ON p.id = fl.child_id
                WHERE fl.parent_id = CAST(:parent_id AS uuid)
                ORDER BY p.full_name ASC
                """
            ),
            {"parent_id": parent_id},
        )
        rows = result.fetchall()
        return [
            ChildItem(
                child_id=row[0],
                full_name=row[1] or "Enfant",
                role=row[2],
                created_at=row[3],
            )
            for row in rows
        ]

    except Exception as exc:
        logger.error("get_children_error", error=str(exc), parent_id=parent_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des enfants.",
        ) from exc


@router.get(
    "/child-status/{child_id}",
    response_model=ChildStatusResponse,
    summary="Vérifie si un child_id est encore rattaché à une famille (family_links)",
)
async def get_child_status(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> ChildStatusResponse:
    try:
        result = await db.execute(
            text(
                """
                SELECT 1
                FROM public.family_links
                WHERE child_id = CAST(:child_id AS uuid)
                LIMIT 1
                """
            ),
            {"child_id": child_id},
        )
        linked = result.fetchone() is not None
        return ChildStatusResponse(linked=linked)
    except Exception as exc:
        logger.error("get_child_status_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la vérification du lien.",
        ) from exc
