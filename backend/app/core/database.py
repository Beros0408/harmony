from sqlalchemy.ext.asyncio import (
    AsyncSession,
    AsyncEngine,
    create_async_engine,
    async_sessionmaker,
)
from sqlalchemy.orm import DeclarativeBase
from redis.asyncio import Redis, from_url
from contextlib import asynccontextmanager
from typing import AsyncGenerator
import structlog

from app.core.config import settings

logger = structlog.get_logger()

# ---------------------------------------------------------------------------
# SQLAlchemy — PostgreSQL async
# ---------------------------------------------------------------------------

engine: AsyncEngine = create_async_engine(
    settings.database_url,
    pool_size=settings.database_pool_size,
    max_overflow=settings.database_max_overflow,
    echo=settings.debug,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# ---------------------------------------------------------------------------
# Redis
# ---------------------------------------------------------------------------

redis_client: Redis | None = None


async def get_redis() -> Redis:
    global redis_client
    if redis_client is None:
        redis_client = from_url(
            settings.redis_url,
            password=settings.redis_password or None,
            encoding="utf-8",
            decode_responses=True,
        )
    return redis_client


async def close_redis() -> None:
    global redis_client
    if redis_client is not None:
        await redis_client.aclose()
        redis_client = None


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

async def check_db_connection() -> bool:
    """Vérifie que la base répond — renvoie True ou False sans lever d'exception."""
    try:
        async with AsyncSessionLocal() as session:
            await session.execute(__import__("sqlalchemy").text("SELECT 1"))
        return True
    except Exception as exc:
        logger.error("db_connection_check_failed", error=str(exc))
        return False


async def check_database_health() -> dict:
    try:
        async with AsyncSessionLocal() as session:
            await session.execute(__import__("sqlalchemy").text("SELECT 1"))
        return {"status": "ok"}
    except Exception as exc:
        logger.error("database_health_check_failed", error=str(exc))
        return {"status": "error", "detail": "Database unreachable"}


async def check_redis_health() -> dict:
    try:
        client = await get_redis()
        await client.ping()
        return {"status": "ok"}
    except Exception as exc:
        logger.error("redis_health_check_failed", error=str(exc))
        return {"status": "error", "detail": "Redis unreachable"}
