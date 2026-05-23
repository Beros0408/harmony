import pytest
from httpx import AsyncClient


REGISTER_PAYLOAD = {
    "email": "test@harmony.app",
    "password": "Harmony123",
    "full_name": "Test User",
    "role": "parent",
}


@pytest.mark.asyncio
async def test_register_success(client: AsyncClient):
    response = await client.post("/api/v1/auth/register", json=REGISTER_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["user"]["email"] == REGISTER_PAYLOAD["email"]
    assert "access_token" in data["tokens"]
    assert "refresh_token" in data["tokens"]


@pytest.mark.asyncio
async def test_register_duplicate_email(client: AsyncClient):
    payload = {**REGISTER_PAYLOAD, "email": "duplicate@harmony.app"}
    await client.post("/api/v1/auth/register", json=payload)
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_register_weak_password(client: AsyncClient):
    payload = {**REGISTER_PAYLOAD, "email": "weak@harmony.app", "password": "weak"}
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_login_success(client: AsyncClient):
    email = "login_test@harmony.app"
    await client.post(
        "/api/v1/auth/register",
        json={**REGISTER_PAYLOAD, "email": email},
    )
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": REGISTER_PAYLOAD["password"]},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["tokens"]["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient):
    email = "wrongpwd@harmony.app"
    await client.post(
        "/api/v1/auth/register",
        json={**REGISTER_PAYLOAD, "email": email},
    )
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "WrongPassword1"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_me_authenticated(client: AsyncClient):
    email = "me_test@harmony.app"
    reg = await client.post(
        "/api/v1/auth/register",
        json={**REGISTER_PAYLOAD, "email": email},
    )
    token = reg.json()["tokens"]["access_token"]
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    assert response.json()["email"] == email


@pytest.mark.asyncio
async def test_get_me_unauthenticated(client: AsyncClient):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_refresh_token(client: AsyncClient):
    email = "refresh_test@harmony.app"
    reg = await client.post(
        "/api/v1/auth/register",
        json={**REGISTER_PAYLOAD, "email": email},
    )
    refresh_token = reg.json()["tokens"]["refresh_token"]
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert response.status_code == 200
    assert "access_token" in response.json()


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient):
    response = await client.get("/health")
    assert response.status_code in [200, 503]
    assert "status" in response.json()
