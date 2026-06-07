import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


# ─── Helpers de seed ─────────────────────────────────────────────────────────

async def _seed_parent(db: AsyncSession, parent_id: str) -> None:
    await db.execute(
        text(
            "INSERT INTO public.profiles (id, role, full_name, email)"
            " VALUES (CAST(:id AS uuid), 'parent', 'Parent Test', :email)"
            " ON CONFLICT (id) DO NOTHING"
        ),
        {"id": parent_id, "email": f"parent_{parent_id[:8]}@harmony.local"},
    )


async def _seed_child_profile(db: AsyncSession, child_id: str) -> None:
    await db.execute(
        text(
            "INSERT INTO public.profiles (id, role, full_name, email)"
            " VALUES (CAST(:id AS uuid), 'child', 'Enfant Test', :email)"
            " ON CONFLICT (id) DO NOTHING"
        ),
        {"id": child_id, "email": f"child_{child_id[:8]}@harmony.local"},
    )


async def _count_consent(
    db: AsyncSession,
    parent_id: str,
    consent_type: str,
    child_id: str | None = None,
) -> int:
    if child_id is not None:
        r = await db.execute(
            text(
                "SELECT COUNT(*) FROM public.consent_records"
                " WHERE parent_id = CAST(:p AS uuid)"
                " AND child_id = CAST(:c AS uuid)"
                " AND consent_type = :t"
            ),
            {"p": parent_id, "c": child_id, "t": consent_type},
        )
    else:
        r = await db.execute(
            text(
                "SELECT COUNT(*) FROM public.consent_records"
                " WHERE parent_id = CAST(:p AS uuid)"
                " AND child_id IS NULL"
                " AND consent_type = :t"
            ),
            {"p": parent_id, "t": consent_type},
        )
    return r.scalar()


# ─── Tests upsert ─────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_upsert_creates_then_updates_child_consent(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """PUT crée un consentement enfant, puis le second PUT met à jour la même ligne (1 seule ligne)."""
    parent = str(uuid.uuid4())
    child = str(uuid.uuid4())
    await _seed_parent(db_session, parent)
    await _seed_child_profile(db_session, child)

    # Création initiale
    resp = await client.put("/api/v1/consent", json={
        "parent_id": parent,
        "child_id": child,
        "consent_type": "screen_time",
        "granted": True,
        "policy_version": "1.0",
    })
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["granted"] is True
    assert data["policy_version"] == "1.0"
    assert data["parent_id"] == parent
    assert data["child_id"] == child
    assert data["consent_type"] == "screen_time"

    # Mise à jour : revocation + nouvelle version
    resp2 = await client.put("/api/v1/consent", json={
        "parent_id": parent,
        "child_id": child,
        "consent_type": "screen_time",
        "granted": False,
        "policy_version": "1.1",
    })
    assert resp2.status_code == 200, resp2.text
    data2 = resp2.json()
    assert data2["granted"] is False
    assert data2["policy_version"] == "1.1"

    # Vérification directe : exactement 1 ligne en base
    count = await _count_consent(db_session, parent, "screen_time", child)
    assert count == 1, f"L'upsert devrait conserver exactement 1 ligne, trouvé {count}."


@pytest.mark.asyncio
async def test_upsert_global_consent_single_row(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """PUT sans child_id (consentement global) crée puis met à jour la même ligne."""
    parent = str(uuid.uuid4())
    await _seed_parent(db_session, parent)

    resp = await client.put("/api/v1/consent", json={
        "parent_id": parent,
        "consent_type": "data_collection",
        "granted": True,
        "policy_version": "1.0",
    })
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["child_id"] is None
    assert data["granted"] is True

    resp2 = await client.put("/api/v1/consent", json={
        "parent_id": parent,
        "consent_type": "data_collection",
        "granted": False,
        "policy_version": "1.1",
    })
    assert resp2.status_code == 200, resp2.text
    data2 = resp2.json()
    assert data2["granted"] is False
    assert data2["policy_version"] == "1.1"
    assert data2["child_id"] is None

    count = await _count_consent(db_session, parent, "data_collection")
    assert count == 1, f"L'upsert global devrait conserver exactement 1 ligne, trouvé {count}."


# ─── Test lecture liste ───────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_list_consents_returns_all_for_parent(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """GET /consent/{parent_id} retourne tous les consentements du parent, toutes variantes."""
    parent = str(uuid.uuid4())
    child = str(uuid.uuid4())
    await _seed_parent(db_session, parent)
    await _seed_child_profile(db_session, child)

    # 3 consentements liés à l'enfant + 1 global
    child_types = ["screen_time", "location", "fitness"]
    for ct in child_types:
        r = await client.put("/api/v1/consent", json={
            "parent_id": parent,
            "child_id": child,
            "consent_type": ct,
            "granted": True,
            "policy_version": "1.0",
        })
        assert r.status_code == 200, r.text

    r_global = await client.put("/api/v1/consent", json={
        "parent_id": parent,
        "consent_type": "data_collection",
        "granted": True,
        "policy_version": "1.0",
    })
    assert r_global.status_code == 200, r_global.text

    # Lecture
    resp = await client.get(f"/api/v1/consent/{parent}")
    assert resp.status_code == 200, resp.text
    rows = resp.json()
    assert len(rows) == 4, f"Attendu 4 consentements, trouvé {len(rows)}."

    returned_types = {r["consent_type"] for r in rows}
    assert returned_types == {*child_types, "data_collection"}

    for row in rows:
        assert row["parent_id"] == parent

    # Le consentement global a child_id = None
    globals_ = [r for r in rows if r["child_id"] is None]
    assert len(globals_) == 1
    assert globals_[0]["consent_type"] == "data_collection"


@pytest.mark.asyncio
async def test_list_consents_empty_for_unknown_parent(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """GET /consent/{parent_id} retourne une liste vide pour un parent sans consentements."""
    unknown = str(uuid.uuid4())
    resp = await client.get(f"/api/v1/consent/{unknown}")
    assert resp.status_code == 200, resp.text
    assert resp.json() == []
