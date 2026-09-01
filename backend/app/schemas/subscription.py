"""
User Subscription Schemas (Pydantic v2)
Includes payload definitions for Subscription CRUD, Burn Rate aggregations, and Feature Seeding alerts.
"""

from datetime import date, datetime
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class SubscriptionBase(BaseModel):
    """Base fields for User Subscription"""
    service_name: str = Field(..., min_length=1, max_length=100)
    category: str = Field("Other", max_length=50)
    billing_cycle: str = Field("monthly", pattern="^(monthly|annual|weekly|quarterly)$")
    price: Decimal = Field(..., ge=0)
    currency: str = Field("TRY", min_length=3, max_length=3)
    start_date: Optional[date] = None
    next_billing_date: date
    trial_end_date: Optional[date] = None
    is_trial: bool = False
    alert_trial_24h: bool = True
    catalog_id: Optional[str] = None
    payment_method_hint: Optional[str] = Field(None, max_length=50)
    notes: Optional[str] = None
    status: str = Field("active", pattern="^(active|cancelled|paused|trial)$")


class SubscriptionCreate(SubscriptionBase):
    """Payload to create a new subscription"""
    pass


class SubscriptionUpdate(BaseModel):
    """Payload to update an existing subscription"""
    service_name: Optional[str] = Field(None, min_length=1, max_length=100)
    category: Optional[str] = Field(None, max_length=50)
    billing_cycle: Optional[str] = Field(None, pattern="^(monthly|annual|weekly|quarterly)$")
    price: Optional[Decimal] = Field(None, ge=0)
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    start_date: Optional[date] = None
    next_billing_date: Optional[date] = None
    trial_end_date: Optional[date] = None
    is_trial: Optional[bool] = None
    alert_trial_24h: Optional[bool] = None
    payment_method_hint: Optional[str] = Field(None, max_length=50)
    notes: Optional[str] = None
    status: Optional[str] = Field(None, pattern="^(active|cancelled|paused|trial)$")


class SubscriptionResponse(SubscriptionBase):
    """Response model for a user subscription"""
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    baseline_catalog_price: Optional[Decimal] = None
    is_price_hike_detected: bool = False
    price_hike_percentage: Optional[Decimal] = None
    created_at: datetime
    updated_at: datetime


class TrialAlertItem(BaseModel):
    """Imminent trial expiry alert model"""
    subscription_id: str
    service_name: str
    trial_end_date: date
    hours_remaining: int
    regular_price: Decimal
    currency: str
    alert_message: str


class PriceHikeAlertItem(BaseModel):
    """Silent price hike alert model"""
    subscription_id: str
    service_name: str
    user_price: Decimal
    catalog_reference_price: Decimal
    currency: str
    price_hike_percentage: Decimal
    alert_message: str


class BurnRateSummaryResponse(BaseModel):
    """Aggregated financial burn rate across active subscriptions"""
    base_currency: str
    total_monthly_burn_rate: Decimal
    total_annual_burn_rate: Decimal
    active_subscriptions_count: int
    trial_subscriptions_count: int
    price_hike_detected_count: int
    category_breakdown: dict[str, Decimal]
    upcoming_billing_7_days: List[SubscriptionResponse]
    trial_alerts: List[TrialAlertItem]
    price_hike_alerts: List[PriceHikeAlertItem]
