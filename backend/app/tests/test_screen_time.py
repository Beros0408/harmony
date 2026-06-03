import datetime
import uuid

import pytest
from httpx import AsyncClient

BASE_URL = "/api/v1/screen-time/usage"


def _child() -> str:
    return str(uuid.uuid4())


def _entry(
    package: str,
    duration: int,
    date: str = "2026-06-03",
    label: str | None = None,
    category: str | None = None,
) -> dict:
    return {
        "package_name": package,
        "app_label": label,
        "category": category,
        "duration_seconds": duration,
        "usage_date": date,
    }


# ─── POST /usage ─────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_post_usage_insert_batch(client: AsyncClient):
    """Insertion batch : 2 entrées nouvelles → processed == 2."""
    child_id = _child()
    payload = {
        "child_id": child_id,
        "entries": [
            _entry("com.instagram.android", 3600, label="Instagram", category="social"),
            _entry("com.google.android.youtube", 1800, label="YouTube", category="entertainment"),
        ],
    }
    resp = await client.post(BASE_URL, json=payload)
    assert resp.status_code == 200
    assert resp.json()["processed"] == 2


@pytest.mark.asyncio
async def test_post_usage_upsert_replaces_duration(client: AsyncClient):
    """Upsert : duration_seconds est remplacé (pas cumulé) sur même (child, package, date)."""
    child_id = _child()
    entry = _entry("com.instagram.android", 3600, label="Instagram", category="social")

    await client.post(BASE_URL, json={"child_id": child_id, "entries": [entry]})

    entry_updated = {**entry, "duration_seconds": 7200}
    resp = await client.post(BASE_URL, json={"child_id": child_id, "entries": [entry_updated]})
    assert resp.status_code == 200
    assert resp.json()["processed"] == 1

    get_resp = await client.get(f"{BASE_URL}/{child_id}", params={"date": "2026-06-03"})
    assert get_resp.status_code == 200
    records = get_resp.json()
    assert len(records) == 1
    assert records[0]["duration_seconds"] == 7200


@pytest.mark.asyncio
async def test_post_usage_empty_entries(client: AsyncClient):
    """Batch vide → processed == 0, pas d'erreur."""
    resp = await client.post(BASE_URL, json={"child_id": _child(), "entries": []})
    assert resp.status_code == 200
    assert resp.json()["processed"] == 0


# ─── GET /usage/{child_id} ────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_usage_by_date(client: AsyncClient):
    """Lecture par date précise, ordre décroissant par durée."""
    child_id = _child()
    await client.post(BASE_URL, json={
        "child_id": child_id,
        "entries": [
            _entry("com.app.a", 300, category="games"),
            _entry("com.app.b", 1200, category="social"),
        ],
    })

    resp = await client.get(f"{BASE_URL}/{child_id}", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    records = resp.json()
    assert len(records) == 2
    durations = [r["duration_seconds"] for r in records]
    assert durations == sorted(durations, reverse=True)


@pytest.mark.asyncio
async def test_get_usage_no_params_returns_today(client: AsyncClient):
    """Sans paramètre, retourne le jour courant (UTC)."""
    child_id = _child()
    today = datetime.date.today().isoformat()

    await client.post(BASE_URL, json={
        "child_id": child_id,
        "entries": [_entry("com.test.app", 60, date=today)],
    })

    resp = await client.get(f"{BASE_URL}/{child_id}")
    assert resp.status_code == 200
    records = resp.json()
    assert len(records) == 1
    assert records[0]["package_name"] == "com.test.app"


@pytest.mark.asyncio
async def test_get_usage_range(client: AsyncClient):
    """Plage from/to : seules les entrées dans l'intervalle sont retournées."""
    child_id = _child()
    await client.post(BASE_URL, json={
        "child_id": child_id,
        "entries": [
            _entry("com.app.a", 100, date="2026-06-01"),
            _entry("com.app.a", 200, date="2026-06-03"),
            _entry("com.app.a", 300, date="2026-06-10"),  # hors plage
        ],
    })

    resp = await client.get(
        f"{BASE_URL}/{child_id}",
        params={"from": "2026-06-01", "to": "2026-06-05"},
    )
    assert resp.status_code == 200
    records = resp.json()
    assert len(records) == 2
    assert all("2026-06-01" <= r["usage_date"] <= "2026-06-05" for r in records)


# ─── GET /usage/{child_id}/summary ───────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_summary_totals(client: AsyncClient):
    """Résumé : total_seconds correct, total_by_category cohérent."""
    child_id = _child()
    await client.post(BASE_URL, json={
        "child_id": child_id,
        "entries": [
            _entry("com.instagram.android", 3600, label="Instagram", category="social"),
            _entry("com.google.android.youtube", 1800, label="YouTube", category="entertainment"),
            _entry("com.tiktok.android", 900, label="TikTok", category="social"),
        ],
    })

    resp = await client.get(f"{BASE_URL}/{child_id}/summary", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["child_id"] == child_id
    assert data["usage_date"] == "2026-06-03"
    assert data["total_seconds"] == 6300
    assert data["total_by_category"]["social"] == 4500
    assert data["total_by_category"]["entertainment"] == 1800


@pytest.mark.asyncio
async def test_get_summary_top_apps_sorted(client: AsyncClient):
    """top_apps est ordonné par durée décroissante."""
    child_id = _child()
    await client.post(BASE_URL, json={
        "child_id": child_id,
        "entries": [
            _entry("com.app.a", 500),
            _entry("com.app.b", 2000),
            _entry("com.app.c", 100),
        ],
    })

    resp = await client.get(f"{BASE_URL}/{child_id}/summary", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    apps = resp.json()["top_apps"]
    assert len(apps) == 3
    assert apps[0]["package_name"] == "com.app.b"
    durations = [a["duration_seconds"] for a in apps]
    assert durations == sorted(durations, reverse=True)
