import re

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from pydantic import BaseModel, field_validator
from datetime import datetime, timezone, timedelta
from uuid import UUID, uuid4
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
                (:code, CAST(:parent_id AS uuid), :child_name, false, :expires_at)
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


# ─── Redeem (côté enfant) ────────────────────────────────────────────────────

class RedeemCodeRequest(BaseModel):
    code: str
    device_label: str = ""

    @field_validator("code", mode="before")
    @classmethod
    def validate_code(cls, v: object) -> str:
        if not isinstance(v, str):
            raise ValueError("Le code doit être une chaîne de caractères.")
        # Supprime les espaces en tête/queue ET les espaces internes (ex : "919 489")
        v = re.sub(r"\s+", "", v.strip())
        if not v.isdigit() or len(v) != 6:
            raise ValueError("Le code doit être composé de 6 chiffres.")
        return v


class RedeemCodeResponse(BaseModel):
    parent_name: str
    child_name: str
    child_id: str   # UUID du profil enfant créé dans public.profiles
    linked: bool


@router.post(
    "/redeem",
    response_model=RedeemCodeResponse,
    status_code=status.HTTP_200_OK,
    summary="Valide un code d'appairage et crée le lien parent ↔ enfant",
)
async def redeem_pairing_code(
    payload: RedeemCodeRequest,
    db: AsyncSession = Depends(get_db),
) -> RedeemCodeResponse:
    try:
        # Nettoyage défensif : on ne garde que les chiffres au cas où un caractère
        # parasite (espace, tiret, nbsp…) aurait traversé la validation Pydantic.
        clean_code = re.sub(r"[^\d]", "", payload.code)

        # 1. Chercher le code valide (non utilisé, non expiré).
        #    • code::text = :code  — cast explicite pour éviter toute ambiguïté
        #      de type entre la colonne (text ou integer) et le paramètre asyncpg.
        #    • clock_timestamp() au lieu de now() : retourne l'heure murale réelle,
        #      pas l'horodatage de début de transaction qui peut être stale dans un pool.
        result = await db.execute(
            text(
                """
                SELECT id, parent_id, child_name
                FROM public.pairing_codes
                WHERE code::text = :code
                  AND is_used = false
                  AND expires_at > clock_timestamp()
                LIMIT 1
                """
            ),
            {"code": clean_code},
        )
        row = result.fetchone()

        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Code invalide ou expiré.",
            )

        pairing_row_id: UUID = row[0]
        parent_id: UUID = row[1]
        child_name: str = row[2]

        # 2. Récupérer le nom du parent (full_name ou email)
        parent_result = await db.execute(
            text(
                """
                SELECT COALESCE(full_name, email, 'Parent') AS parent_name
                FROM public.profiles
                WHERE id = CAST(:parent_id AS uuid)
                LIMIT 1
                """
            ),
            {"parent_id": str(parent_id)},
        )
        parent_row = parent_result.fetchone()
        parent_name: str = parent_row[0] if parent_row else "Parent"

        # 3. Créer un profil enfant
        child_id = uuid4()
        generated_email = f"child_{child_id.hex[:8]}@harmony.local"
        await db.execute(
            text(
                """
                INSERT INTO public.profiles (id, role, full_name, email)
                VALUES (CAST(:id AS uuid), 'child', :full_name, :email)
                """
            ),
            {
                "id": str(child_id),
                "full_name": child_name,
                "email": generated_email,
            },
        )

        # 4. Créer le lien family_links
        await db.execute(
            text(
                """
                INSERT INTO public.family_links (parent_id, child_id)
                VALUES (CAST(:parent_id AS uuid), CAST(:child_id AS uuid))
                """
            ),
            {"parent_id": str(parent_id), "child_id": str(child_id)},
        )

        # 5. Marquer le code comme utilisé
        await db.execute(
            text(
                """
                UPDATE public.pairing_codes
                SET is_used = true
                WHERE id = CAST(:row_id AS uuid)
                """
            ),
            {"row_id": str(pairing_row_id)},
        )

        logger.info(
            "pairing_code_redeemed",
            parent_id=str(parent_id),
            child_id=str(child_id),
            child_name=child_name,
            device_label=payload.device_label,
        )

        return RedeemCodeResponse(
            parent_name=parent_name,
            child_name=child_name,
            child_id=str(child_id),
            linked=True,
        )

    except HTTPException:
        raise
    except Exception as exc:
        logger.error("pairing_redeem_error", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur serveur lors de la validation du code.",
        ) from exc
