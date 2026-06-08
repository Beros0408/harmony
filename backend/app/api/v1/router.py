from fastapi import APIRouter
from app.api.v1.auth.router import router as auth_router
from app.api.v1.commands.router import router as commands_router
from app.api.v1.consent.router import router as consent_router
from app.api.v1.content_filter.router import router as content_filter_router
from app.api.v1.family.router import router as family_router
from app.api.v1.fitness.router import router as fitness_router
from app.api.v1.locations.router import router as locations_router
from app.api.v1.pairing.router import router as pairing_router
from app.api.v1.privacy.router import router as privacy_router
from app.api.v1.schedules.router import router as schedules_router
from app.api.v1.screen_time.router import router as screen_time_router
from app.api.v1.sos.router import router as sos_router
from app.api.v1.unlink.router import router as unlink_router
from app.api.v1.wellbeing.router import router as wellbeing_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth_router)
api_router.include_router(pairing_router)
api_router.include_router(commands_router)
api_router.include_router(consent_router)
api_router.include_router(family_router)
api_router.include_router(fitness_router)
api_router.include_router(locations_router)
api_router.include_router(privacy_router)
api_router.include_router(schedules_router)
api_router.include_router(content_filter_router)
api_router.include_router(screen_time_router)
api_router.include_router(unlink_router)
api_router.include_router(wellbeing_router)
api_router.include_router(sos_router)
