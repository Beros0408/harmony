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
    yield
    async with test_engine.begin() as conn:
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
