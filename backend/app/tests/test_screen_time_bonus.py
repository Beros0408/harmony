import uuid

import pytest
from httpx import AsyncClient

BONUS_URL  = "/api/v1/screen-time/bonus"
STATUS_URL = "/api/v1/screen-time/status"
LIMITS_URL = "/api/v1/screen-time/limits"
USAGE_URL  = "/api/v1/screen-time/usage"

_DATE = "2026-06-03"


def _child() -> str:
    return str(uuid.uuid4())


def _bonus_body(child_id: str, bonus_seconds: int, date: str = _DATE) -> dict:
    return {
        "child_id": child_id,
        "bonus_date": date,
        "bonus_seconds": bonus_seconds,
    }


def _global_limit(child_id: str, seconds: int) -> dict:
    return {"child_id": child_id, "scope": "global", "limit_seconds": seconds}


def _app_limit(child_id: str, package: str, seconds: int) -> dict:
    return {
        "child_id": child_id,
        "scope": "app",
        "package_name": package,
        "limit_seconds": seconds,
    }


def _usage(child_id: str, package: str, duration: int) -> dict:
    return {
        "child_id": child_id,
        "entries": [
            {"package_name": package, "duration_seconds": duration, "usage_date": _DATE}
        ],
    }


# ─── PUT /bonus ───────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_put_bonus_creates(client: AsyncClient):
    """Création d'un bonus : renvoie le bonus enregistré."""
    child_id = _child()
    resp = await client.put(BONUS_URL, json=_bonus_body(child_id, 1800))
    assert resp.status_code == 200
    data = resp.json()
    assert data["child_id"] == child_id
    assert data["bonus_seconds"] == 1800
    assert data["bonus_date"] == _DATE


@pytest.mark.asyncio
async def test_put_bonus_upserts(client: AsyncClient):
    """Deux PUT pour le même (child, date) → upsert : seule la dernière valeur."""
    child_id = _child()
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800))
    resp = await client.put(BONUS_URL, json=_bonus_body(child_id, 3600))
    assert resp.status_code == 200
    assert resp.json()["bonus_seconds"] == 3600


@pytest.mark.asyncio
async def test_put_bonus_zero_allowed(client: AsyncClient):
    """bonus_seconds=0 est valide (remise à zéro)."""
    resp = await client.put(BONUS_URL, json=_bonus_body(_child(), 0))
    assert resp.status_code == 200
    assert resp.json()["bonus_seconds"] == 0


@pytest.mark.asyncio
async def test_put_bonus_negative_rejected(client: AsyncClient):
    """bonus_seconds négatif → 422 Unprocessable Entity."""
    resp = await client.put(BONUS_URL, json=_bonus_body(_child(), -1))
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_put_bonus_different_dates_independent(client: AsyncClient):
    """Bonus sur deux dates différentes → deux entrées indépendantes."""
    child_id = _child()
    await client.put(BONUS_URL, json=_bonus_body(child_id, 900, "2026-06-03"))
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800, "2026-06-04"))

    r1 = await client.get(f"{BONUS_URL}/{child_id}", params={"date": "2026-06-03"})
    r2 = await client.get(f"{BONUS_URL}/{child_id}", params={"date": "2026-06-04"})
    assert r1.json()["bonus_seconds"] == 900
    assert r2.json()["bonus_seconds"] == 1800


# ─── GET /bonus/{child_id} ───────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_bonus_returns_value(client: AsyncClient):
    """GET retourne le bonus enregistré pour la date demandée."""
    child_id = _child()
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800))
    resp = await client.get(f"{BONUS_URL}/{child_id}", params={"date": _DATE})
    assert resp.status_code == 200
    assert resp.json()["bonus_seconds"] == 1800


@pytest.mark.asyncio
async def test_get_bonus_returns_zero_when_none(client: AsyncClient):
    """GET sur un enfant sans bonus → bonus_seconds=0 (pas 404)."""
    resp = await client.get(f"{BONUS_URL}/{_child()}", params={"date": _DATE})
    assert resp.status_code == 200
    assert resp.json()["bonus_seconds"] == 0


@pytest.mark.asyncio
async def test_get_bonus_returns_zero_for_other_date(client: AsyncClient):
    """Bonus défini J+1 → GET sur J renvoie 0."""
    child_id = _child()
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800, "2026-06-04"))
    resp = await client.get(f"{BONUS_URL}/{child_id}", params={"date": "2026-06-03"})
    assert resp.json()["bonus_seconds"] == 0


# ─── GET /status/{child_id} avec bonus ───────────────────────────────────────

@pytest.mark.asyncio
async def test_status_global_remaining_increases_with_bonus(client: AsyncClient):
    """Le bonus augmente remaining_seconds exactement de bonus_seconds."""
    child_id = _child()
    # Limite 2 h, usage 1h23 → remaining = 2h - 1h23 = 37 min sans bonus
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    await client.post(USAGE_URL, json=_usage(child_id, "com.app.a", 5000))
    # Bonus +30 min → remaining = 7200 + 1800 - 5000 = 4000
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    assert resp.status_code == 200
    item = resp.json()[0]
    assert item["scope"] == "global"
    assert item["bonus_seconds"] == 1800
    assert item["remaining_seconds"] == 4000
    assert item["exceeded"] is False


@pytest.mark.asyncio
async def test_status_global_exceeded_false_with_bonus(client: AsyncClient):
    """Quota dépassé sans bonus → exceeded redevient False si le bonus est suffisant."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 3600))
    await client.post(USAGE_URL, json=_usage(child_id, "com.app.a", 4000))
    # Sans bonus : 4000 > 3600 → exceeded=True
    # Bonus +1h → effective=7200, 4000 < 7200 → exceeded=False
    await client.put(BONUS_URL, json=_bonus_body(child_id, 3600))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    item = resp.json()[0]
    assert item["exceeded"] is False
    assert item["remaining_seconds"] == 3200


@pytest.mark.asyncio
async def test_status_global_still_exceeded_with_insufficient_bonus(client: AsyncClient):
    """Bonus insuffisant → exceeded reste True."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 3600))
    await client.post(USAGE_URL, json=_usage(child_id, "com.app.a", 5000))
    # Bonus +15 min = 900 s → effective = 4500, 5000 > 4500 → exceeded=True
    await client.put(BONUS_URL, json=_bonus_body(child_id, 900))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    item = resp.json()[0]
    assert item["exceeded"] is True
    assert item["remaining_seconds"] == 0


@pytest.mark.asyncio
async def test_status_app_limits_unaffected_by_bonus(client: AsyncClient):
    """Le bonus global ne modifie pas les limites par app."""
    child_id = _child()
    pkg = "com.youtube.android"
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 1800))
    await client.post(USAGE_URL, json=_usage(child_id, pkg, 2500))
    # Bonus +1h → ne doit pas affecter la limite app
    await client.put(BONUS_URL, json=_bonus_body(child_id, 3600))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    items = resp.json()
    app_item = next(i for i in items if i.get("package_name") == pkg)
    assert app_item["bonus_seconds"] == 0
    assert app_item["exceeded"] is True
    assert app_item["remaining_seconds"] == 0


@pytest.mark.asyncio
async def test_status_no_bonus_has_zero_bonus_seconds(client: AsyncClient):
    """Sans bonus, bonus_seconds=0 dans la réponse de statut."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    item = resp.json()[0]
    assert item["bonus_seconds"] == 0


@pytest.mark.asyncio
async def test_status_global_and_app_with_bonus(client: AsyncClient):
    """Avec limite globale + limite app + bonus : global tient compte du bonus, app non."""
    child_id = _child()
    pkg = "com.tiktok.android"
    await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 1800))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [
            {"package_name": pkg, "duration_seconds": 2000, "usage_date": _DATE},
            {"package_name": "com.other.app", "duration_seconds": 3000, "usage_date": _DATE},
        ],
    })
    await client.put(BONUS_URL, json=_bonus_body(child_id, 1800))

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": _DATE})
    items = resp.json()

    global_item = next(i for i in items if i["scope"] == "global")
    app_item    = next(i for i in items if i.get("package_name") == pkg)

    # Global : used=5000, effective=7200+1800=9000, remaining=4000
    assert global_item["bonus_seconds"] == 1800
    assert global_item["used_seconds"] == 5000
    assert global_item["remaining_seconds"] == 4000

    # App : used=2000, limit=1800, bonus=0 → exceeded
    assert app_item["bonus_seconds"] == 0
    assert app_item["exceeded"] is True
