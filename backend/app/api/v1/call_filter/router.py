import datetime
from typing import Literal, Optional
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, field_validator
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(tags=["Filtrage Appels"])


# ─── Schémas ─────────────────────────────────────────────────────────────────

class CreateCallFilterRuleRequest(BaseModel):
    phone_number: str
    list_type: Literal["blacklist", "whitelist"]
    label: Optional[str] = None
    created_by: Literal["parent", "child"]

    @field_validator("phone_number", mode="before")
    @classmethod
    def not_blank(cls, v: object) -> str:
        if not isinstance(v, str) or not v.strip():
            raise ValueError("Ce champ ne peut pas être vide.")
        return v.strip()


class CallFilterRuleResponse(BaseModel):
    id: str
    child_id: str
    phone_number: str
    list_type: str
    label: Optional[str]
    created_by: str
    created_at: datetime.datetime


class CallFilterSettingsResponse(BaseModel):
    child_id: str
    list_mode: str
    block_hour_start: int
    block_hour_end: int
    updated_by: str
    updated_at: Optional[datetime.datetime] = None


class CallFilterSnapshotResponse(BaseModel):
    settings: CallFilterSettingsResponse
    rules: list[CallFilterRuleResponse]


class UpdateCallFilterSettingsRequest(BaseModel):
    list_mode: Literal["blacklist", "whitelist"]
    block_hour_start: int = 22
    block_hour_end: int = 7
    updated_by: Literal["parent", "child"]


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.get(
    "/call-filter-rules/{child_id}",
    response_model=CallFilterSnapshotResponse,
    summary="Snapshot de filtrage (paramètres + règles) pour un enfant",
)
async def get_call_filter_snapshot(
    child_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> CallFilterSnapshotResponse:
    try:
        settings_result = await db.execute(
            text(
                """
                SELECT child_id::text, list_mode, block_hour_start, block_hour_end, updated_by, updated_at
                FROM public.call_filter_settings
                WHERE child_id = CAST(:child_id AS uuid)
                """
            ),
            {"child_id": str(child_id)},
        )
        s = settings_result.fetchone()
        if s is None:
            settings = CallFilterSettingsResponse(
                child_id=str(child_id),
                list_mode="blacklist",
                block_hour_start=22,
                block_hour_end=7,
                updated_by="child",
                updated_at=None,
            )
        else:
            settings = CallFilterSettingsResponse(
                child_id=s.child_id,
                list_mode=s.list_mode,
                block_hour_start=s.block_hour_start,
                block_hour_end=s.block_hour_end,
                updated_by=s.updated_by,
                updated_at=s.updated_at,
            )

        rules_result = await db.execute(
            text(
                """
                SELECT id::text, child_id::text, phone_number, list_type, label, created_by, created_at
                FROM public.call_filter_rules
                WHERE child_id = CAST(:child_id AS uuid)
                ORDER BY created_at ASC
                """
            ),
            {"child_id": str(child_id)},
        )
        rules = [
            CallFilterRuleResponse(
                id=row.id,
                child_id=row.child_id,
                phone_number=row.phone_number,
                list_type=row.list_type,
                label=row.label,
                created_by=row.created_by,
                created_at=row.created_at,
            )
            for row in rules_result.fetchall()
        ]

        logger.info("call_filter_snapshot", child_id=str(child_id), rules_count=len(rules))
        return CallFilterSnapshotResponse(settings=settings, rules=rules)
    except Exception as exc:
        logger.error("call_filter_snapshot_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération du snapshot de filtrage.",
        ) from exc


@router.post(
    "/call-filter-rules/{child_id}",
    response_model=CallFilterRuleResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Ajoute un numéro à la liste de filtrage d'un enfant",
)
async def create_call_filter_rule(
    child_id: UUID,
    payload: CreateCallFilterRuleRequest,
    db: AsyncSession = Depends(get_db),
) -> CallFilterRuleResponse:
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        rule_id = uuid4()

        result = await db.execute(
            text(
                """
                INSERT INTO public.call_filter_rules
                    (id, child_id, phone_number, list_type, label, created_by, created_at)
                VALUES (
                    CAST(:id AS uuid),
                    CAST(:child_id AS uuid),
                    :phone_number,
                    :list_type,
                    :label,
                    :created_by,
                    :created_at
                )
                RETURNING id::text, child_id::text, phone_number, list_type, label, created_by, created_at
                """
            ),
            {
                "id": str(rule_id),
                "child_id": str(child_id),
                "phone_number": payload.phone_number,
                "list_type": payload.list_type,
                "label": payload.label,
                "created_by": payload.created_by,
                "created_at": now,
            },
        )
        row = result.fetchone()
        logger.info("call_filter_rule_created", rule_id=str(rule_id), child_id=str(child_id))
        return CallFilterRuleResponse(
            id=row.id,
            child_id=row.child_id,
            phone_number=row.phone_number,
            list_type=row.list_type,
            label=row.label,
            created_by=row.created_by,
            created_at=row.created_at,
        )
    except IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ce numéro est déjà dans la liste de filtrage de cet enfant.",
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("call_filter_rule_create_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la création de la règle de filtrage.",
        ) from exc


@router.delete(
    "/call-filter-rules/{rule_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Supprime une règle de filtrage par son ID",
)
async def delete_call_filter_rule(
    rule_id: UUID,
    db: AsyncSession = Depends(get_db),
) -> None:
    try:
        result = await db.execute(
            text(
                """
                DELETE FROM public.call_filter_rules
                WHERE id = CAST(:rule_id AS uuid)
                RETURNING id
                """
            ),
            {"rule_id": str(rule_id)},
        )
        if result.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Règle de filtrage introuvable.",
            )
        logger.info("call_filter_rule_deleted", rule_id=str(rule_id))
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("call_filter_rule_delete_error", error=str(exc), rule_id=str(rule_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la suppression de la règle de filtrage.",
        ) from exc


@router.put(
    "/call-filter-settings/{child_id}",
    response_model=CallFilterSettingsResponse,
    summary="Met à jour (ou crée) les paramètres de filtrage d'un enfant (upsert)",
)
async def upsert_call_filter_settings(
    child_id: UUID,
    payload: UpdateCallFilterSettingsRequest,
    db: AsyncSession = Depends(get_db),
) -> CallFilterSettingsResponse:
    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        result = await db.execute(
            text(
                """
                INSERT INTO public.call_filter_settings
                    (child_id, list_mode, block_hour_start, block_hour_end, updated_by, updated_at)
                VALUES (
                    CAST(:child_id AS uuid),
                    :list_mode,
                    :block_hour_start,
                    :block_hour_end,
                    :updated_by,
                    :updated_at
                )
                ON CONFLICT (child_id) DO UPDATE SET
                    list_mode        = EXCLUDED.list_mode,
                    block_hour_start = EXCLUDED.block_hour_start,
                    block_hour_end   = EXCLUDED.block_hour_end,
                    updated_by       = EXCLUDED.updated_by,
                    updated_at       = EXCLUDED.updated_at
                RETURNING child_id::text, list_mode, block_hour_start, block_hour_end, updated_by, updated_at
                """
            ),
            {
                "child_id": str(child_id),
                "list_mode": payload.list_mode,
                "block_hour_start": payload.block_hour_start,
                "block_hour_end": payload.block_hour_end,
                "updated_by": payload.updated_by,
                "updated_at": now,
            },
        )
        row = result.fetchone()
        logger.info(
            "call_filter_settings_upserted",
            child_id=str(child_id),
            list_mode=payload.list_mode,
        )
        return CallFilterSettingsResponse(
            child_id=row.child_id,
            list_mode=row.list_mode,
            block_hour_start=row.block_hour_start,
            block_hour_end=row.block_hour_end,
            updated_by=row.updated_by,
            updated_at=row.updated_at,
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("call_filter_settings_upsert_error", error=str(exc), child_id=str(child_id))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la mise à jour des paramètres de filtrage.",
        ) from exc
