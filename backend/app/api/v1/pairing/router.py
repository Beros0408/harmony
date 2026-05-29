from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from pydantic import BaseModel, field_validator
from datetime import datetime, timezone, timedelta
from uuid import UUID
import secrets
import structlog

from app.core.database import get_db

logger = structlog.get_logger()
router = APIRouter(prefix="/pairing", tags=["Appairage"])


class GenerateCodeRequest(BaseModel):
    child_name: str
    parent_id: UUID  # UUID de session côté mobile (local jusqu'à auth réelle)

    @field_validator("child_name", mode="before")
    @classmethod
    def strip_and_validate_name(cls, v: object) -> str:
        if not isinstance(v, str):
            raise ValueError("Le prénom doit être une chaîne de caractères.")
        v = v.strip()
        if not v:
            raise ValueError("Le prénom de l'enfant est obligatoire.")
        if len(v) > 50:
            raise ValueError("Le prénom ne peut pas dépasser 50 caractères.")
        return v


class GenerateCodeResponse(BaseModel):
    code: str
    child_name: str
    expires_at: datetime


@router.post(
    "/generate",
    response_model=GenerateCodeResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Génère un code d'appairage parent/enfant à 6 chiffres (valable 10 min)",
)
async def generate_pairing_code(
    payload: GenerateCodeRequest,
    db: AsyncSession = Depends(get_db),
) -> GenerateCodeResponse:
    # Code 6 chiffres via secrets (cryptographiquement sûr)
    code = f"{100000 + secrets.randbelow(900000)}"
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)

    await db.execute(
        text(
            """
            INSERT INTO public.pairing_codes
                (code, parent_id, child_name, is_used, expires_at)
            VALUES
                (:code, :parent_id::uuid, :child_name, false, :expires_at)
            """,
        ),
        {
            "code": code,
            "parent_id": str(payload.parent_id),
            "child_name": payload.child_name,
            "expires_at": expires_at,
        },
    )

    logger.info(
        "pairing_code_generated",
        parent_id=str(payload.parent_id),
        child_name=payload.child_name,
        expires_at=expires_at.isoformat(),
    )

    return GenerateCodeResponse(
        code=code,
        child_name=payload.child_name,
        expires_at=expires_at,
    )
