import uuid

import pytest
from httpx import AsyncClient

CHILD_ID = str(uuid.uuid4())

RULE_PAYLOAD = {
    "phone_number": "+33600000001",
    "list_type": "blacklist",
    "created_by": "parent",
}

SETTINGS_PAYLOAD = {
    "list_mode": "whitelist",
    "block_hour_start": 21,
    "block_hour_end": 8,
    "updated_by": "parent",
}


# ─── GET /call-filter-rules/{child_id} ───────────────────────────────────────

@pytest.mark.asyncio
async def test_get_snapshot_default_settings_for_unknown_child(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.get(f"/api/v1/call-filter-rules/{child_id}")
    assert response.status_code == 200
    data = response.json()
    assert "settings" in data
    assert "rules" in data
    assert data["rules"] == []
    assert data["settings"]["list_mode"] == "blacklist"
    assert data["settings"]["block_hour_start"] == 22
    assert data["settings"]["block_hour_end"] == 7
    assert data["settings"]["child_id"] == child_id


@pytest.mark.asyncio
async def test_get_snapshot_shows_rules_after_post(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(f"/api/v1/call-filter-rules/{child_id}", json=RULE_PAYLOAD)
    await client.post(
        f"/api/v1/call-filter-rules/{child_id}",
        json={**RULE_PAYLOAD, "phone_number": "+33600000002", "list_type": "whitelist"},
    )

    response = await client.get(f"/api/v1/call-filter-rules/{child_id}")
    assert response.status_code == 200
    rules = response.json()["rules"]
    assert len(rules) == 2
    numbers = {r["phone_number"] for r in rules}
    assert numbers == {"+33600000001", "+33600000002"}


@pytest.mark.asyncio
async def test_get_snapshot_reflects_settings_after_put(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.put(f"/api/v1/call-filter-settings/{child_id}", json=SETTINGS_PAYLOAD)

    response = await client.get(f"/api/v1/call-filter-rules/{child_id}")
    assert response.status_code == 200
    settings = response.json()["settings"]
    assert settings["list_mode"] == "whitelist"
    assert settings["block_hour_start"] == 21
    assert settings["block_hour_end"] == 8


@pytest.mark.asyncio
async def test_get_snapshot_isolation_between_children(client: AsyncClient):
    child_a = str(uuid.uuid4())
    child_b = str(uuid.uuid4())
    await client.post(f"/api/v1/call-filter-rules/{child_a}", json=RULE_PAYLOAD)

    response = await client.get(f"/api/v1/call-filter-rules/{child_b}")
    assert response.json()["rules"] == []


# ─── POST /call-filter-rules/{child_id} ──────────────────────────────────────

@pytest.mark.asyncio
async def test_create_rule_returns_201(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.post(f"/api/v1/call-filter-rules/{child_id}", json=RULE_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["child_id"] == child_id
    assert data["phone_number"] == "+33600000001"
    assert data["list_type"] == "blacklist"
    assert data["created_by"] == "parent"
    assert data["label"] is None
    assert "id" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_create_rule_with_label(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**RULE_PAYLOAD, "label": "Démarcheur suspect"}
    response = await client.post(f"/api/v1/call-filter-rules/{child_id}", json=payload)
    assert response.status_code == 201
    assert response.json()["label"] == "Démarcheur suspect"


@pytest.mark.asyncio
async def test_create_rule_whitelist_type(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**RULE_PAYLOAD, "list_type": "whitelist", "created_by": "child"}
    response = await client.post(f"/api/v1/call-filter-rules/{child_id}", json=payload)
    assert response.status_code == 201
    assert response.json()["list_type"] == "whitelist"
    assert response.json()["created_by"] == "child"


@pytest.mark.asyncio
async def test_create_rule_blank_phone_returns_422(client: AsyncClient):
    payload = {**RULE_PAYLOAD, "phone_number": "   "}
    response = await client.post(f"/api/v1/call-filter-rules/{CHILD_ID}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_rule_invalid_list_type_returns_422(client: AsyncClient):
    payload = {**RULE_PAYLOAD, "list_type": "greylist"}
    response = await client.post(f"/api/v1/call-filter-rules/{CHILD_ID}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_rule_invalid_created_by_returns_422(client: AsyncClient):
    payload = {**RULE_PAYLOAD, "created_by": "admin"}
    response = await client.post(f"/api/v1/call-filter-rules/{CHILD_ID}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_rule_duplicate_returns_409(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(f"/api/v1/call-filter-rules/{child_id}", json=RULE_PAYLOAD)
    response = await client.post(f"/api/v1/call-filter-rules/{child_id}", json=RULE_PAYLOAD)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_create_rule_same_number_different_children_allowed(client: AsyncClient):
    child_a = str(uuid.uuid4())
    child_b = str(uuid.uuid4())
    r1 = await client.post(f"/api/v1/call-filter-rules/{child_a}", json=RULE_PAYLOAD)
    r2 = await client.post(f"/api/v1/call-filter-rules/{child_b}", json=RULE_PAYLOAD)
    assert r1.status_code == 201
    assert r2.status_code == 201


# ─── DELETE /call-filter-rules/{rule_id} ─────────────────────────────────────

@pytest.mark.asyncio
async def test_delete_rule_returns_204(client: AsyncClient):
    child_id = str(uuid.uuid4())
    create = await client.post(f"/api/v1/call-filter-rules/{child_id}", json=RULE_PAYLOAD)
    rule_id = create.json()["id"]

    response = await client.delete(f"/api/v1/call-filter-rules/{rule_id}")
    assert response.status_code == 204

    snapshot = await client.get(f"/api/v1/call-filter-rules/{child_id}")
    assert snapshot.json()["rules"] == []


@pytest.mark.asyncio
async def test_delete_rule_unknown_id_returns_404(client: AsyncClient):
    unknown_id = str(uuid.uuid4())
    response = await client.delete(f"/api/v1/call-filter-rules/{unknown_id}")
    assert response.status_code == 404


# ─── PUT /call-filter-settings/{child_id} ────────────────────────────────────

@pytest.mark.asyncio
async def test_put_settings_creates_and_returns_200(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.put(
        f"/api/v1/call-filter-settings/{child_id}", json=SETTINGS_PAYLOAD
    )
    assert response.status_code == 200
    data = response.json()
    assert data["child_id"] == child_id
    assert data["list_mode"] == "whitelist"
    assert data["block_hour_start"] == 21
    assert data["block_hour_end"] == 8
    assert data["updated_by"] == "parent"
    assert "updated_at" in data


@pytest.mark.asyncio
async def test_put_settings_upsert_overwrites(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.put(f"/api/v1/call-filter-settings/{child_id}", json=SETTINGS_PAYLOAD)
    response = await client.put(
        f"/api/v1/call-filter-settings/{child_id}",
        json={**SETTINGS_PAYLOAD, "list_mode": "blacklist", "updated_by": "child"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["list_mode"] == "blacklist"
    assert data["updated_by"] == "child"


@pytest.mark.asyncio
async def test_put_settings_invalid_list_mode_returns_422(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**SETTINGS_PAYLOAD, "list_mode": "greylist"}
    response = await client.put(f"/api/v1/call-filter-settings/{child_id}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_put_settings_default_hours_when_omitted(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {"list_mode": "blacklist", "updated_by": "parent"}
    response = await client.put(f"/api/v1/call-filter-settings/{child_id}", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["block_hour_start"] == 22
    assert data["block_hour_end"] == 7
