---
name: create-fastapi-endpoint
description: >
  Use this skill when adding a new FastAPI endpoint to Helios.
  Covers Pydantic schemas, repository method, route handler,
  dependency injection, and pytest integration tests.
---

# Creating a FastAPI endpoint

## Step 1 — Define Pydantic schemas
```python
# app/api/v1/schemas/resource.py
from pydantic import BaseModel, Field
from datetime import datetime

class ResourceCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255, description="Resource name")
    description: str | None = Field(None, description="Optional description")

class ResourceUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None

class ResourceRead(BaseModel):
    id: str
    name: str
    description: str | None
    created_at: datetime

    model_config = {"from_attributes": True}   # Pydantic v2 ORM mode

class ResourceList(BaseModel):
    data: list[ResourceRead]
    meta: dict = Field(default_factory=lambda: {"total": 0, "cursor": None})
```

## Step 2 — Add repository method
```python
# app/db/repository/resource_repo.py
async def create(
    self, db: AsyncSession, *, org_id: str, data: ResourceCreate
) -> Resource:
    obj = Resource(org_id=org_id, **data.model_dump(exclude_none=True))
    db.add(obj)
    await db.flush()
    await db.refresh(obj)
    return obj
```

## Step 3 — Create the route handler
```python
# app/api/v1/endpoints/resources.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.deps import get_db, get_api_key
from app.db.models.api_key import APIKey
from app.db.repository.resource_repo import resource_repo
from app.api.v1.schemas.resource import ResourceCreate, ResourceRead, ResourceList

router = APIRouter(prefix="/resources", tags=["resources"])

@router.get("", response_model=ResourceList)
async def list_resources(
    limit: int = 50,
    cursor: str | None = None,
    db: AsyncSession = Depends(get_db),
    api_key: APIKey = Depends(get_api_key),
) -> ResourceList:
    """List all resources for the authenticated organisation."""
    items = await resource_repo.list(db, org_id=api_key.org_id, limit=limit, cursor=cursor)
    return ResourceList(
        data=items,
        meta={"total": len(items), "cursor": items[-1].id if items else None},
    )

@router.post("", response_model=ResourceRead, status_code=status.HTTP_201_CREATED)
async def create_resource(
    payload: ResourceCreate,
    db: AsyncSession = Depends(get_db),
    api_key: APIKey = Depends(get_api_key),
) -> ResourceRead:
    """Create a new resource."""
    resource = await resource_repo.create(db, org_id=api_key.org_id, data=payload)
    await db.commit()
    return ResourceRead.model_validate(resource)

@router.get("/{resource_id}", response_model=ResourceRead)
async def get_resource(
    resource_id: str,
    db: AsyncSession = Depends(get_db),
    api_key: APIKey = Depends(get_api_key),
) -> ResourceRead:
    """Get a resource by ID."""
    resource = await resource_repo.get(db, id=resource_id, org_id=api_key.org_id)
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")
    return ResourceRead.model_validate(resource)
```

## Step 4 — Register the router
```python
# app/api/v1/router.py
from app.api.v1.endpoints.resources import router as resources_router
api_router.include_router(resources_router)
```

## Step 5 — Write pytest integration tests
```python
# tests/api/test_resources.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_list_resources_empty(client: AsyncClient, auth_headers: dict):
    resp = await client.get("/api/v1/resources", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["data"] == []

@pytest.mark.asyncio
async def test_create_resource(client: AsyncClient, auth_headers: dict):
    resp = await client.post(
        "/api/v1/resources",
        headers=auth_headers,
        json={"name": "Test resource"},
    )
    assert resp.status_code == 201
    assert resp.json()["name"] == "Test resource"
    assert "id" in resp.json()

@pytest.mark.asyncio
async def test_create_resource_validation(client: AsyncClient, auth_headers: dict):
    resp = await client.post(
        "/api/v1/resources",
        headers=auth_headers,
        json={"name": ""},          # empty name should fail
    )
    assert resp.status_code == 422

@pytest.mark.asyncio
async def test_get_resource_not_found(client: AsyncClient, auth_headers: dict):
    resp = await client.get("/api/v1/resources/nonexistent", headers=auth_headers)
    assert resp.status_code == 404
```

## Checklist
- [ ] Pydantic schemas in `app/api/v1/schemas/`
- [ ] Repository method (not inline query)
- [ ] `org_id` filter on all queries
- [ ] Router registered in `app/api/v1/router.py`
- [ ] Docstring on each handler (shows in Swagger)
- [ ] Tests cover: 200 happy path, 404, 422 validation
- [ ] `make typecheck && make test` passes
