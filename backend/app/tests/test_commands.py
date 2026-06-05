import uuid

import pytest
from httpx import AsyncClient


# ─── Endpoints screen-pause / screen-resume ───────────────────────────────────

@pytest.mark.asyncio
async def test_screen_pause_returns_pending(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/commands/screen-pause",
        json={"child_id": str(uuid.uuid4())},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "pending"
    assert "command_id" in data


@pytest.mark.asyncio
async def test_screen_resume_returns_pending(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/commands/screen-resume",
        json={"child_id": str(uuid.uuid4())},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "pending"
    assert "command_id" in data


@pytest.mark.asyncio
async def test_pause_command_visible_in_pending(client: AsyncClient) -> None:
    """La commande screen_pause doit apparaître dans /pending avant acquittement."""
    child_id = str(uuid.uuid4())
    post_resp = await client.post(
        "/api/v1/commands/screen-pause",
        json={"child_id": child_id},
    )
    assert post_resp.status_code == 201

    get_resp = await client.get(
        "/api/v1/commands/pending",
        params={"child_id": child_id},
    )
    assert get_resp.status_code == 200
    commands = get_resp.json()
    assert any(c["command"] == "screen_pause" for c in commands)


@pytest.mark.asyncio
async def test_resume_command_visible_in_pending(client: AsyncClient) -> None:
    """La commande screen_resume doit apparaître dans /pending avant acquittement."""
    child_id = str(uuid.uuid4())
    post_resp = await client.post(
        "/api/v1/commands/screen-resume",
        json={"child_id": child_id},
    )
    assert post_resp.status_code == 201

    get_resp = await client.get(
        "/api/v1/commands/pending",
        params={"child_id": child_id},
    )
    assert get_resp.status_code == 200
    commands = get_resp.json()
    assert any(c["command"] == "screen_resume" for c in commands)


@pytest.mark.asyncio
async def test_pause_command_disappears_after_ack(client: AsyncClient) -> None:
    """Après acquittement, la commande ne doit plus apparaître dans /pending."""
    child_id = str(uuid.uuid4())
    post_resp = await client.post(
        "/api/v1/commands/screen-pause",
        json={"child_id": child_id},
    )
    command_id = post_resp.json()["command_id"]

    ack_resp = await client.post(f"/api/v1/commands/{command_id}/ack")
    assert ack_resp.status_code == 200
    assert ack_resp.json()["acknowledged"] is True

    get_resp = await client.get(
        "/api/v1/commands/pending",
        params={"child_id": child_id},
    )
    assert get_resp.status_code == 200
    assert get_resp.json() == []


@pytest.mark.asyncio
async def test_screen_pause_invalid_uuid_returns_422(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/commands/screen-pause",
        json={"child_id": "not-a-uuid"},
    )
    assert response.status_code == 422
