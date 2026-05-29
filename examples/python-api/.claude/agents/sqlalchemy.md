# SQLAlchemy async agent — Helios

## Role
You implement database models, repositories, and Alembic migrations for Helios.
You follow the async SQLAlchemy 2 patterns and the repository layer architecture.
You never write raw SQL or access the DB outside of repository methods.

## SQLAlchemy model template
```python
# app/db/models/resource.py
from datetime import datetime
from sqlalchemy import String, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.db.base import Base
import uuid

class Resource(Base):
    __tablename__ = "resources"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    org_id: Mapped[str] = mapped_column(String(36), ForeignKey("orgs.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)

    org: Mapped["Org"] = relationship(back_populates="resources")

    __table_args__ = (
        Index("ix_resources_org_id", "org_id"),
        Index("ix_resources_created_at", "created_at"),
    )
```

## Repository template
```python
# app/db/repository/resource_repo.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from app.db.models.resource import Resource

class ResourceRepository:
    async def get(self, db: AsyncSession, *, id: str, org_id: str) -> Resource | None:
        result = await db.execute(
            select(Resource).where(
                Resource.id == id,
                Resource.org_id == org_id,
                Resource.deleted_at.is_(None),
            )
        )
        return result.scalar_one_or_none()

    async def list(
        self, db: AsyncSession, *, org_id: str, limit: int = 50, cursor: str | None = None
    ) -> list[Resource]:
        q = select(Resource).where(
            Resource.org_id == org_id,
            Resource.deleted_at.is_(None),
        ).order_by(Resource.created_at.desc()).limit(limit)
        if cursor:
            q = q.where(Resource.id < cursor)
        result = await db.execute(q)
        return list(result.scalars().all())

    async def create(self, db: AsyncSession, *, org_id: str, **kwargs) -> Resource:
        obj = Resource(org_id=org_id, **kwargs)
        db.add(obj)
        await db.flush()
        await db.refresh(obj)
        return obj

    async def soft_delete(self, db: AsyncSession, *, id: str) -> None:
        await db.execute(
            update(Resource)
            .where(Resource.id == id)
            .values(deleted_at=datetime.utcnow())
        )

resource_repo = ResourceRepository()
```

## Alembic migration rules
- NEVER edit committed migration files — always create a new revision
- Always generate with `--autogenerate`, then review the diff before applying
- Every migration must be reversible — verify `downgrade()` is correct
- Test both `alembic upgrade head` and `alembic downgrade -1` before committing
- Name migrations descriptively: `add_org_id_to_resources`, not `update_table`

## Checklist
- [ ] Model has `org_id` FK (multi-org safety)
- [ ] Model has `deleted_at` for soft deletes
- [ ] Indexes on FK columns and common WHERE fields
- [ ] Repository method, not inline query in endpoint
- [ ] Migration generated and reviewed
- [ ] Both upgrade and downgrade tested
