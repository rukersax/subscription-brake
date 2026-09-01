"""
Subscription Catalog Endpoints
Provides endpoints for browsing and searching predefined Turkish & global services.
"""

from typing import Annotated, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import distinct, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.catalog import SubscriptionCatalog
from app.schemas.catalog import CatalogItemCreate, CatalogItemResponse, CatalogListResponse

router = APIRouter(prefix="/catalog", tags=["Subscription Catalog"])


@router.get("/", response_model=CatalogListResponse)
async def list_catalog_services(
    db: Annotated[AsyncSession, Depends(get_db)],
    category: Optional[str] = Query(None, description="Filter by category"),
    search: Optional[str] = Query(None, description="Search by name or description"),
    popular_only: bool = Query(False, description="Filter popular services only"),
):
    """
    Retrieves the centralized catalog of predefined subscription services.
    Supports filtering by category, search keywords, and popularity.
    """
    stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.is_active.is_(True))

    if category:
        stmt = stmt.where(SubscriptionCatalog.category == category)
    if popular_only:
        stmt = stmt.where(SubscriptionCatalog.is_popular.is_(True))
    if search:
        search_pattern = f"%{search}%"
        stmt = stmt.where(
            (SubscriptionCatalog.name.ilike(search_pattern)) |
            (SubscriptionCatalog.description.ilike(search_pattern))
        )

    stmt = stmt.order_by(SubscriptionCatalog.is_popular.desc(), SubscriptionCatalog.name.asc())
    result = await db.execute(stmt)
    items = result.scalars().all()

    # Get distinct active categories
    cat_stmt = select(distinct(SubscriptionCatalog.category)).where(SubscriptionCatalog.is_active.is_(True))
    cat_result = await db.execute(cat_stmt)
    categories = [c for c in cat_result.scalars().all() if c]

    return {
        "total": len(items),
        "items": items,
        "categories": categories
    }


@router.get("/popular", response_model=List[CatalogItemResponse])
async def get_popular_services(
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Quick endpoint returning top popular Turkish & Global services for quick addition.
    """
    stmt = select(SubscriptionCatalog).where(
        SubscriptionCatalog.is_active.is_(True),
        SubscriptionCatalog.is_popular.is_(True)
    ).order_by(SubscriptionCatalog.name.asc())
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/{catalog_id}", response_model=CatalogItemResponse)
async def get_catalog_item(
    catalog_id: str,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieves detailed reference information for a specific catalog service.
    """
    stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.id == catalog_id)
    result = await db.execute(stmt)
    item = result.scalar_one_or_none()

    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Catalog service not found."
        )
    return item


@router.post("/", response_model=CatalogItemResponse, status_code=status.HTTP_201_CREATED)
async def create_catalog_service(
    payload: CatalogItemCreate,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Admin endpoint to register a new service into the central catalog.
    """
    # Check slug uniqueness
    stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.slug == payload.slug)
    result = await db.execute(stmt)
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A catalog item with this slug already exists."
        )

    item = SubscriptionCatalog(**payload.model_dump())
    db.add(item)
    await db.flush()
    await db.refresh(item)
    return item
