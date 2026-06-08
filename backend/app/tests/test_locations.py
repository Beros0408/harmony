import datetime
import uuid

import pytest
from httpx import AsyncClient


CHILD_ID = str(uuid.uuid4())


@pytest.mark.asyncio
async def test_post_inserts_location(client: AsyncClient):
    """POST crée un point GPS et renvoie le point avec tous les champs."""
    resp = await client.post(
        f"/api/v1/locations/{CHILD_ID}",
        json={"latitude": 48.8566, "longitude": 2.3522, "accuracy": 10.5},
    )
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["child_id"] == CHILD_ID
    assert data["latitude"] == 48.8566
    assert data["longitude"] == 2.3522
    assert data["accuracy"] == 10.5
    assert "id" in data
    assert "recorded_at" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_get_latest_returns_most_recent(client: AsyncClient):
    """GET latest renvoie le point avec le recorded_at le plus récent."""
    child = str(uuid.uuid4())
    now = datetime.datetime.now(datetime.timezone.utc)
    older = (now - datetime.timedelta(hours=2)).isoformat()
    newer = now.isoformat()

    await client.post(
        f"/api/v1/locations/{child}",
        json={"latitude": 48.0, "longitude": 2.0, "recorded_at": older},
    )
    await client.post(
        f"/api/v1/locations/{child}",
        json={"latitude": 49.0, "longitude": 3.0, "recorded_at": newer},
    )

    resp = await client.get(f"/api/v1/locations/latest/{child}")
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["latitude"] == 49.0
    assert data["longitude"] == 3.0
    assert data["child_id"] == child


@pytest.mark.asyncio
async def test_get_history_ordered_and_limited(client: AsyncClient):
    """history?limit=3 renvoie 3 points sur 5, triés récents d'abord."""
    child = str(uuid.uuid4())
    base = datetime.datetime.now(datetime.timezone.utc)

    for i in range(5):
        recorded = (base - datetime.timedelta(hours=i)).isoformat()
        resp = await client.post(
            f"/api/v1/locations/{child}",
            json={"latitude": float(i), "longitude": float(i), "recorded_at": recorded},
        )
        assert resp.status_code == 201, resp.text

    resp = await client.get(f"/api/v1/locations/history/{child}", params={"limit": 3})
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["child_id"] == child
    assert len(data["points"]) == 3

    # Vérification ordre décroissant (recorded_at)
    times = [p["recorded_at"] for p in data["points"]]
    assert times == sorted(times, reverse=True)

    # Le premier point est le plus récent (i=0, lat=0.0)
    assert data["points"][0]["latitude"] == 0.0
