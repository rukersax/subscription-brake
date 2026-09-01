"""
Subscription Catalog Schemas (Pydantic v2)
"""

from datetime import datetime
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class CatalogItemBase(BaseModel):
    """Base fields for Catalog Service"""
    name: str = Field(..., max_length=100)
    slug: str = Field(..., max_length=100)
    category: str = Field(..., max_length=50)
    tier_name: str = Field("Standard", max_length=50)
    default_billing_cycle: str = Field("monthly", pattern="^(monthly|annual|weekly|quarterly)$")
    price_try: Decimal = Field(..., ge=0)
    price_usd: Optional[Decimal] = Field(None, ge=0)
    price_eur: Optional[Decimal] = Field(None, ge=0)
    icon_name: str = Field("subscriptions", max_length=50)
    website_url: Optional[str] = Field(None, max_length=255)
    description: Optional[str] = None
    is_popular: bool = False
    is_active: bool = True


class CatalogItemCreate(CatalogItemBase):
    """Payload for creating a new catalog item"""
    pass


class CatalogItemResponse(CatalogItemBase):
    """Response representation for a catalog service item"""
    model_config = ConfigDict(from_attributes=True)

    id: str
    created_at: datetime
    updated_at: datetime


class CatalogListResponse(BaseModel):
    """List response with total count and grouped categories"""
    total: int
    items: List[CatalogItemResponse]
    categories: List[str]
