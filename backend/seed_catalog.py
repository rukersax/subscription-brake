"""
Subscription Catalog Seed Script
Pre-populates the database with 15 initial popular Turkish & global services with realistic TRY baseline prices.
Categories:
- Streaming Video & TV (Netflix, Exxen, BluTV, TOD / beIN Connect, Gain, Amazon Prime Video, Disney+)
- Music & Audio (Spotify, YouTube Premium, Storytel)
- AI & Productivity (ChatGPT Plus, iCloud+)
- Gaming (Xbox Game Pass Ultimate)
- Education & Sports (Duolingo Super, S Sport Plus)
"""

import asyncio
from decimal import Decimal
import sys
import os

# Add parent directory to sys.path to enable direct execution
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.db.base import Base
from app.db.session import engine, async_session_factory
from app.models.catalog import SubscriptionCatalog
from sqlalchemy import select

INITIAL_CATALOG_SERVICES = [
    {
        "name": "Netflix",
        "slug": "netflix-standard",
        "category": "Streaming Video",
        "tier_name": "Standard (HD)",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("229.99"),
        "price_usd": Decimal("15.49"),
        "price_eur": Decimal("13.49"),
        "icon_name": "movie",
        "website_url": "https://www.netflix.com",
        "description": "Stream unlimited movies, TV shows, and games on phone, tablet, laptop, and TV.",
        "is_popular": True,
    },
    {
        "name": "Spotify",
        "slug": "spotify-individual",
        "category": "Music & Audio",
        "tier_name": "Individual Premium",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("59.99"),
        "price_usd": Decimal("11.99"),
        "price_eur": Decimal("10.99"),
        "icon_name": "music_note",
        "website_url": "https://www.spotify.com",
        "description": "Ad-free music listening, offline playback, and unlimited skips.",
        "is_popular": True,
    },
    {
        "name": "YouTube Premium",
        "slug": "youtube-premium-individual",
        "category": "Music & Video",
        "tier_name": "Individual",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("79.99"),
        "price_usd": Decimal("13.99"),
        "price_eur": Decimal("12.99"),
        "icon_name": "smart_display",
        "website_url": "https://www.youtube.com/premium",
        "description": "Ad-free YouTube, background playback, and YouTube Music Premium included.",
        "is_popular": True,
    },
    {
        "name": "Exxen",
        "slug": "exxen-reklamsiz",
        "category": "Streaming Video",
        "tier_name": "Ad-Free (Reklamsız)",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("222.50"),
        "price_usd": Decimal("7.00"),
        "price_eur": Decimal("6.50"),
        "icon_name": "tv",
        "website_url": "https://www.exxen.com",
        "description": "Turkish exclusive series, talk shows, and reality entertainment without ads.",
        "is_popular": True,
    },
    {
        "name": "BluTV",
        "slug": "blutv-standart",
        "category": "Streaming Video",
        "tier_name": "Standard (Aylık)",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("139.90"),
        "price_usd": Decimal("4.50"),
        "price_eur": Decimal("4.20"),
        "icon_name": "live_tv",
        "website_url": "https://www.blutv.com",
        "description": "HBO Max originals, Turkish dramas, and discovery+ content in Turkey.",
        "is_popular": True,
    },
    {
        "name": "ChatGPT Plus",
        "slug": "chatgpt-plus",
        "category": "AI & Productivity",
        "tier_name": "Plus (GPT-4o)",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("649.99"),
        "price_usd": Decimal("20.00"),
        "price_eur": Decimal("22.00"),
        "icon_name": "psychology",
        "website_url": "https://chat.openai.com",
        "description": "Access to OpenAI GPT-4o, DALL-E image generation, advanced data analysis, and priority access.",
        "is_popular": True,
    },
    {
        "name": "Amazon Prime",
        "slug": "amazon-prime-tr",
        "category": "Shopping & Video",
        "tier_name": "Prime Membership",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("39.00"),
        "price_usd": Decimal("14.99"),
        "price_eur": Decimal("8.99"),
        "icon_name": "local_shipping",
        "website_url": "https://www.amazon.com.tr/prime",
        "description": "Fast & free shipping, Prime Video catalog, Prime Gaming perks, and exclusive deals.",
        "is_popular": True,
    },
    {
        "name": "Disney+",
        "slug": "disney-plus-standard",
        "category": "Streaming Video",
        "tier_name": "Standard (Aylık)",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("164.90"),
        "price_usd": Decimal("13.99"),
        "price_eur": Decimal("11.99"),
        "icon_name": "video_library",
        "website_url": "https://www.disneyplus.com",
        "description": "Disney, Pixar, Marvel, Star Wars, National Geographic, and Star content.",
        "is_popular": True,
    },
    {
        "name": "TOD (beIN Connect)",
        "slug": "tod-super-lig",
        "category": "Sports & TV",
        "tier_name": "Süper Lig Paketi",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("389.00"),
        "price_usd": Decimal("12.00"),
        "price_eur": Decimal("11.00"),
        "icon_name": "sports_soccer",
        "website_url": "https://www.todtv.com.tr",
        "description": "Live Trendyol Süper Lig football matches, Premier League, Formula 1, and entertainment.",
        "is_popular": True,
    },
    {
        "name": "Gain",
        "slug": "gain-premium",
        "category": "Streaming Video",
        "tier_name": "Premium",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("149.00"),
        "price_usd": Decimal("4.90"),
        "price_eur": Decimal("4.50"),
        "icon_name": "play_circle",
        "website_url": "https://www.gain.tv",
        "description": "Innovative Turkish original documentaries, short formats, and independent cinema.",
        "is_popular": False,
    },
    {
        "name": "iCloud+ (200GB)",
        "slug": "icloud-plus-200gb",
        "category": "Cloud Storage",
        "tier_name": "200 GB Tier",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("79.99"),
        "price_usd": Decimal("2.99"),
        "price_eur": Decimal("2.99"),
        "icon_name": "cloud",
        "website_url": "https://www.apple.com/icloud",
        "description": "Apple cloud storage for photos and backups with Private Relay and Hide My Email.",
        "is_popular": True,
    },
    {
        "name": "Xbox Game Pass Ultimate",
        "slug": "xbox-game-pass-ultimate",
        "category": "Gaming",
        "tier_name": "Ultimate",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("309.00"),
        "price_usd": Decimal("19.99"),
        "price_eur": Decimal("17.99"),
        "icon_name": "sports_esports",
        "website_url": "https://www.xbox.com/gamepass",
        "description": "Over 100 high-quality console and PC games, EA Play membership, and cloud gaming.",
        "is_popular": True,
    },
    {
        "name": "Duolingo Super",
        "slug": "duolingo-super-individual",
        "category": "Education",
        "tier_name": "Super Individual",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("129.99"),
        "price_usd": Decimal("12.99"),
        "price_eur": Decimal("11.99"),
        "icon_name": "school",
        "website_url": "https://www.duolingo.com",
        "description": "Ad-free language learning with unlimited hearts and personalized practice reviews.",
        "is_popular": False,
    },
    {
        "name": "S Sport Plus",
        "slug": "ssport-plus-aylik",
        "category": "Sports & TV",
        "tier_name": "Aylık Paket",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("99.99"),
        "price_usd": Decimal("3.20"),
        "price_eur": Decimal("3.00"),
        "icon_name": "sports_basketball",
        "website_url": "https://www.ssportplus.com",
        "description": "LaLiga, Serie A, EuroLeague basketball, UFC, and MotoGP live streaming.",
        "is_popular": False,
    },
    {
        "name": "Storytel",
        "slug": "storytel-unlimited",
        "category": "Music & Audio",
        "tier_name": "Unlimited Audiobooks",
        "default_billing_cycle": "monthly",
        "price_try": Decimal("149.99"),
        "price_usd": Decimal("9.99"),
        "price_eur": Decimal("8.99"),
        "icon_name": "auto_stories",
        "website_url": "https://www.storytel.com/tr",
        "description": "Over 500,000 Turkish and English audiobooks and e-books.",
        "is_popular": False,
    },
]


async def seed_database() -> None:
    """
    Seeds the central subscription catalog with 15 initial popular Turkish & global services.
    Idempotent: skips existing services based on unique slug.
    """
    print("=" * 60)
    print("SUBSCRIPTION BRAKE - CENTRAL CATALOG SEED SCRIPT")
    print("=" * 60)

    async with engine.begin() as conn:
        print("[1/3] Creating database tables if they do not exist...")
        await conn.run_sync(Base.metadata.create_all)
        print("      ✓ Tables initialized.")

    async with async_session_factory() as session:
        print("[2/3] Checking existing catalog entries...")
        inserted_count = 0
        skipped_count = 0

        for item_data in INITIAL_CATALOG_SERVICES:
            stmt = select(SubscriptionCatalog).where(SubscriptionCatalog.slug == item_data["slug"])
            result = await session.execute(stmt)
            existing = result.scalar_one_or_none()

            if existing is None:
                service = SubscriptionCatalog(**item_data)
                session.add(service)
                inserted_count += 1
                print(f"      + Added: {item_data['name']} ({item_data['tier_name']}) -> {item_data['price_try']} TRY")
            else:
                skipped_count += 1
                print(f"      = Exists (Skipped): {item_data['name']} ({item_data['slug']})")

        print("[3/3] Committing seed transaction to database...")
        await session.commit()
        print(f"\n✓ Seed Complete: {inserted_count} inserted, {skipped_count} skipped. Total: {len(INITIAL_CATALOG_SERVICES)} catalog items.")
        print("=" * 60)


if __name__ == "__main__":
    asyncio.run(seed_database())
