import uuid

import pytest
from httpx import AsyncClient

LIMITS_URL = "/api/v1/screen-time/limits"
STATUS_URL = "/api/v1/screen-time/status"
USAGE_URL  = "/api/v1/screen-time/usage"
BONUS_URL  = "/api/v1/screen-time/bonus"

# Dates de référence pour les tests
WEEKDAY_DATE = "2026-06-03"   # mercredi (weekday)
WEEKEND_DATE = "2026-06-06"   # samedi   (weekend)


def _child() -> str:
    return str(uuid.uuid4())


def _global_limit(child_id: str, seconds: int) -> dict:
    """Limite globale day_type='all' (rétrocompatible)."""
    return {"child_id": child_id, "scope": "global", "limit_seconds": seconds}


def _global_weekday_limit(child_id: str, seconds: int) -> dict:
    return {"child_id": child_id, "scope": "global", "limit_seconds": seconds, "day_type": "weekday"}


def _global_weekend_limit(child_id: str, seconds: int) -> dict:
    return {"child_id": child_id, "scope": "global", "limit_seconds": seconds, "day_type": "weekend"}


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
    """Création d'une limite globale day_type='all' : scope=global, package_name=None."""
    child_id = _child()
    resp = await client.put(LIMITS_URL, json=_global_limit(child_id, 7200))
    assert resp.status_code == 200
    data = resp.json()
    assert data["scope"] == "global"
    assert data["package_name"] is None
    assert data["limit_seconds"] == 7200
    assert data["child_id"] == child_id
    assert data["day_type"] == "all"


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


# ─── Sprint 5D-5 : quotas globaux différenciés semaine vs week-end ────────────

@pytest.mark.asyncio
async def test_put_limit_weekday_returns_day_type(client: AsyncClient) -> None:
    """PUT avec day_type='weekday' → day_type renvoyé dans la réponse."""
    child_id = _child()
    resp = await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))
    assert resp.status_code == 200
    data = resp.json()
    assert data["scope"] == "global"
    assert data["day_type"] == "weekday"
    assert data["limit_seconds"] == 7200


@pytest.mark.asyncio
async def test_put_limit_weekend_returns_day_type(client: AsyncClient) -> None:
    """PUT avec day_type='weekend' → day_type renvoyé dans la réponse."""
    child_id = _child()
    resp = await client.put(LIMITS_URL, json=_global_weekend_limit(child_id, 18000))
    assert resp.status_code == 200
    assert resp.json()["day_type"] == "weekend"


@pytest.mark.asyncio
async def test_put_invalid_day_type_rejected(client: AsyncClient) -> None:
    """day_type inconnu → 422."""
    resp = await client.put(
        LIMITS_URL,
        json={"child_id": _child(), "scope": "global", "limit_seconds": 3600, "day_type": "tuesday"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_status_selects_weekday_quota_on_weekday(client: AsyncClient) -> None:
    """Sur un jour de semaine, le quota weekday est préféré au quota 'all'."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))   # 2 h semaine
    await client.put(LIMITS_URL, json=_global_weekend_limit(child_id, 18000))  # 5 h week-end
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry("com.app.a", 3600, WEEKDAY_DATE)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKDAY_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    assert global_items[0]["limit_seconds"] == 7200   # quota weekday sélectionné
    assert global_items[0]["day_type"] == "weekday"


@pytest.mark.asyncio
async def test_status_selects_weekend_quota_on_weekend(client: AsyncClient) -> None:
    """Sur un samedi, le quota weekend est préféré."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))
    await client.put(LIMITS_URL, json=_global_weekend_limit(child_id, 18000))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry("com.app.a", 3600, WEEKEND_DATE)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKEND_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    assert global_items[0]["limit_seconds"] == 18000   # quota weekend sélectionné
    assert global_items[0]["day_type"] == "weekend"


@pytest.mark.asyncio
async def test_status_fallback_to_all_on_weekday(client: AsyncClient) -> None:
    """Seul quota 'all' défini → utilisé en fallback sur un jour de semaine."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 14400))  # day_type='all'
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry("com.app.a", 3600, WEEKDAY_DATE)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKDAY_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    assert global_items[0]["limit_seconds"] == 14400
    assert global_items[0]["day_type"] == "all"


@pytest.mark.asyncio
async def test_status_fallback_to_all_on_weekend(client: AsyncClient) -> None:
    """Seul quota 'all' défini → utilisé en fallback sur le week-end."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 14400))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry("com.app.a", 3600, WEEKEND_DATE)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKEND_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    assert global_items[0]["limit_seconds"] == 14400
    assert global_items[0]["day_type"] == "all"


@pytest.mark.asyncio
async def test_status_weekday_preferred_over_all_on_weekday(client: AsyncClient) -> None:
    """weekday + all définis → weekday est préféré sur un jour de semaine."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_limit(child_id, 14400))         # 'all'
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))  # 'weekday'

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKDAY_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    assert global_items[0]["limit_seconds"] == 7200   # weekday préféré
    assert global_items[0]["day_type"] == "weekday"


@pytest.mark.asyncio
async def test_status_app_limits_unaffected_by_day_type(client: AsyncClient) -> None:
    """Les limites par app sont indépendantes du jour de la semaine."""
    child_id = _child()
    pkg = "com.youtube.android"
    await client.put(LIMITS_URL, json=_app_limit(child_id, pkg, 3600))
    await client.post(USAGE_URL, json={
        "child_id": child_id,
        "entries": [_usage_entry(pkg, 1800, WEEKEND_DATE)],
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKEND_DATE})
    assert resp.status_code == 200
    app_items = [i for i in resp.json() if i.get("package_name") == pkg]
    assert len(app_items) == 1
    assert app_items[0]["limit_seconds"] == 3600
    assert app_items[0]["remaining_seconds"] == 1800


@pytest.mark.asyncio
async def test_status_weekday_quota_with_bonus(client: AsyncClient) -> None:
    """Le bonus s'applique correctement au quota weekday sélectionné."""
    child_id = _child()
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))  # 2 h
    # Bonus +30 min
    await client.put(BONUS_URL, json={
        "child_id": child_id,
        "bonus_date": WEEKDAY_DATE,
        "bonus_seconds": 1800,
    })

    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKDAY_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 1
    item = global_items[0]
    # remaining = limit + bonus - used = 7200 + 1800 - 0 = 9000
    assert item["bonus_seconds"] == 1800
    assert item["remaining_seconds"] == 9000
    assert item["exceeded"] is False


@pytest.mark.asyncio
async def test_weekday_and_weekend_upsert_independently(client: AsyncClient) -> None:
    """weekday et weekend s'upsertent indépendamment — deux lignes distinctes dans la BDD."""
    child_id = _child()
    # Crée puis met à jour le quota semaine
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 7200))
    await client.put(LIMITS_URL, json=_global_weekday_limit(child_id, 3600))  # upsert
    # Crée le quota week-end
    await client.put(LIMITS_URL, json=_global_weekend_limit(child_id, 18000))

    resp = await client.get(f"{LIMITS_URL}/{child_id}")
    assert resp.status_code == 200
    global_lims = [l for l in resp.json() if l["scope"] == "global"]
    assert len(global_lims) == 2
    weekday_lims = [l for l in global_lims if l["day_type"] == "weekday"]
    weekend_lims = [l for l in global_lims if l["day_type"] == "weekend"]
    assert len(weekday_lims) == 1
    assert weekday_lims[0]["limit_seconds"] == 3600   # valeur mise à jour
    assert len(weekend_lims) == 1
    assert weekend_lims[0]["limit_seconds"] == 18000


@pytest.mark.asyncio
async def test_status_no_global_when_no_quota_defined_for_day(client: AsyncClient) -> None:
    """Aucun quota défini pour le type de jour et aucun 'all' → pas de global dans le statut."""
    child_id = _child()
    # Seulement un quota weekend défini
    await client.put(LIMITS_URL, json=_global_weekend_limit(child_id, 18000))

    # Le statut sur un jour de semaine ne doit contenir aucun quota global
    resp = await client.get(f"{STATUS_URL}/{child_id}", params={"date": WEEKDAY_DATE})
    assert resp.status_code == 200
    global_items = [i for i in resp.json() if i["scope"] == "global"]
    assert len(global_items) == 0
