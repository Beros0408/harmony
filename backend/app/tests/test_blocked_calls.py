import uuid

import pytest
from httpx import AsyncClient

CHILD_ID = str(uuid.uuid4())

T1 = "2026-06-09T10:00:00Z"
T2 = "2026-06-09T11:00:00Z"
T3 = "2026-06-09T12:00:00Z"

CALL_1 = {"phone_number": "+33600000001", "blocked_at": T1, "list_mode": "blacklist", "latency_ms": 0}
CALL_2 = {"phone_number": "+33600000002", "blocked_at": T2, "list_mode": "blacklist", "latency_ms": 1}
CALL_3 = {"phone_number": "+33600000003", "blocked_at": T3}  # list_mode et latency_ms absents


# ─── POST /blocked-calls/{child_id} ──────────────────────────────────────────

@pytest.mark.asyncio
async def test_batch_upload_returns_inserted_count(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2]},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["inserted"] == 2
    assert data["skipped"] == 0


@pytest.mark.asyncio
async def test_batch_upload_single_call_without_optional_fields(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_3]},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["inserted"] == 1
    assert data["skipped"] == 0


@pytest.mark.asyncio
async def test_batch_upload_idempotent_re_upload(client: AsyncClient):
    child_id = str(uuid.uuid4())
    # premier upload
    r1 = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2]},
    )
    assert r1.json()["inserted"] == 2

    # re-upload identique : tout ignoré
    r2 = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2]},
    )
    assert r2.status_code == 200
    assert r2.json()["inserted"] == 0
    assert r2.json()["skipped"] == 2


@pytest.mark.asyncio
async def test_batch_upload_partial_re_upload(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1]},
    )
    # re-upload CALL_1 (doublon) + CALL_2 (nouveau)
    r = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2]},
    )
    assert r.status_code == 200
    assert r.json()["inserted"] == 1
    assert r.json()["skipped"] == 1


@pytest.mark.asyncio
async def test_batch_upload_same_number_different_timestamps_both_inserted(client: AsyncClient):
    child_id = str(uuid.uuid4())
    call_a = {"phone_number": "+33600000001", "blocked_at": T1}
    call_b = {"phone_number": "+33600000001", "blocked_at": T2}
    r = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [call_a, call_b]},
    )
    assert r.json()["inserted"] == 2


@pytest.mark.asyncio
async def test_batch_upload_invalid_list_mode_returns_422(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [{"phone_number": "+33600000001", "blocked_at": T1, "list_mode": "greylist"}]},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_batch_upload_blank_phone_returns_422(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [{"phone_number": "   ", "blocked_at": T1}]},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_batch_upload_empty_list_returns_422(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": []},
    )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_batch_upload_isolation_between_children(client: AsyncClient):
    child_a = str(uuid.uuid4())
    child_b = str(uuid.uuid4())
    await client.post(f"/api/v1/blocked-calls/{child_a}", json={"calls": [CALL_1]})

    r = await client.get(f"/api/v1/blocked-calls/{child_b}")
    assert r.json()["calls"] == []


# ─── GET /blocked-calls/{child_id} ───────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_blocked_calls_empty_for_unknown_child(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.get(f"/api/v1/blocked-calls/{child_id}")
    assert r.status_code == 200
    assert r.json()["calls"] == []


@pytest.mark.asyncio
async def test_get_blocked_calls_returns_all_fields(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1]},
    )
    r = await client.get(f"/api/v1/blocked-calls/{child_id}")
    assert r.status_code == 200
    calls = r.json()["calls"]
    assert len(calls) == 1
    c = calls[0]
    assert c["child_id"] == child_id
    assert c["phone_number"] == "+33600000001"
    assert c["list_mode"] == "blacklist"
    assert c["latency_ms"] == 0
    assert "id" in c
    assert "blocked_at" in c
    assert "created_at" in c


@pytest.mark.asyncio
async def test_get_blocked_calls_null_optional_fields(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_3]},
    )
    r = await client.get(f"/api/v1/blocked-calls/{child_id}")
    c = r.json()["calls"][0]
    assert c["list_mode"] is None
    assert c["latency_ms"] is None


@pytest.mark.asyncio
async def test_get_blocked_calls_ordered_blocked_at_desc(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_3, CALL_2]},
    )
    r = await client.get(f"/api/v1/blocked-calls/{child_id}")
    calls = r.json()["calls"]
    assert len(calls) == 3
    # T3 > T2 > T1
    assert calls[0]["phone_number"] == "+33600000003"
    assert calls[1]["phone_number"] == "+33600000002"
    assert calls[2]["phone_number"] == "+33600000001"


@pytest.mark.asyncio
async def test_get_blocked_calls_limit(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2, CALL_3]},
    )
    r = await client.get(f"/api/v1/blocked-calls/{child_id}?limit=2")
    assert r.status_code == 200
    assert len(r.json()["calls"]) == 2


@pytest.mark.asyncio
async def test_get_blocked_calls_offset(client: AsyncClient):
    child_id = str(uuid.uuid4())
    await client.post(
        f"/api/v1/blocked-calls/{child_id}",
        json={"calls": [CALL_1, CALL_2, CALL_3]},
    )
    # offset=2, limit=10 → ne renvoie que le plus ancien (T1)
    r = await client.get(f"/api/v1/blocked-calls/{child_id}?limit=10&offset=2")
    assert r.status_code == 200
    calls = r.json()["calls"]
    assert len(calls) == 1
    assert calls[0]["phone_number"] == "+33600000001"


@pytest.mark.asyncio
async def test_get_blocked_calls_limit_max_200(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.get(f"/api/v1/blocked-calls/{child_id}?limit=201")
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_get_blocked_calls_limit_min_1(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r = await client.get(f"/api/v1/blocked-calls/{child_id}?limit=0")
    assert r.status_code == 422
