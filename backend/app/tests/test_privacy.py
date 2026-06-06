import datetime
import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


# ─── Helper de seed ──────────────────────────────────────────────────────────

async def _seed_child(db: AsyncSession, child_id: str, parent_id: str) -> None:
    """Insère une ligne représentative dans chaque table liée à child_id.

    Pas de commit — opérations dans la transaction de test, rollback automatique à la fin.
    """
    today = datetime.date.today()

    await db.execute(
        text(
            "INSERT INTO public.profiles (id, role, full_name, email)"
            " VALUES (CAST(:id AS uuid), 'child', :name, :email)"
        ),
        {"id": child_id, "name": f"Enfant {child_id[:8]}", "email": f"child_{child_id[:8]}@harmony.local"},
    )
    await db.execute(
        text(
            "INSERT INTO public.family_links (parent_id, child_id)"
            " VALUES (CAST(:parent_id AS uuid), CAST(:child_id AS uuid))"
        ),
        {"parent_id": parent_id, "child_id": child_id},
    )
    await db.execute(
        text(
            "INSERT INTO public.screen_time_usage"
            " (child_id, package_name, duration_seconds, usage_date)"
            " VALUES (CAST(:child_id AS uuid), 'com.test.app', 3600, :date)"
        ),
        {"child_id": child_id, "date": today},
    )
    await db.execute(
        text(
            "INSERT INTO public.screen_time_limits"
            " (child_id, scope, day_type, limit_seconds)"
            " VALUES (CAST(:child_id AS uuid), 'global', 'all', 7200)"
        ),
        {"child_id": child_id},
    )
    await db.execute(
        text(
            "INSERT INTO public.screen_time_bonus"
            " (child_id, bonus_date, bonus_seconds)"
            " VALUES (CAST(:child_id AS uuid), :date, 600)"
        ),
        {"child_id": child_id, "date": today},
    )
    await db.execute(
        text(
            "INSERT INTO public.fitness_activity"
            " (child_id, activity_date, steps, active_minutes, distance_meters, source)"
            " VALUES (CAST(:child_id AS uuid), :date, 5000, 40, 3500, 'device')"
        ),
        {"child_id": child_id, "date": today},
    )
    signal_id = str(uuid.uuid4())
    await db.execute(
        text(
            "INSERT INTO public.wellbeing_signals"
            " (id, child_id, signal_type, severity, source, signal_date)"
            " VALUES (CAST(:id AS uuid), CAST(:child_id AS uuid),"
            " 'usage_spike', 'vigilance', 'screen_time', :date)"
        ),
        {"id": signal_id, "child_id": child_id, "date": today},
    )
    await db.execute(
        text(
            "INSERT INTO public.wellbeing_alerts"
            " (child_id, signal_id, title, message, severity)"
            " VALUES (CAST(:child_id AS uuid), CAST(:signal_id AS uuid),"
            " 'Test alerte', 'Usage élevé détecté', 'vigilance')"
        ),
        {"child_id": child_id, "signal_id": signal_id},
    )
    await db.execute(
        text(
            "INSERT INTO public.lock_schedules"
            " (child_id, label, start_time, end_time, days_of_week)"
            " VALUES (CAST(:child_id AS uuid), 'Nuit', :start_t, :end_t, :days)"
        ),
        {
            "child_id": child_id,
            "start_t": datetime.time(22, 0),
            "end_t": datetime.time(7, 0),
            "days": [1, 2, 3, 4, 5],
        },
    )
    await db.execute(
        text(
            "INSERT INTO public.device_commands (child_id, command)"
            " VALUES (CAST(:child_id AS uuid), 'lock')"
        ),
        {"child_id": child_id},
    )
    await db.execute(
        text(
            "INSERT INTO public.content_filter (child_id, enabled)"
            " VALUES (CAST(:child_id AS uuid), true)"
            " ON CONFLICT (child_id) DO UPDATE SET enabled = true"
        ),
        {"child_id": child_id},
    )
    await db.execute(
        text(
            "INSERT INTO public.unlink_requests (child_id, parent_id, status)"
            " VALUES (CAST(:child_id AS uuid), CAST(:parent_id AS uuid), 'pending')"
        ),
        {"child_id": child_id, "parent_id": parent_id},
    )


# ─── Tests ────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_export_aggregates_all_tables(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """GET export rassemble bien les données de toutes les tables pour l'enfant."""
    child = str(uuid.uuid4())
    parent = str(uuid.uuid4())
    await _seed_child(db_session, child, parent)

    resp = await client.get(f"/api/v1/privacy/export/{child}")
    assert resp.status_code == 200, resp.text

    data = resp.json()
    assert data["child_id"] == child
    assert "export_date" in data

    # Profil
    assert data["profile"] is not None
    assert data["profile"]["id"] == child
    assert data["profile"]["role"] == "child"

    # Toutes les tables de liste ont exactement 1 entrée pour cet enfant
    for key in (
        "family_links",
        "screen_time_usage",
        "screen_time_limits",
        "screen_time_bonus",
        "fitness_activity",
        "wellbeing_signals",
        "wellbeing_alerts",
        "lock_schedules",
        "device_commands",
        "unlink_requests",
    ):
        assert len(data[key]) == 1, f"Clé '{key}' : attendu 1 entrée, got {len(data[key])}"
        assert data[key][0].get("child_id") == child or data[key][0].get("parent_id") is not None

    # Table scalaire content_filter
    assert data["content_filter"] is not None
    assert data["content_filter"]["enabled"] is True


@pytest.mark.asyncio
async def test_delete_erases_all_child_data(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """DELETE vide toutes les tables pour l'enfant ciblé et retourne le compte par table."""
    child = str(uuid.uuid4())
    parent = str(uuid.uuid4())
    await _seed_child(db_session, child, parent)

    resp = await client.delete(f"/api/v1/privacy/data/{child}")
    assert resp.status_code == 200, resp.text

    data = resp.json()
    assert data["deleted"] is True
    assert data["child_id"] == child
    assert "export_reminder" in data

    touched = data["tables_touched"]
    # Chaque table doit avoir eu exactement 1 ligne supprimée
    for table in (
        "profiles", "family_links", "screen_time_usage", "screen_time_limits",
        "screen_time_bonus", "fitness_activity", "wellbeing_signals",
        "wellbeing_alerts", "lock_schedules", "device_commands",
        "content_filter", "unlink_requests",
    ):
        assert touched[table] == 1, f"Table '{table}' : attendu rowcount=1, got {touched[table]}"

    # Vérification directe en DB — toutes les tables doivent être vides pour cet enfant
    checks = [
        ("profiles",             "id"),
        ("family_links",         "child_id"),
        ("screen_time_usage",    "child_id"),
        ("screen_time_limits",   "child_id"),
        ("screen_time_bonus",    "child_id"),
        ("fitness_activity",     "child_id"),
        ("wellbeing_signals",    "child_id"),
        ("wellbeing_alerts",     "child_id"),
        ("lock_schedules",       "child_id"),
        ("device_commands",      "child_id"),
        ("content_filter",       "child_id"),
        ("unlink_requests",      "child_id"),
    ]
    for table, col in checks:
        r = await db_session.execute(
            text(f"SELECT COUNT(*) FROM public.{table} WHERE {col} = CAST(:c AS uuid)"),
            {"c": child},
        )
        count = r.scalar()
        assert count == 0, f"Table '{table}' : {count} ligne(s) restante(s) après DELETE !"


@pytest.mark.asyncio
async def test_delete_does_not_touch_other_child(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """DELETE sur child_1 ne supprime AUCUNE donnée de child_2 (même parent)."""
    parent = str(uuid.uuid4())
    child1 = str(uuid.uuid4())
    child2 = str(uuid.uuid4())
    await _seed_child(db_session, child1, parent)
    await _seed_child(db_session, child2, parent)

    resp = await client.delete(f"/api/v1/privacy/data/{child1}")
    assert resp.status_code == 200, resp.text

    # child2 doit conserver l'intégralité de ses données
    checks = [
        ("profiles",          "id"),
        ("family_links",      "child_id"),
        ("screen_time_usage", "child_id"),
        ("fitness_activity",  "child_id"),
        ("wellbeing_signals", "child_id"),
        ("wellbeing_alerts",  "child_id"),
        ("lock_schedules",    "child_id"),
        ("device_commands",   "child_id"),
        ("content_filter",    "child_id"),
        ("unlink_requests",   "child_id"),
    ]
    for table, col in checks:
        r = await db_session.execute(
            text(f"SELECT COUNT(*) FROM public.{table} WHERE {col} = CAST(:c AS uuid)"),
            {"c": child2},
        )
        count = r.scalar()
        assert count >= 1, (
            f"Table '{table}' : child2 a perdu ses données après DELETE de child1 !"
        )


@pytest.mark.asyncio
async def test_delete_does_not_touch_parent_profile(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """DELETE sur l'enfant ne supprime pas le profil du parent."""
    parent = str(uuid.uuid4())
    child = str(uuid.uuid4())

    # Crée le profil parent explicitement
    await db_session.execute(
        text(
            "INSERT INTO public.profiles (id, role, full_name, email)"
            " VALUES (CAST(:id AS uuid), 'parent', 'Parent Test', :email)"
        ),
        {"id": parent, "email": f"parent_{parent[:8]}@harmony.local"},
    )

    await _seed_child(db_session, child, parent)

    resp = await client.delete(f"/api/v1/privacy/data/{child}")
    assert resp.status_code == 200, resp.text

    data = resp.json()
    assert data["tables_touched"]["profiles"] == 1  # seul le profil enfant supprimé

    # Le profil parent doit être intact
    r = await db_session.execute(
        text("SELECT COUNT(*) FROM public.profiles WHERE id = CAST(:id AS uuid)"),
        {"id": parent},
    )
    assert r.scalar() == 1, "Le profil parent a été supprimé par le DELETE enfant !"


# ─── Helpers purge ────────────────────────────────────────────────────────────

async def _seed_history(db: AsyncSession, child_id: str, days_ago: int) -> str:
    """Insère une ligne historique dans chaque table de purge, datée à J-days_ago.

    Retourne le signal_id inséré (nécessaire pour wellbeing_alerts).
    """
    past = datetime.date.today() - datetime.timedelta(days=days_ago)
    past_ts = datetime.datetime.combine(past, datetime.time.min)

    signal_id = str(uuid.uuid4())

    await db.execute(
        text(
            "INSERT INTO public.screen_time_usage"
            " (child_id, package_name, duration_seconds, usage_date)"
            " VALUES (CAST(:child_id AS uuid), :pkg, 1800, :d)"
            " ON CONFLICT (child_id, package_name, usage_date) DO NOTHING"
        ),
        {"child_id": child_id, "pkg": f"com.purge.{days_ago}", "d": past},
    )
    await db.execute(
        text(
            "INSERT INTO public.fitness_activity"
            " (child_id, activity_date, steps, active_minutes, distance_meters, source)"
            " VALUES (CAST(:child_id AS uuid), :d, 1000, 10, 700, 'device')"
            " ON CONFLICT (child_id, activity_date) DO NOTHING"
        ),
        {"child_id": child_id, "d": past},
    )
    await db.execute(
        text(
            "INSERT INTO public.wellbeing_signals"
            " (id, child_id, signal_type, severity, source, signal_date)"
            " VALUES (CAST(:id AS uuid), CAST(:child_id AS uuid),"
            " 'usage_spike', 'vigilance', 'screen_time', :d)"
            " ON CONFLICT (child_id, signal_type, signal_date) DO NOTHING"
        ),
        {"id": signal_id, "child_id": child_id, "d": past},
    )
    await db.execute(
        text(
            "INSERT INTO public.wellbeing_alerts"
            " (child_id, signal_id, title, message, severity, created_at)"
            " VALUES (CAST(:child_id AS uuid), CAST(:signal_id AS uuid),"
            " 'Alerte purge', 'Test purge', 'vigilance', :ts)"
        ),
        {"child_id": child_id, "signal_id": signal_id, "ts": past_ts},
    )
    await db.execute(
        text(
            "INSERT INTO public.device_commands (child_id, command, created_at)"
            " VALUES (CAST(:child_id AS uuid), 'lock', :ts)"
        ),
        {"child_id": child_id, "ts": past_ts},
    )
    return signal_id


async def _count_history(db: AsyncSession, child_id: str, days_ago: int) -> dict[str, int]:
    """Compte les lignes historiques pour child_id datées à J-days_ago."""
    past = datetime.date.today() - datetime.timedelta(days=days_ago)
    past_ts = datetime.datetime.combine(past, datetime.time.min)
    past_ts_end = past_ts + datetime.timedelta(seconds=1)

    counts: dict[str, int] = {}

    r = await db.execute(
        text(
            "SELECT COUNT(*) FROM public.screen_time_usage"
            " WHERE child_id = CAST(:c AS uuid) AND usage_date = :d"
        ),
        {"c": child_id, "d": past},
    )
    counts["screen_time_usage"] = r.scalar()

    r = await db.execute(
        text(
            "SELECT COUNT(*) FROM public.fitness_activity"
            " WHERE child_id = CAST(:c AS uuid) AND activity_date = :d"
        ),
        {"c": child_id, "d": past},
    )
    counts["fitness_activity"] = r.scalar()

    r = await db.execute(
        text(
            "SELECT COUNT(*) FROM public.wellbeing_signals"
            " WHERE child_id = CAST(:c AS uuid) AND signal_date = :d"
        ),
        {"c": child_id, "d": past},
    )
    counts["wellbeing_signals"] = r.scalar()

    r = await db.execute(
        text(
            "SELECT COUNT(*) FROM public.wellbeing_alerts"
            " WHERE child_id = CAST(:c AS uuid)"
            " AND created_at >= :ts AND created_at < :ts_end"
        ),
        {"c": child_id, "ts": past_ts, "ts_end": past_ts_end},
    )
    counts["wellbeing_alerts"] = r.scalar()

    r = await db.execute(
        text(
            "SELECT COUNT(*) FROM public.device_commands"
            " WHERE child_id = CAST(:c AS uuid)"
            " AND created_at >= :ts AND created_at < :ts_end"
        ),
        {"c": child_id, "ts": past_ts, "ts_end": past_ts_end},
    )
    counts["device_commands"] = r.scalar()

    return counts


# ─── Tests purge ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_purge_deletes_old_rows(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """POST /purge avec retention_days=90 supprime les lignes datées à J-91."""
    child = str(uuid.uuid4())
    await _seed_history(db_session, child, days_ago=91)

    resp = await client.post("/api/v1/privacy/purge?retention_days=90")
    assert resp.status_code == 200, resp.text

    data = resp.json()
    assert data["purged"] is True
    assert data["retention_days"] == 90
    assert "cutoff_date" in data

    # Les 5 tables historiques doivent avoir au moins 1 ligne supprimée
    for table in (
        "screen_time_usage", "fitness_activity", "wellbeing_signals",
        "wellbeing_alerts", "device_commands",
    ):
        assert data["rows_deleted"][table] >= 1, (
            f"Table '{table}' : aucune ligne supprimée alors que J-91 devrait être purgée"
        )

    # Vérification directe en base — plus aucune ligne J-91 pour cet enfant
    counts = await _count_history(db_session, child, days_ago=91)
    for table, n in counts.items():
        assert n == 0, f"Table '{table}' : {n} ligne(s) J-91 encore présente(s) après purge"


@pytest.mark.asyncio
async def test_purge_keeps_recent_rows(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """POST /purge avec retention_days=90 conserve les lignes datées à J-1."""
    child = str(uuid.uuid4())
    await _seed_history(db_session, child, days_ago=1)

    resp = await client.post("/api/v1/privacy/purge?retention_days=90")
    assert resp.status_code == 200, resp.text

    # Les lignes récentes (J-1) ne doivent PAS avoir été supprimées
    counts = await _count_history(db_session, child, days_ago=1)
    for table, n in counts.items():
        assert n >= 1, f"Table '{table}' : ligne J-1 supprimée à tort par la purge"


@pytest.mark.asyncio
async def test_purge_child_id_filter(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """POST /purge?child_id=X purge uniquement child1, pas child2."""
    child1 = str(uuid.uuid4())
    child2 = str(uuid.uuid4())
    await _seed_history(db_session, child1, days_ago=91)
    await _seed_history(db_session, child2, days_ago=91)

    resp = await client.post(
        f"/api/v1/privacy/purge?retention_days=90&child_id={child1}"
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["purged"] is True

    # child1 : lignes purgées
    counts1 = await _count_history(db_session, child1, days_ago=91)
    for table, n in counts1.items():
        assert n == 0, (
            f"Table '{table}' : child1 a encore {n} ligne(s) J-91 après purge ciblée"
        )

    # child2 : lignes intactes
    counts2 = await _count_history(db_session, child2, days_ago=91)
    for table, n in counts2.items():
        assert n >= 1, (
            f"Table '{table}' : child2 a perdu ses données lors de la purge de child1"
        )


@pytest.mark.asyncio
async def test_purge_does_not_touch_settings_table(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """POST /purge ne doit jamais supprimer des lignes de screen_time_limits."""
    child = str(uuid.uuid4())

    # Insère une limite (réglage courant, hors périmètre de purge)
    await db_session.execute(
        text(
            "INSERT INTO public.screen_time_limits"
            " (child_id, scope, day_type, limit_seconds)"
            " VALUES (CAST(:c AS uuid), 'global', 'all', 3600)"
        ),
        {"c": child},
    )

    resp = await client.post("/api/v1/privacy/purge?retention_days=0")
    assert resp.status_code == 200, resp.text

    # La table de réglages doit être intacte
    r = await db_session.execute(
        text(
            "SELECT COUNT(*) FROM public.screen_time_limits"
            " WHERE child_id = CAST(:c AS uuid)"
        ),
        {"c": child},
    )
    assert r.scalar() >= 1, (
        "screen_time_limits a été vidée par la purge — elle ne doit pas être touchée"
    )
