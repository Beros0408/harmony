import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.pool import NullPool

from app.main import app
from app.core.database import Base, get_db

TEST_DATABASE_URL = "postgresql+asyncpg://harmony:harmony@localhost:5432/harmony_test"

test_engine = create_async_engine(TEST_DATABASE_URL, poolclass=NullPool)
TestSessionLocal = async_sessionmaker(
    bind=test_engine, class_=AsyncSession, expire_on_commit=False
)


@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_database():
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        # table hors ORM — DDL explicite
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.screen_time_usage (
                id              uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id        uuid        NOT NULL,
                package_name    text        NOT NULL,
                app_label       text,
                category        text,
                duration_seconds integer    NOT NULL DEFAULT 0,
                usage_date      date        NOT NULL,
                created_at      timestamptz DEFAULT now(),
                updated_at      timestamptz DEFAULT now(),
                UNIQUE (child_id, package_name, usage_date)
            )
            """
        ))
        await conn.execute(text(
            """
            CREATE INDEX IF NOT EXISTS idx_screen_time_child_date
                ON public.screen_time_usage (child_id, usage_date)
            """
        ))
        # table limites hors ORM — DDL explicite (Sprint 5B + 5D-5)
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.screen_time_limits (
                id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id      uuid        NOT NULL,
                scope         text        NOT NULL CHECK (scope IN ('global', 'app')),
                package_name  text,
                day_type      text        NOT NULL DEFAULT 'all'
                                          CHECK (day_type IN ('all', 'weekday', 'weekend')),
                limit_seconds integer     NOT NULL CHECK (limit_seconds >= 0),
                created_at    timestamptz DEFAULT now(),
                updated_at    timestamptz DEFAULT now()
            )
            """
        ))
        await conn.execute(text(
            """
            CREATE INDEX IF NOT EXISTS idx_screen_time_limits_child
                ON public.screen_time_limits (child_id)
            """
        ))
        # Index unique partiel — un seul global par (enfant, day_type) — Sprint 5D-5
        await conn.execute(text(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS uq_screen_time_limits_global_day_type
                ON public.screen_time_limits (child_id, day_type)
                WHERE scope = 'global'
            """
        ))
        # Index unique partiel — une seule limite par (enfant, app)
        await conn.execute(text(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS uq_screen_time_limits_app
                ON public.screen_time_limits (child_id, package_name)
                WHERE scope = 'app'
            """
        ))
        # table bonus hors ORM — DDL explicite (Sprint 5D-2)
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.screen_time_bonus (
                id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id      uuid        NOT NULL,
                bonus_date    date        NOT NULL,
                bonus_seconds integer     NOT NULL DEFAULT 0 CHECK (bonus_seconds >= 0),
                created_at    timestamptz DEFAULT now(),
                updated_at    timestamptz DEFAULT now(),
                CONSTRAINT uq_screen_time_bonus_child_date UNIQUE (child_id, bonus_date)
            )
            """
        ))
        await conn.execute(text(
            """
            CREATE INDEX IF NOT EXISTS idx_screen_time_bonus_child
                ON public.screen_time_bonus (child_id)
            """
        ))
        # table commandes appareil hors ORM (Sprint B2 + 5D-3)
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.device_commands (
                id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id    uuid        NOT NULL,
                command     text        NOT NULL,
                status      text        NOT NULL DEFAULT 'pending',
                created_at  timestamptz DEFAULT now(),
                executed_at timestamptz
            )
            """
        ))
        await conn.execute(text(
            """
            CREATE INDEX IF NOT EXISTS idx_device_commands_child_status
                ON public.device_commands (child_id, status)
            """
        ))
        # tables bien-être numérique (Module 6) — DDL miroir du schéma Supabase
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.wellbeing_signals (
                id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id    uuid        NOT NULL,
                signal_type text        NOT NULL,
                severity    text        NOT NULL DEFAULT 'vigilance'
                                        CHECK (severity IN ('info', 'vigilance', 'attention')),
                source      text        NOT NULL DEFAULT 'screen_time',
                details     jsonb,
                signal_date date        NOT NULL,
                created_at  timestamptz DEFAULT now(),
                UNIQUE (child_id, signal_type, signal_date)
            )
            """
        ))
        await conn.execute(text(
            """
            CREATE TABLE IF NOT EXISTS public.wellbeing_alerts (
                id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
                child_id    uuid        NOT NULL,
                signal_id   uuid        NOT NULL,
                title       text        NOT NULL,
                message     text        NOT NULL,
                severity    text        NOT NULL DEFAULT 'vigilance'
                                        CHECK (severity IN ('info', 'vigilance', 'attention')),
                status      text        NOT NULL DEFAULT 'sent'
                                        CHECK (status IN ('sent', 'read', 'handled')),
                created_at  timestamptz DEFAULT now(),
                read_at     timestamptz
            )
            """
        ))
    yield
    async with test_engine.begin() as conn:
        # wellbeing_alerts avant wellbeing_signals (dépendance signal_id)
        await conn.execute(text("DROP TABLE IF EXISTS public.wellbeing_alerts"))
        await conn.execute(text("DROP TABLE IF EXISTS public.wellbeing_signals"))
        await conn.execute(text("DROP TABLE IF EXISTS public.device_commands"))
        await conn.execute(text("DROP TABLE IF EXISTS public.screen_time_bonus"))
        await conn.execute(text("DROP TABLE IF EXISTS public.screen_time_limits"))
        await conn.execute(text("DROP TABLE IF EXISTS public.screen_time_usage"))
        await conn.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture
async def db_session():
    async with TestSessionLocal() as session:
        yield session
        await session.rollback()


@pytest_asyncio.fixture
async def client(db_session: AsyncSession):
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac

    app.dependency_overrides.clear()
