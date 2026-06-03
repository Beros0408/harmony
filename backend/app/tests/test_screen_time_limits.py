import uuid

import pytest
from httpx import AsyncClient

LIMITS_URL = "/api/v1/screen-time/limits"
STATUS_URL = "/api/v1/screen-time/status"
USAGE_URL  = "/api/v1/screen-time/usage"


def _child() -> str:
    return str(uuid.uuid4())


def _global_limit(child_id: str, seconds: int) -> dict:
    return {"child_id": child_id, "scope": "global", "limit_seconds": seconds}


def _app_limit(child_id: str, package: str, seconds: int) -> dict:
    return {
        "child_id": child_id,
        "scope": "app",
        "package_name": package,
        "limit_seconds": seconds,
    }


def _usage_entry(package: str, duration: int, date: str = "2026-06-03") -> dict:
    return {"package_name": package, "duration_seconds": duration, "usage_date": date}


# ─── PUT /limits ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_put_limit_global(client: AsyncClient):
    """Création d'une limite globale : scope=global, package_name=None."""
    child_id = _child()
    resp = await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    assert resp.status_code == 200
    data = resp.json()
    assert data["scope"] == "global"
    assert data["package_name"] is None
    assert data["limit_seconds"] == 7200
    assert data["child_id"] == child_id


@pytest.mark.asyncio
async def test_put_limit_app(client: AsyncClient):
    """Création d'une limite par application : scope=app, package_name renseigné."""
    child_id = _child()
    resp = await client.put(LIMITS_URL, json=_app_limit(child_id, "com.youtube.android", 3600))
    assert resp.status_code == 200
    data = resp.json()
    assert data["scope"] == "app"
    assert data["package_name"] == "com.youtube.android"
    assert data["limit_seconds"] == 3600


@pytest.mark.asyncio
async def test_put_limit_global_upsert(client: AsyncClient):
    """Deux PUT globaux pour le même enfant → upsert : une seule ligne avec la nouvelle valeur."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 3600))
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))

    resp = await client.get(f"{LIMITS_URL}/{child_id}")
    assert resp.status_code == 200
    limits = resp.json()
    globals_ = [l for l in limits if l["scope"] == "global"]
    assert len(globals_) == 1
    assert globals_[0]["limit_seconds"] == 7200


@pytest.mark.asyncio
async def test_put_limit_app_upsert(client: AsyncClient):
    """Deux PUT app pour le même (child, package) → upsert : une seule ligne."""
    child_id = _child()
    pkg = "com.tiktok.android"
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 1800))
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 3600))

    resp = await client.get(f"{LIMITS_URL}/{child_id}")
    assert resp.status_code == 200
    limits = resp.json()
    app_limits = [l for l in limits if l["package_name"] == pkg]
    assert len(app_limits) == 1
    assert app_limits[0]["limit_seconds"] == 3600


@pytest.mark.asyncio
async def test_put_limit_app_without_package_name_rejected(client: AsyncClient):
    """scope='app' sans package_name → 422 Unprocessable Entity."""
    resp = await client.put(
        LIMITS_URL,
        json={"child_id": _child(), "scope": "app", "limit_seconds": 3600},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_put_limit_invalid_scope_rejected(client: AsyncClient):
    """scope inconnu → 422 Unprocessable Entity."""
    resp = await client.put(
        LIMITS_URL,
        json={"child_id": _child(), "scope": "weekly", "limit_seconds": 3600},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_put_limit_negative_seconds_rejected(client: AsyncClient):
    """limit_seconds négatif → 422 Unprocessable Entity."""
    resp = await client.put(
        LIMITS_URL,
        json={"child_id": _child(), "scope": "global", "limit_seconds": -1},
    )
    assert resp.status_code == 422


# ─── GET /limits/{child_id} ──────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_limits_returns_all(client: AsyncClient):
    """GET retourne la limite globale + deux limites app pour le même enfant."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    await client.put(LIMITS_URL, json=_app_limit(child_id, "com.youtube.android", 3600))
    await client.put(LIMITS_URL, json=_app_limit(child_id, "com.tiktok.android", 1800))

    resp = await client.get(f"{LIMITS_URL}/{child_id}")
    assert resp.status_code == 200
    limits = resp.json()
    assert len(limits) == 3
    scopes = {l["scope"] for l in limits}
    assert "global" in scopes
    assert "app" in scopes


@pytest.mark.asyncio
async def test_get_limits_empty_for_new_child(client: AsyncClient):
    """GET sur un enfant sans limites → liste vide."""
    resp = await client.get(f"{LIMITS_URL}/{_child()}")
    assert resp.status_code == 200
    assert resp.json() == []


# ─── DELETE /limits/{limit_id} ───────────────────────────────────────────────

@pytest.mark.asyncio
async def test_delete_limit(client: AsyncClient):
    """DELETE d'une limite existante → 200 + la limite disparaît du GET."""
    child_id = _child()
    put_resp = await client.put(LIMITS_URL, json=_global_limit(child_id, 3600))
    limit_id = put_resp.json()["id"]

    del_resp = await client.delete(f"{LIMITS_URL}/{limit_id}")
    assert del_resp.status_code == 200
    assert del_resp.json()["deleted"] is True

    get_resp = await client.get(f"{LIMITS_URL}/{child_id}")
    assert get_resp.json() == []


@pytest.mark.asyncio
async def test_delete_nonexistent_limit(client: AsyncClient):
    """DELETE d'un UUID inexistant → 404 Not Found."""
    resp = await client.delete(f"{LIMITS_URL}/{uuid.uuid4()}")
    assert resp.status_code == 404


# ─── GET /status/{child_id} ──────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_status_global_not_exceeded(client: AsyncClient):
    """Usage < limite globale → remaining > 0, exceeded = False."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry("com.app.a", 3600)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    items = resp.json()
    assert len(items) == 1
    item = items[0]
    assert item["scope"] == "global"
    assert item["used_seconds"] == 3600
    assert item["remaining_seconds"] == 3600
    assert item["exceeded"] is False


@pytest.mark.asyncio
async def test_status_global_exceeded(client: AsyncClient):
    """Usage >= limite globale → remaining = 0, exceeded = True."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 3600))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [
            _usage_entry("com.app.a", 2000),
            _usage_entry("com.app.b", 2000),
        ],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    item = resp.json()[0]
    assert item["used_seconds"] == 4000
    assert item["remaining_seconds"] == 0
    assert item["exceeded"] is True


@pytest.mark.asyncio
async def test_status_app_exceeded(client: AsyncClient):
    """Usage app >= limite app → exceeded = True pour cette app."""
    child_id = _child()
    pkg = "com.youtube.android"
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 1800))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry(pkg, 3600)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    items = resp.json()
    app_items = [i for i in items if i["package_name"] == pkg]
    assert len(app_items) == 1
    assert app_items[0]["used_seconds"] == 3600
    assert app_items[0]["remaining_seconds"] == 0
    assert app_items[0]["exceeded"] is True


@pytest.mark.asyncio
async def test_status_no_limits_returns_empty(client: AsyncClient):
    """Aucune limite définie → statut retourne une liste vide."""
    resp = await client.get(f"{STATUS_URL}/{_child()}", params={"date": "2026-06-03"})
    assert resp.status_code == 200
    assert resp.json() == []
