from fastapi import FastAPI
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from slowapi.errors import RateLimitExceeded
import structlog

from app.core.config import settings
from app.core.database import check_database_health, check_db_connection, check_redis_health, close_redis
from app.core.middleware import setup_middleware, limiter, rate_limit_exceeded_handler
from app.api.v1.router import api_router

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ]
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("startup", version=settings.app_version, environment=settings.environment)
    yield
    await close_redis()
    logger.info("shutdown")


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    openapi_url="/openapi.json" if settings.debug else None,
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)

setup_middleware(app)
app.include_router(api_router)


@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Bienvenue sur Harmony Backend",
        "version": settings.app_version,
        "docs": "/docs" if settings.debug else "Activez DEBUG=true pour accéder à la documentation.",
    }


@app.get("/health", tags=["Monitoring"])
async def health_check():
    db_health = await check_database_health()
    redis_health = await check_redis_health()
    db_connected = await check_db_connection()

    all_ok = all(h["status"] == "ok" for h in [db_health, redis_health])
    status_code = 200 if all_ok else 503

    return JSONResponse(
        status_code=status_code,
        content={
            "status": "ok" if all_ok else "degraded",
            # Format simplifié attendu par le mobile : "connected" | "disconnected"
            "database": "connected" if db_connected else "disconnected",
            "env": settings.environment,
            "version": settings.app_version,
            "services": {
                "database": db_health,
                "redis": redis_health,
            },
        },
    )
