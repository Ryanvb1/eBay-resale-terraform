"""Run one Modern Hunter refresh for an EventBridge-triggered ECS task."""

import asyncio
import uuid

from backend.database import create_tables
from backend.main import _maybe_sync_category_tree, _run_schema_migrations, _seed_default_settings
from backend.routers import modern
from backend.services.modern_tracking_advisor import maybe_run_advisor_before_refresh


async def run() -> int:
    await create_tables()
    await _run_schema_migrations()
    await _seed_default_settings()
    await _maybe_sync_category_tree()

    raw = await modern._get_all_settings()
    config = modern._parse_modern_settings(raw)
    await maybe_run_advisor_before_refresh()

    pool_size = max(config["max_categories_per_refresh"] * 4, config["max_categories_per_refresh"])
    categories = await modern._select_runtime_categories(pool_size)
    if not categories:
        print("[scheduled-scan] No tracked categories; nothing to scan.")
        return 0

    job_id = str(uuid.uuid4())
    modern._jobs[job_id] = {
        "status": "running",
        "progress": 0,
        "message": "Starting scheduled modern refresh...",
        "metrics": {},
        "scraper_status": {},
    }
    await modern._persist_job(job_id)
    await modern._run_modern_refresh(job_id, [c.ebay_category_id for c in categories], config)

    job = modern._jobs[job_id]
    print(f"[scheduled-scan] {job['status']}: {job['message']}")
    return 0 if job["status"] == "done" else 1


if __name__ == "__main__":
    raise SystemExit(asyncio.run(run()))
