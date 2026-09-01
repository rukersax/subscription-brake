"""
API v1 Router Aggregator
Combines Auth, Catalog, and Subscription endpoint modules.
"""

from fastapi import APIRouter
from app.api.v1.endpoints import auth, catalog, subscriptions

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(catalog.router)
api_router.include_router(subscriptions.router)
