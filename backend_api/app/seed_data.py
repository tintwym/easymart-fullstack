import sys
import os
import asyncio
from sqlalchemy import text

# ------------------------------------------------------------------
# 🟢 MAGIC FIX: Ensure Python finds your 'app' folder
# ------------------------------------------------------------------
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)
# ------------------------------------------------------------------

from app.db.database import AsyncSessionLocal


async def seed_categories():
    print("🌱 Seeding database with categories...")

    async with AsyncSessionLocal() as db:
        try:
            # We insert multiple categories at once.
            # IMPORTANT: The first ID matches your error log to fix the crash.
            await db.execute(text("""
                                  INSERT INTO categories (id, name, slug)
                                  VALUES ('d55d2fa3-a876-44be-a0f9-d6dc9f7c32ec', 'Electronics', 'electronics'),
                                         ('a1b2c3d4-e5f6-47a8-b9c0-d1e2f3a4b5c6', 'Phones', 'phones'),
                                         ('b2c3d4e5-f6a7-48b9-c0d1-e2f3a4b5c6d7', 'Kitchen', 'kitchen'),
                                         ('c3d4e5f6-a7b8-49c0-d1e2-f3a4b5c6d7e8', 'Books', 'books'),
                                         ('d4e5f6a7-b8c9-40d1-e2f3-a4b5c6d7e8f9', 'Fashion', 'fashion'),
                                         ('e5f6a7b8-c9d0-41e2-f3a4-b5c6d7e8f9a0', 'Sports', 'sports'),
                                         ('f6a7b8c9-d0e1-42f3-a4b5-c6d7e8f9a0b1', 'Toys', 'toys'),
                                         ('0a1b2c3d-4e5f-46a7-b8c9-d0e1f2a3b4c5', 'Beauty', 'beauty'),
                                         ('1a2b3c4d-5e6f-47a8-b9c0-d1e2f3a4b5c6', 'Home', 'home'),
                                         ('2a3b4c5d-6e7f-48a9-b0c1-d2e3f4a5b6c7', 'Automotive',
                                          'automotive') ON CONFLICT (id) DO NOTHING;
                                  """))

            await db.commit()
            print("✅ Success! All categories seeded.")

        except Exception as e:
            print(f"❌ Error: {e}")


if __name__ == "__main__":
    asyncio.run(seed_categories())