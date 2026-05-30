from fastapi import APIRouter
from app.api.v1.auth.router import router as auth_router
from app.api.v1.commands.router import router as commands_router
from app.api.v1.pairing.router import router as pairing_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth_router)
api_router.include_router(pairing_router)
api_router.include_router(commands_router)
