import datetime
import uuid

import pytest
from httpx import AsyncClient

ANALYZE_URL = "/api/v1/wellbeing/analyze"
ALERTS_URL  = "/api/v1/wellbeing/alerts"
USAGE_URL   = "/api/v1/screen-time/usage"

# Date de référence fixe pour tous les tests (un mercredi — peu importe le jour réel)
_BASE_DATE = "2026-06-03"


def _child() -> str:
    return str(uuid.uuid4())


def _date_minus(base: str, days: int) -> str:
    d = datetime.date.fromisoformat(base)
    return str(d - datetime.timedelta(days=days))


async def _post_usage(client: AsyncClient, child_id: str, date: str, seconds: int) -> None:
    """Insère (ou met à jour) un usage journalier via l'endpoint existant."""
    resp = await client.post(
        USAGE_URL,
        json={
            "child_id": child_id,
            "entries": [
                {"package_name": "com.test.app", "duration_seconds": seconds, "usage_date": date}
            ],
        },
    )
    assert resp.status_code == 200


# ─── Cas 1 : historique insuffisant ──────────────────────────────────────────

@pytest.mark.asyncio
async def test_analyze_insufficient_history(client: AsyncClient) -> None:
    """Seulement 2 jours d'historique → reason='historique_insuffisant', aucun signal."""
    child_id = _child()
    # 2 jours d'historique (sous le seuil minimum de 3)
    await _post_usage(client, child_id, _date_minus(_BASE_DATE, 1), 3600)
    await _post_usage(client, child_id, _date_minus(_BASE_DATE, 2), 3600)
    # Usage du jour largement au-dessus, mais peu importe — l'historique est insuffisant
    await _post_usage(client, child_id, _BASE_DATE, 10_000)

    resp = await client.post(f"{ANALYZE_URL}/{child_id}", params={"date": _BASE_DATE})
    assert resp.status_code == 200
    data = resp.json()
    assert data["analyzed"] is True
    assert data["anomaly_detected"] is False
    assert data["signal"] is None
    assert data["reason"] == "historique_insuffisant"


# ─── Cas 2 : pas d'anomalie ───────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_analyze_no_anomaly(client: AsyncClient) -> None:
    """5 jours d'historique, usage_J = moyenne × 1.2 → sous le seuil, aucun signal."""
    child_id = _child()
    # Historique : 5 jours × 3600 s → moyenne = 3600 s
    for i in range(1, 6):
        await _post_usage(client, child_id, _date_minus(_BASE_DATE, i), 3_600)
    # usage_J = 4320 s = 3600 × 1.2  <  3600 × 1.5 → pas d'anomalie
    await _post_usage(client, child_id, _BASE_DATE, 4_320)

    resp = await client.post(f"{ANALYZE_URL}/{child_id}", params={"date": _BASE_DATE})
    assert resp.status_code == 200
    data = resp.json()
    assert data["analyzed"] is True
    assert data["anomaly_detected"] is False
    assert data["signal"] is None
    assert data["reason"] == "aucune_anomalie"


# ─── Cas 3 : anomalie détectée ────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_analyze_spike_detected(client: AsyncClient) -> None:
    """5 jours d'historique, usage_J = moyenne × 2 → signal + alerte créés."""
    child_id = _child()
    # Historique : 5 jours × 3600 s → moyenne = 3600 s
    for i in range(1, 6):
        await _post_usage(client, child_id, _date_minus(_BASE_DATE, i), 3_600)
    # usage_J = 7200 s = 3600 × 2  >  3600 × 1.5 → anomalie
    await _post_usage(client, child_id, _BASE_DATE, 7_200)

    resp = await client.post(f"{ANALYZE_URL}/{child_id}", params={"date": _BASE_DATE})
    assert resp.status_code == 200
    data = resp.json()
    assert data["analyzed"] is True
    assert data["anomaly_detected"] is True
    assert data["signal"] is not None

    signal = data["signal"]
    assert signal["signal_type"] == "usage_spike"
    assert signal["severity"] == "vigilance"
    assert signal["source"] == "screen_time"

    details = signal["details"]
    assert details["usage_jour_seconds"] == 7_200
    assert details["nb_jours_historique"] == 5
    assert abs(details["ratio"] - 2.0) < 0.01

    # L'alerte correspondante doit exister
    alerts_resp = await client.get(f"{ALERTS_URL}/{child_id}")
    assert alerts_resp.status_code == 200
    alerts = alerts_resp.json()
    assert len(alerts) == 1
    alert = alerts[0]
    assert alert["signal_id"] == signal["id"]
    assert alert["status"] == "sent"
    assert alert["title"] == "Temps d'écran en hausse"


# ─── Cas 4 : idempotence (double exécution) ───────────────────────────────────

@pytest.mark.asyncio
async def test_analyze_idempotent(client: AsyncClient) -> None:
    """Relancer l'analyse le même jour → 1 seul signal, 1 seule alerte."""
    child_id = _child()
    for i in range(1, 6):
        await _post_usage(client, child_id, _date_minus(_BASE_DATE, i), 3_600)
    await _post_usage(client, child_id, _BASE_DATE, 7_200)

    # Première analyse
    resp1 = await client.post(f"{ANALYZE_URL}/{child_id}", params={"date": _BASE_DATE})
    assert resp1.status_code == 200
    assert resp1.json()["anomaly_detected"] is True
    signal_id_1 = resp1.json()["signal"]["id"]

    # Deuxième analyse — même enfant, même date
    resp2 = await client.post(f"{ANALYZE_URL}/{child_id}", params={"date": _BASE_DATE})
    assert resp2.status_code == 200
    assert resp2.json()["anomaly_detected"] is True
    signal_id_2 = resp2.json()["signal"]["id"]

    # Même ID de signal → pas de doublon
    assert signal_id_1 == signal_id_2

    # Une seule alerte malgré deux appels
    alerts_resp = await client.get(f"{ALERTS_URL}/{child_id}")
    assert alerts_resp.status_code == 200
    assert len(alerts_resp.json()) == 1
