"""
User Subscription Endpoints & Financial Calculation Engine
Handles Subscription CRUD, Trial Expiry Alerts (24h), Price Hike Tracking, and Burn Rate aggregation.
"""

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from typing import Annotated, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.catalog import SubscriptionCatalog
from app.models.subscription import UserSubscription
from app.models.user import User
from app.schemas.subscription import (
    BurnRateSummaryResponse,
    PriceHikeAlertItem,
    SubscriptionCreate,
    SubscriptionResponse,
    SubscriptionUpdate,
    TrialAlertItem
)

router = APIRouter(prefix="/subscriptions", tags=["User Subscriptions & Burn Rate"])

# Static Exchange Rates for Mock Dev Mode (TRY Baseline)
MOCK_EXCHANGE_RATES_TO_TRY = {
    "TRY": Decimal("1.0"),
    "USD": Decimal("34.50"),
    "EUR": Decimal("37.80")
}


def normalize_to_currency(amount: Decimal, from_curr: str, to_curr: str) -> Decimal:
    """
    Normalizes monetary amounts between currencies.
    Uses static rate table when in development mode.
    """
    if from_curr == to_curr:
        return amount
    
    # Convert from source to TRY
    rate_from = MOCK_EXCHANGE_RATES_TO_TRY.get(from_curr.upper(), Decimal("1.0"))
    amount_in_try = amount * rate_from

    # Convert from TRY to target currency
    rate_to = MOCK_EXCHANGE_RATES_TO_TRY.get(to_curr.upper(), Decimal("1.0"))
    return (amount_in_try / rate_to).quantize(Decimal("0.01"))


def check_price_hike(
    user_price: Decimal,
    user_currency: str,
    catalog_item: Optional[SubscriptionCatalog]
) -> tuple[Optional[Decimal], bool, Optional[Decimal]]:
    """
    Compares user price with catalog baseline reference to detect silent price hikes.
    Returns: (baseline_catalog_price, is_price_hike_detected, price_hike_percentage)
    """
    if not catalog_item:
        return None, False, None

    # Get baseline price in matching currency
    if user_currency == "TRY":
        baseline = catalog_item.price_try
    elif user_currency == "USD" and catalog_item.price_usd:
        baseline = catalog_item.price_usd
    elif user_currency == "EUR" and catalog_item.price_eur:
        baseline = catalog_item.price_eur
    else:
        baseline = catalog_item.price_try

    if baseline and user_price > baseline:
        diff = user_price - baseline
        percentage = (diff / baseline) * Decimal("100.0")
        return baseline, True, percentage.quantize(Decimal("0.01"))
    
    return baseline, False, None


@router.get("/", response_model=List[SubscriptionResponse])
async def list_user_subscriptions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    status_filter: Optional[str] = Query(None, description="Filter by status (active, trial, paused, cancelled)"),
    category: Optional[str] = Query(None, description="Filter by category")
):
    """
    Lists all subscriptions for the authenticated user.
    """
    stmt = select(UserSubscription).where(UserSubscription.user_id == current_user.id)
    if status_filter:
        stmt = stmt.where(UserSubscription.status == status_filter)
    if category:
        stmt = stmt.where(UserSubscription.category == category)

    stmt = stmt.order_by(UserSubscription.next_billing_date.asc())
    result = await db.execute(stmt)
    return result.scalars().all()


@router.post("/", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_user_subscription(
    payload: SubscriptionCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Creates a new user subscription (either from catalog selection or custom manual entry).
    Automatically calculates price-hike flags against reference catalog baseline.
    """
    catalog_item = None
    if payload.catalog_id:
        c_stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.id == payload.catalog_id)
        c_res = await db.execute(c_stmt)
        catalog_item = c_res.scalar_one_or_none()

    baseline, is_hike, hike_pct = check_price_hike(
        user_price=payload.price,
        user_currency=payload.currency.upper(),
        catalog_item=catalog_item
    )

    subscription = UserSubscription(
        user_id=current_user.id,
        catalog_id=payload.catalog_id,
        service_name=payload.service_name,
        category=payload.category,
        billing_cycle=payload.billing_cycle,
        price=payload.price,
        currency=payload.currency.upper(),
        start_date=payload.start_date,
        next_billing_date=payload.next_billing_date,
        trial_end_date=payload.trial_end_date,
        is_trial=payload.is_trial,
        alert_trial_24h=payload.alert_trial_24h,
        baseline_catalog_price=baseline,
        is_price_hike_detected=is_hike,
        price_hike_percentage=hike_pct,
        payment_method_hint=payload.payment_method_hint,
        notes=payload.notes,
        status=payload.status
    )
    db.add(subscription)
    await db.flush()
    await db.refresh(subscription)
    return subscription


@router.get("/burn-rate", response_model=BurnRateSummaryResponse)
async def get_burn_rate_summary(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Financial Dashboard Aggregator:
    1. Computes total monthly & annual burn rates normalized to user's preferred currency (default TRY).
    2. Identifies active trial expiries within next 48h (Trial Expiry Guardian).
    3. Aggregates silent price-hike alerts.
    """
    user_currency = current_user.preferred_currency or "TRY"
    
    stmt = select(UserSubscription).where(
        UserSubscription.user_id == current_user.id,
        UserSubscription.status.in_(["active", "trial"])
    )
    result = await db.execute(stmt)
    subscriptions = result.scalars().all()

    total_monthly = Decimal("0.0")
    total_annual = Decimal("0.0")
    active_count = 0
    trial_count = 0
    price_hike_count = 0
    category_breakdown: dict[str, Decimal] = {}
    upcoming_7_days: List[UserSubscription] = []
    trial_alerts: List[TrialAlertItem] = []
    price_hike_alerts: List[PriceHikeAlertItem] = []

    today = date.today()
    in_7_days = today + timedelta(days=7)

    for sub in subscriptions:
        # Convert price to monthly normalized value
        if sub.billing_cycle == "annual":
            monthly_val = sub.price / Decimal("12.0")
            annual_val = sub.price
        elif sub.billing_cycle == "weekly":
            monthly_val = sub.price * Decimal("4.33")
            annual_val = sub.price * Decimal("52.0")
        elif sub.billing_cycle == "quarterly":
            monthly_val = sub.price / Decimal("3.0")
            annual_val = sub.price * Decimal("4.0")
        else:  # monthly
            monthly_val = sub.price
            annual_val = sub.price * Decimal("12.0")

        # Convert to user's base currency
        monthly_norm = normalize_to_currency(monthly_val, sub.currency, user_currency)
        annual_norm = normalize_to_currency(annual_val, sub.currency, user_currency)

        if not sub.is_trial:
            total_monthly += monthly_norm
            total_annual += annual_norm
            active_count += 1
            category_breakdown[sub.category] = category_breakdown.get(sub.category, Decimal("0.0")) + monthly_norm
        else:
            trial_count += 1

        # Check upcoming billing within 7 days
        if today <= sub.next_billing_date <= in_7_days:
            upcoming_7_days.append(sub)

        # Check Trial Expiry Guardian (Imminent within 48h)
        if sub.is_trial and sub.trial_end_date and sub.alert_trial_24h:
            delta_days = (sub.trial_end_date - today).days
            if 0 <= delta_days <= 2:
                hours_left = max(1, delta_days * 24)
                trial_alerts.append(TrialAlertItem(
                    subscription_id=sub.id,
                    service_name=sub.service_name,
                    trial_end_date=sub.trial_end_date,
                    hours_remaining=hours_left,
                    regular_price=sub.price,
                    currency=sub.currency,
                    alert_message=f"Trial for {sub.service_name} ends on {sub.trial_end_date}. Regular fee of {sub.price} {sub.currency} will be charged!"
                ))

        # Check Price Hike Alerts
        if sub.is_price_hike_detected and sub.baseline_catalog_price:
            price_hike_count += 1
            price_hike_alerts.append(PriceHikeAlertItem(
                subscription_id=sub.id,
                service_name=sub.service_name,
                user_price=sub.price,
                catalog_reference_price=sub.baseline_catalog_price,
                currency=sub.currency,
                price_hike_percentage=sub.price_hike_percentage or Decimal("0.0"),
                alert_message=f"{sub.service_name} price ({sub.price} {sub.currency}) is {sub.price_hike_percentage}% higher than reference catalog standard."
            ))

    return BurnRateSummaryResponse(
        base_currency=user_currency,
        total_monthly_burn_rate=total_monthly.quantize(Decimal("0.01")),
        total_annual_burn_rate=total_annual.quantize(Decimal("0.01")),
        active_subscriptions_count=active_count,
        trial_subscriptions_count=trial_count,
        price_hike_detected_count=price_hike_count,
        category_breakdown={k: v.quantize(Decimal("0.01")) for k, v in category_breakdown.items()},
        upcoming_billing_7_days=upcoming_7_days,
        trial_alerts=trial_alerts,
        price_hike_alerts=price_hike_alerts
    )


@router.get("/{subscription_id}", response_model=SubscriptionResponse)
async def get_subscription_details(
    subscription_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Retrieves specific subscription details.
    """
    stmt = select(UserSubscription).where(
        UserSubscription.id == subscription_id,
        UserSubscription.user_id == current_user.id
    )
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")
    return sub


@router.put("/{subscription_id}", response_model=SubscriptionResponse)
async def update_subscription(
    subscription_id: str,
    payload: SubscriptionUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Updates an existing user subscription.
    Recalculates price hike deviations if price or currency changes.
    """
    stmt = select(UserSubscription).where(
        UserSubscription.id == subscription_id,
        UserSubscription.user_id == current_user.id
    )
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")

    update_dict = payload.model_dump(exclude_unset=True)
    for field, value in update_dict.items():
        setattr(sub, field, value)

    # Re-evaluate price hike if price or currency changed
    if payload.price is not None or payload.currency is not None:
        catalog_item = None
        if sub.catalog_id:
            c_stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.id == sub.catalog_id)
            c_res = await db.execute(c_stmt)
            catalog_item = c_res.scalar_one_or_none()

        baseline, is_hike, hike_pct = check_price_hike(
            user_price=sub.price,
            user_currency=sub.currency,
            catalog_item=catalog_item
        )
        sub.baseline_catalog_price = baseline
        sub.is_price_hike_detected = is_hike
        sub.price_hike_percentage = hike_pct

    db.add(sub)
    await db.flush()
    await db.refresh(sub)
    return sub


@router.delete("/{subscription_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_subscription(
    subscription_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    """
    Deletes a user subscription record.
    """
    stmt = select(UserSubscription).where(
        UserSubscription.id == subscription_id,
        UserSubscription.user_id == current_user.id
    )
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")

    await db.delete(sub)
    return None
