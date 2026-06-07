from typing import Any
from uuid import UUID

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/consent", tags=["RGPD – Consentements"])


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _serialize(v: Any) -> Any:
    if hasattr(v, "isoformat"):
        return v.isoformat()
    if isinstance(v, UUID):
        return str(v)
    return v


def _row_to_dict(row) -> dict:
    return {k: _serialize(v) for k, v in row._mapping.items()}


# ─── Schémas ─────────────────────────────────────────────────────────────────

class ConsentUpsertRequest(BaseModel):
    parent_id: str
    child_id: str | None = None
    consent_type: str
    granted: bool = True
    policy_version: str = "1.0"


class ConsentRecord(BaseModel):
    id: str
    parent_id: str
    child_id: str | None
    consent_type: str
    granted: bool
    policy_version: str
    created_at: str


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.put(
    "",
    response_model=ConsentRecord,
    summary="Enregistre ou met à jour un consentement RGPD parental (upsert)",
)
async def upsert_consent(
    body: ConsentUpsertRequest,
    db: AsyncSession = Depends(get_db),
) -> ConsentRecord:
    """
    Upsert sur (parent_id, child_id, consent_type).
    Deux index partiels distincts gèrent le cas child_id IS NOT NULL
    et le cas child_id IS NULL (consentement global du parent).
    """
    try:
        if body.child_id is not None:
            sql = text(
                "INSERT INTO public.consent_records"
                " (parent_id, child_id, consent_type, granted, policy_version)"
                " VALUES (CAST(:parent_id AS uuid), CAST(:child_id AS uuid),"
                " :consent_type, :granted, :policy_version)"
                " ON CONFLICT (parent_id, child_id, consent_type)"
                " WHERE child_id IS NOT NULL"
                " DO UPDATE SET"
                " granted = EXCLUDED.granted,"
                " policy_version = EXCLUDED.policy_version,"
                " created_at = now()"
                " RETURNING *"
            )
            params: dict = {
                "parent_id": body.parent_id,
                "child_id": body.child_id,
                "consent_type": body.consent_type,
                "granted": body.granted,
                "policy_version": body.policy_version,
            }
        else:
            sql = text(
                "INSERT INTO public.consent_records"
                " (parent_id, child_id, consent_type, granted, policy_version)"
                " VALUES (CAST(:parent_id AS uuid), NULL,"
                " :consent_type, :granted, :policy_version)"
                " ON CONFLICT (parent_id, consent_type)"
                " WHERE child_id IS NULL"
                " DO UPDATE SET"
                " granted = EXCLUDED.granted,"
                " policy_version = EXCLUDED.policy_version,"
                " created_at = now()"
                " RETURNING *"
            )
            params = {
                "parent_id": body.parent_id,
                "consent_type": body.consent_type,
                "granted": body.granted,
                "policy_version": body.policy_version,
            }

        r = await db.execute(sql, params)
        row = r.fetchone()
        d = _row_to_dict(row)
        logger.info(
            "consent_upserted",
            parent_id=body.parent_id,
            child_id=body.child_id,
            consent_type=body.consent_type,
            granted=body.granted,
        )
        return ConsentRecord(**d)

    except Exception as exc:
        logger.error("consent_upsert_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'enregistrement du consentement.",
        ) from exc


@router.get(
    "/{parent_id}",
    summary="Liste tous les consentements d'un parent (RGPD – traçabilité)",
)
async def list_consents(
    parent_id: str,
    db: AsyncSession = Depends(get_db),
) -> list[dict]:
    try:
        r = await db.execute(
            text(
                "SELECT * FROM public.consent_records"
                " WHERE parent_id = CAST(:parent_id AS uuid)"
                " ORDER BY created_at DESC"
            ),
            {"parent_id": parent_id},
        )
        rows = [_row_to_dict(row) for row in r.fetchall()]
        logger.info("consent_listed", parent_id=parent_id, count=len(rows))
        return rows

    except Exception as exc:
        logger.error("consent_list_error", error=str(exc), parent_id=parent_id)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des consentements.",
        ) from exc
