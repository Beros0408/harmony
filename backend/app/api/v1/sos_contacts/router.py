import datetime
from typing import Literal, Optional
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, field_validator
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/sos-contacts", tags=["Contacts SOS"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class CreateSosContactRequest(BaseModel):
    name: str
    phone: str
    created_by: Literal["parent", "child"]
    sort_order: Optional[int] = None

    @field_validator("name", "phone", mode="before")
    @classmethod
    def not_blank(cls, v: object) -> str:
        if not isinstance(v, str) or not v.strip():
            raise ValueError("Ce champ ne peut pas être vide.")
        return v.strip()


class UpdateSosContactRequest(BaseModel):
    sort_order: int


class SosContactResponse(BaseModel):
    id: str
    child_id: str
    name: str
    phone: str
    created_by: str
    sort_order: int
    created_at: datetime.datetime


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/{child_id}",
    response_model=SosContactResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Crée un contact SOS pour un enfant",
)
async def create_sos_contact(
    child_id: UUID,
    payload: CreateSosContactRequest,
    db: AsyncSession = Depends(get_db),
) -> SosContactResponse:
    try:
        if payload.sort_order is None:
            max_row = await db.execute(
                text(
                    "SELECT COALESCE(MAX(sort_order), -1) + 1 "
                    "FROM public.sos_contacts "
                    "WHERE child_id = CAST(:child_id AS uuid)"
                ),
                {"child_id": str(child_id)},
            )
            sort_order: int = max_row.scalar()
        else:
            sort_order = payload.sort_order

        now = datetime.datetime.now(datetime.timezone.utc)
        contact_id = uuid4()

        result = await db.execute(
            text(
                """
                INSERT INTO public.sos_contacts
                    (id, child_id, name, phone, created_by, sort_order, created_at)
                VALUES (
                    CAST(:id AS uuid),
                    CAST(:child_id AS uuid),
                    :name,
                    :phone,
                    :created_by,
                    :sort_order,
                    :created_at
                )
                RETURNING id::text, child_id::text, name, phone, created_by, sort_order, created_at
                """
            ),
            {
                "id": str(contact_id),
                "child_id": str(child_id),
                "name": payload.name,
                "phone": payload.phone,
                "created_by": payload.created_by,
                "sort_order": sort_order,
                "created_at": now,
            },
        )
        row = result.fetchone()
        logger.info("sos_contact_created", contact_id=str(contact_id), child_id=str(child_id))
        return SosContactResponse(
            id=row.id,
            child_id=row.child_id,
            name=row.name,
            phone=row.phone,
            created_by=row.created_by,
            sort_order=row.sort_order,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_contact_create_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la création du contact SOS.",
        ) from exc


@router.get(
    "/{child_id}",
    response_model=list[SosContactResponse],
    summary="Liste les contacts SOS d'un enfant (sort_order ASC, created_at ASC)",
)
async def list_sos_contacts(
    child_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> list[SosContactResponse]:
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, child_id::text, name, phone, created_by, sort_order, created_at
                FROM public.sos_contacts
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY sort_order ASC, created_at ASC
                """
            ),
            {"child_id": str(child_id)},
        )
        rows = result.fetchall()
        logger.info("sos_contacts_listed", child_id=str(child_id), count=len(rows))
        return [
            SosContactResponse(
                id=row.id,
                child_id=row.child_id,
                name=row.name,
                phone=row.phone,
                created_by=row.created_by,
                sort_order=row.sort_order,
                created_at=row.created_at,
            )
            for row in rows
        ]
    except Exception as exc:
        logger.error("sos_contacts_list_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des contacts SOS.",
        ) from exc


@router.delete(
    "/{contact_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Supprime un contact SOS",
)
async def delete_sos_contact(
    contact_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> None:
    try:
        result = await db.execute(
            text(
                """
                DELETE FROM public.sos_contacts
                WHERE id = CAST(:contact_id AS uuid)
                RETURNING id
                """
            ),
            {"contact_id": str(contact_id)},
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Contact SOS introuvable.",
            )
        logger.info("sos_contact_deleted", contact_id=str(contact_id))
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_contact_delete_error", error=str(exc), contact_id=str(contact_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la suppression du contact SOS.",
        ) from exc


@router.patch(
    "/{contact_id}",
    response_model=SosContactResponse,
    summary="Met à jour l'ordre d'un contact SOS",
)
async def update_sos_contact_order(
    contact_id: UUID,
    payload: UpdateSosContactRequest,
    db: AsyncSession = Depends(get_db),
) -> SosContactResponse:
    try:
        result = await db.execute(
            text(
                """
                UPDATE public.sos_contacts
                SET sort_order = :sort_order
                WHERE id = CAST(:contact_id AS uuid)
                RETURNING id::text, child_id::text, name, phone, created_by, sort_order, created_at
                """
            ),
            {
                "contact_id": str(contact_id),
                "sort_order": payload.sort_order,
            },
        )
        row = result.fetchone()
        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Contact SOS introuvable.",
            )
        logger.info("sos_contact_order_updated", contact_id=str(contact_id), sort_order=payload.sort_order)
        return SosContactResponse(
            id=row.id,
            child_id=row.child_id,
            name=row.name,
            phone=row.phone,
            created_by=row.created_by,
            sort_order=row.sort_order,
            created_at=row.created_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("sos_contact_patch_error", error=str(exc), contact_id=str(contact_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la mise à jour du contact SOS.",
        ) from exc
