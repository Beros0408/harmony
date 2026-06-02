from datetime import datetime, timezone
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/unlink", tags=["Déliage appareil"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class UnlinkRequestPayload(BaseModel):
    child_id: UUID


class UnlinkApprovePayload(BaseModel):
    parent_id: UUID


class UnlinkExecutePayload(BaseModel):
    child_id: UUID


class UnlinkPendingItem(BaseModel):
    id: str
    child_id: str
    child_name: str
    created_at: datetime


class UnlinkStatusResponse(BaseModel):
    status: str          # none | pending | approved | rejected
    request_id: str | None = None


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/request",
    status_code=status.HTTP_201_CREATED,
    summary="Crée une demande de déliage (app enfant)",
)
async def create_unlink_request(
    payload: UnlinkRequestPayload,
    db: AsyncSession = Depends(get_db),
) -> dict:
    # Récupère le parent lié à cet enfant via family_links
    result = await db.execute(
        text(
            """
            SELECT parent_id::text
            FROM public.family_links
            WHERE child_id = CAST(:child_id AS uuid)
            LIMIT 1
            """
        ),
        {"child_id": str(payload.child_id)},
    )
    row = result.fetchone()
    if row is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aucun lien familial trouvé pour cet enfant.",
        )

    parent_id = row[0]
    request_id = uuid4()
    now = datetime.now(timezone.utc)

    try:
        await db.execute(
            text(
                """
                INSERT INTO public.unlink_requests
                    (id, child_id, parent_id, status, created_at)
                VALUES
                    (CAST(:id AS uuid), CAST(:child_id AS uuid),
                     CAST(:parent_id AS uuid), 'pending', :created_at)
                """
            ),
            {
                "id": str(request_id),
                "child_id": str(payload.child_id),
                "parent_id": parent_id,
                "created_at": now,
            },
        )
        logger.info(
            "unlink_request_created",
            request_id=str(request_id),
            child_id=str(payload.child_id),
        )
        return {"request_id": str(request_id), "status": "pending"}

    except IntegrityError:
        # L'index unique partiel empêche deux demandes pending pour un même enfant
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Une demande de déliage est déjà en cours pour cet enfant.",
        )
    except Exception as exc:
        logger.error("unlink_request_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la création de la demande.",
        ) from exc


@router.get(
    "/pending",
    response_model=list[UnlinkPendingItem],
    summary="Liste les demandes en attente pour un parent (polling app parent)",
)
async def get_pending_requests(
    parent_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[UnlinkPendingItem]:
    try:
        result = await db.execute(
            text(
                """
                SELECT ur.id::text,
                       ur.child_id::text,
                       p.full_name,
                       ur.created_at
                FROM public.unlink_requests ur
                JOIN public.profiles p ON p.id = ur.child_id
                WHERE ur.parent_id = CAST(:parent_id AS uuid)
                  AND ur.status = 'pending'
                ORDER BY ur.created_at ASC
                """
            ),
            {"parent_id": parent_id},
        )
        rows = result.fetchall()
        return [
            UnlinkPendingItem(
                id=row[0],
                child_id=row[1],
                child_name=row[2],
                created_at=row[3],
            )
            for row in rows
        ]
    except Exception as exc:
        logger.error("unlink_pending_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des demandes.",
        ) from exc


@router.post(
    "/{request_id}/approve",
    summary="Approuve une demande de déliage (app parent)",
)
async def approve_unlink_request(
    request_id: str,
    payload: UnlinkApprovePayload,
    db: AsyncSession = Depends(get_db),
) -> dict:
    try:
        resolved_at = datetime.now(timezone.utc)
        result = await db.execute(
            text(
                """
                UPDATE public.unlink_requests
                SET status = 'approved', resolved_at = :resolved_at
                WHERE id = CAST(:request_id AS uuid)
                  AND parent_id = CAST(:parent_id AS uuid)
                  AND status = 'pending'
                RETURNING id
                """
            ),
            {
                "request_id": request_id,
                "parent_id": str(payload.parent_id),
                "resolved_at": resolved_at,
            },
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Demande introuvable, déjà traitée ou parent non autorisé.",
            )
        logger.info("unlink_approved", request_id=request_id, parent_id=str(payload.parent_id))
        return {"approved": True}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("unlink_approve_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'approbation.",
        ) from exc


@router.post(
    "/{request_id}/reject",
    summary="Refuse une demande de déliage (app parent)",
)
async def reject_unlink_request(
    request_id: str,
    payload: UnlinkApprovePayload,
    db: AsyncSession = Depends(get_db),
) -> dict:
    try:
        resolved_at = datetime.now(timezone.utc)
        result = await db.execute(
            text(
                """
                UPDATE public.unlink_requests
                SET status = 'rejected', resolved_at = :resolved_at
                WHERE id = CAST(:request_id AS uuid)
                  AND parent_id = CAST(:parent_id AS uuid)
                  AND status = 'pending'
                RETURNING id
                """
            ),
            {
                "request_id": request_id,
                "parent_id": str(payload.parent_id),
                "resolved_at": resolved_at,
            },
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Demande introuvable, déjà traitée ou parent non autorisé.",
            )
        logger.info("unlink_rejected", request_id=request_id, parent_id=str(payload.parent_id))
        return {"rejected": True}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("unlink_reject_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors du refus.",
        ) from exc


@router.get(
    "/status",
    response_model=UnlinkStatusResponse,
    summary="Statut de la demande de déliage en cours (polling app enfant)",
)
async def get_unlink_status(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> UnlinkStatusResponse:
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, status
                FROM public.unlink_requests
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY created_at DESC
                LIMIT 1
                """
            ),
            {"child_id": child_id},
        )
        row = result.fetchone()
        if row is None:
            return UnlinkStatusResponse(status="none")
        return UnlinkStatusResponse(status=row[1], request_id=row[0])
    except Exception as exc:
        logger.error("unlink_status_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la vérification du statut.",
        ) from exc


@router.post(
    "/{request_id}/execute",
    summary="Exécute le déliage : supprime family_links (app enfant, après approbation)",
)
async def execute_unlink(
    request_id: str,
    payload: UnlinkExecutePayload,
    db: AsyncSession = Depends(get_db),
) -> dict:
    try:
        # Vérifie que la demande est approuvée et appartient bien à cet enfant
        result = await db.execute(
            text(
                """
                SELECT id FROM public.unlink_requests
                WHERE id = CAST(:request_id AS uuid)
                  AND child_id = CAST(:child_id AS uuid)
                  AND status = 'approved'
                """
            ),
            {"request_id": request_id, "child_id": str(payload.child_id)},
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Demande introuvable, non approuvée ou enfant incorrect.",
            )

        # Supprime le lien familial — l'enfant n'a plus de parent dans Supabase
        await db.execute(
            text(
                "DELETE FROM public.family_links WHERE child_id = CAST(:child_id AS uuid)"
            ),
            {"child_id": str(payload.child_id)},
        )

        # Supprime également la demande (nettoyage)
        await db.execute(
            text(
                "DELETE FROM public.unlink_requests WHERE id = CAST(:request_id AS uuid)"
            ),
            {"request_id": request_id},
        )

        logger.info("unlink_executed", request_id=request_id, child_id=str(payload.child_id))
        return {"unlinked": True}

    except HTTPException:
        raise
    except Exception as exc:
        logger.error("unlink_execute_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'exécution du déliage.",
        ) from exc
