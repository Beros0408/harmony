from datetime import datetime, timezone
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/commands", tags=["Commandes appareil"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class LockCommandRequest(BaseModel):
    child_id: UUID


class CommandItem(BaseModel):
    id: str
    command: str
    status: str
    created_at: datetime


class AckResponse(BaseModel):
    acknowledged: bool


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post(
    "/lock",
    status_code=status.HTTP_201_CREATED,
    summary="Envoie une commande de verrouillage vers l'appareil d'un enfant",
)
async def send_lock_command(
    payload: LockCommandRequest,
    db: AsyncSession = Depends(get_db),
) -> dict:
    try:
        command_id = uuid4()
        now = datetime.now(timezone.utc)

        await db.execute(
            text(
                """
                INSERT INTO public.device_commands
                    (id, child_id, command, status, created_at)
                VALUES
                    (CAST(:id AS uuid), CAST(:child_id AS uuid), :command, :status, :created_at)
                """
            ),
            {
                "id": str(command_id),
                "child_id": str(payload.child_id),
                "command": "lock",
                "status": "pending",
                "created_at": now,
            },
        )

        logger.info(
            "lock_command_created",
            command_id=str(command_id),
            child_id=str(payload.child_id),
        )
        return {"command_id": str(command_id), "status": "pending"}

    except Exception as exc:
        logger.error("lock_command_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la création de la commande.",
        ) from exc


@router.get(
    "/pending",
    response_model=list[CommandItem],
    summary="Récupère les commandes en attente pour un enfant (polling app enfant)",
)
async def get_pending_commands(
    child_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[CommandItem]:
    try:
        result = await db.execute(
            text(
                """
                SELECT id::text, command, status, created_at
                FROM public.device_commands
                WHERE child_id = CAST(:child_id AS uuid)
                  AND status = 'pending'
                ORDER BY created_at ASC
                """
            ),
            {"child_id": child_id},
        )
        rows = result.fetchall()
        return [
            CommandItem(
                id=row[0],
                command=row[1],
                status=row[2],
                created_at=row[3],
            )
            for row in rows
        ]

    except Exception as exc:
        logger.error("pending_commands_error", error=str(exc), child_id=child_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des commandes.",
        ) from exc


@router.post(
    "/{command_id}/ack",
    response_model=AckResponse,
    summary="Marque une commande comme exécutée (acquittement app enfant)",
)
async def ack_command(
    command_id: str,
    db: AsyncSession = Depends(get_db),
) -> AckResponse:
    try:
        executed_at = datetime.now(timezone.utc)
        result = await db.execute(
            text(
                """
                UPDATE public.device_commands
                SET status = 'executed', executed_at = :executed_at
                WHERE id = CAST(:command_id AS uuid)
                  AND status = 'pending'
                RETURNING id
                """
            ),
            {"command_id": command_id, "executed_at": executed_at},
        )
        row = result.fetchone()
        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Commande introuvable ou déjà acquittée.",
            )

        logger.info("command_acknowledged", command_id=command_id)
        return AckResponse(acknowledged=True)

    except HTTPException:
        raise
    except Exception as exc:
        logger.error("ack_command_error", error=str(exc), command_id=command_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'acquittement.",
        ) from exc
