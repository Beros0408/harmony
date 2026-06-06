import datetime
import uuid

import pytest
from httpx import AsyncClient


CHILD_ID = str(uuid.uuid4())


@pytest.mark.asyncio
async def test_upsert_creates_then_updates(client: AsyncClient):
    """PUT deux fois sur le même (child_id, date) → 1 seule ligne, steps mis à jour."""
    today = datetime.date.today().isoformat()

    # Création
    resp = await client.put(
        f"/api/v1/fitness/activity/{CHILD_ID}",
        json={"activity_date": today, "steps": 3000, "active_minutes": 30,
              "distance_meters": 2000, "source": "device"},
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["steps"] == 3000
    assert data["child_id"] == CHILD_ID
    assert data["activity_date"] == today
    first_id = data["id"]

    # Mise à jour — même date
    resp2 = await client.put(
        f"/api/v1/fitness/activity/{CHILD_ID}",
        json={"activity_date": today, "steps": 8500, "active_minutes": 60,
              "distance_meters": 6000, "source": "manual"},
    )
    assert resp2.status_code == 200, resp2.text
    data2 = resp2.json()
    assert data2["steps"] == 8500
    assert data2["source"] == "manual"
    # Même enregistrement (même id)
    assert data2["id"] == first_id


@pytest.mark.asyncio
async def test_get_activity_absent_returns_zeros(client: AsyncClient):
    """GET sur une date sans données → objet à zéros, pas une 404."""
    child = str(uuid.uuid4())
    date = "2000-01-01"

    resp = await client.get(f"/api/v1/fitness/activity/{child}", params={"date": date})
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["steps"] == 0
    assert data["active_minutes"] == 0
    assert data["distance_meters"] == 0
    assert data["activity_date"] == date
    assert data["child_id"] == child


@pytest.mark.asyncio
async def test_summary_total_and_average(client: AsyncClient):
    """3 PUT sur 3 jours consécutifs → summary total et moyenne corrects."""
    child = str(uuid.uuid4())
    today = datetime.date.today()

    steps_by_day = [4000, 6000, 8000]
    for i, steps in enumerate(steps_by_day):
        d = (today - datetime.timedelta(days=i)).isoformat()
        resp = await client.put(
            f"/api/v1/fitness/activity/{child}",
            json={"activity_date": d, "steps": steps, "active_minutes": 30,
                  "distance_meters": steps // 2, "source": "test"},
        )
        assert resp.status_code == 200, resp.text

    resp = await client.get(
        f"/api/v1/fitness/summary/{child}", params={"days": 7}
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()

    assert data["total_steps"] == 18000
    assert data["average_steps_per_day"] == 6000.0
    assert len(data["days"]) == 3
    assert data["child_id"] == child
