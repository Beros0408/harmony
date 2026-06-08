import uuid
import pytest
from httpx import AsyncClient

CHILD_ID = str(uuid.uuid4())

CONTACT_PAYLOAD = {
    "name": "Maman",
    "phone": "+33600000001",
    "created_by": "parent",
}


# ─── POST /{child_id} ────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_create_contact_returns_201(client: AsyncClient):
    response = await client.post(f"/api/v1/sos-contacts/{CHILD_ID}", json=CONTACT_PAYLOAD)
    assert response.status_code == 201
    data = response.json()
    assert data["child_id"] == CHILD_ID
    assert data["name"] == "Maman"
    assert data["phone"] == "+33600000001"
    assert data["created_by"] == "parent"
    assert data["sort_order"] == 0
    assert "id" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_create_contact_auto_sort_order_increments(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r1 = await client.post(f"/api/v1/sos-contacts/{child_id}", json=CONTACT_PAYLOAD)
    r2 = await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "Papa"})
    r3 = await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "Frère"})
    assert r1.json()["sort_order"] == 0
    assert r2.json()["sort_order"] == 1
    assert r3.json()["sort_order"] == 2


@pytest.mark.asyncio
async def test_create_contact_explicit_sort_order(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**CONTACT_PAYLOAD, "sort_order": 42}
    response = await client.post(f"/api/v1/sos-contacts/{child_id}", json=payload)
    assert response.status_code == 201
    assert response.json()["sort_order"] == 42


@pytest.mark.asyncio
async def test_create_contact_child_created_by(client: AsyncClient):
    child_id = str(uuid.uuid4())
    payload = {**CONTACT_PAYLOAD, "created_by": "child"}
    response = await client.post(f"/api/v1/sos-contacts/{child_id}", json=payload)
    assert response.status_code == 201
    assert response.json()["created_by"] == "child"


@pytest.mark.asyncio
async def test_create_contact_invalid_created_by_returns_422(client: AsyncClient):
    payload = {**CONTACT_PAYLOAD, "created_by": "admin"}
    response = await client.post(f"/api/v1/sos-contacts/{CHILD_ID}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_contact_blank_name_returns_422(client: AsyncClient):
    payload = {**CONTACT_PAYLOAD, "name": "   "}
    response = await client.post(f"/api/v1/sos-contacts/{CHILD_ID}", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_contact_blank_phone_returns_422(client: AsyncClient):
    payload = {**CONTACT_PAYLOAD, "phone": ""}
    response = await client.post(f"/api/v1/sos-contacts/{CHILD_ID}", json=payload)
    assert response.status_code == 422


# ─── GET /{child_id} ─────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_list_contacts_empty_for_unknown_child(client: AsyncClient):
    child_id = str(uuid.uuid4())
    response = await client.get(f"/api/v1/sos-contacts/{child_id}")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_contacts_ordered_by_sort_order(client: AsyncClient):
    child_id = str(uuid.uuid4())
    # Insertion dans l'ordre inverse pour vérifier le tri
    await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "C", "sort_order": 2})
    await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "A", "sort_order": 0})
    await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "B", "sort_order": 1})

    response = await client.get(f"/api/v1/sos-contacts/{child_id}")
    assert response.status_code == 200
    names = [c["name"] for c in response.json()]
    assert names == ["A", "B", "C"]


@pytest.mark.asyncio
async def test_list_contacts_isolation_between_children(client: AsyncClient):
    child_a = str(uuid.uuid4())
    child_b = str(uuid.uuid4())
    await client.post(f"/api/v1/sos-contacts/{child_a}", json=CONTACT_PAYLOAD)
    await client.post(f"/api/v1/sos-contacts/{child_a}", json={**CONTACT_PAYLOAD, "name": "Papa"})

    response = await client.get(f"/api/v1/sos-contacts/{child_b}")
    assert response.status_code == 200
    assert response.json() == []


# ─── DELETE /{contact_id} ────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_delete_contact_returns_204(client: AsyncClient):
    child_id = str(uuid.uuid4())
    create = await client.post(f"/api/v1/sos-contacts/{child_id}", json=CONTACT_PAYLOAD)
    contact_id = create.json()["id"]

    response = await client.delete(f"/api/v1/sos-contacts/{contact_id}")
    assert response.status_code == 204

    contacts = await client.get(f"/api/v1/sos-contacts/{child_id}")
    assert contacts.json() == []


@pytest.mark.asyncio
async def test_delete_contact_unknown_id_returns_404(client: AsyncClient):
    unknown_id = str(uuid.uuid4())
    response = await client.delete(f"/api/v1/sos-contacts/{unknown_id}")
    assert response.status_code == 404


# ─── PATCH /{contact_id} ─────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_patch_contact_sort_order(client: AsyncClient):
    child_id = str(uuid.uuid4())
    create = await client.post(f"/api/v1/sos-contacts/{child_id}", json=CONTACT_PAYLOAD)
    contact_id = create.json()["id"]

    response = await client.patch(
        f"/api/v1/sos-contacts/{contact_id}",
        json={"sort_order": 99},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["sort_order"] == 99
    assert data["id"] == contact_id
    assert data["name"] == "Maman"


@pytest.mark.asyncio
async def test_patch_contact_unknown_id_returns_404(client: AsyncClient):
    unknown_id = str(uuid.uuid4())
    response = await client.patch(
        f"/api/v1/sos-contacts/{unknown_id}",
        json={"sort_order": 0},
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_patch_reorder_reflects_in_list(client: AsyncClient):
    child_id = str(uuid.uuid4())
    r1 = await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "First"})
    r2 = await client.post(f"/api/v1/sos-contacts/{child_id}", json={**CONTACT_PAYLOAD, "name": "Second"})
    id1 = r1.json()["id"]
    id2 = r2.json()["id"]

    # Inverse : First passe en sort_order=10, Second en 0
    await client.patch(f"/api/v1/sos-contacts/{id1}", json={"sort_order": 10})
    await client.patch(f"/api/v1/sos-contacts/{id2}", json={"sort_order": 0})

    contacts = await client.get(f"/api/v1/sos-contacts/{child_id}")
    names = [c["name"] for c in contacts.json()]
    assert names == ["Second", "First"]
