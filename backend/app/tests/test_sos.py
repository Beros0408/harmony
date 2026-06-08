import uuid
import pytest
from httpx import AsyncClient

CHILD_ID = str(uuid.uuid4())

TRIGGER_PAYLOAD = {
    "child_id": CHILD_ID,
    "latitude": 48.8566,
    "longitude": 2.3522,
    "accuracy": 10.0,
}


@pytest.mark.asyncio
async def test_sos_trigger_creates_event(client: AsyncClient):
    response = await client.post("/api/v1/sos/trigger", json=TRIGGER_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["child_id"] == CHILD_ID
    assert data["status"] == "active"
    assert data["latitude"] == TRIGGER_PAYLOAD["latitude"]
    assert data["longitude"] == TRIGGER_PAYLOAD["longitude"]
    assert data["accuracy"] == TRIGGER_PAYLOAD["accuracy"]
    assert "id" in data
    assert "triggered_at" in data


@pytest.mark.asyncio
async def test_sos_active_returns_events(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**TRIGGER_PAYLOAD, "child_id": child_id}
    await client.post("/api/v1/sos/trigger", json=payload)
    await client.post("/api/v1/sos/trigger", json=payload)

    response = await client.get(f"/api/v1/sos/active/{child_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["child_id"] == child_id
    assert len(data["events"]) == 2
    assert all(e["status"] == "active" for e in data["events"])


@pytest.mark.asyncio
async def test_sos_acknowledge_changes_status(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**TRIGGER_PAYLOAD, "child_id": child_id}

    trigger = await client.post("/api/v1/sos/trigger", json=payload)
    event_id = trigger.json()["id"]

    ack = await client.post(f"/api/v1/sos/{event_id}/acknowledge")
    assert ack.status_code == 200
    assert ack.json()["status"] == "acknowledged"

    active = await client.get(f"/api/v1/sos/active/{child_id}")
    assert active.json()["events"] == []
