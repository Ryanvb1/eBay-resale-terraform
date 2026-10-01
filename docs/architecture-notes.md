# Architecture notes

## Repository audit

- **Backend:** Python 3.11+ with FastAPI, Uvicorn, async SQLAlchemy, and HTTP-based marketplace scrapers.
- **Frontend:** React 18 and TypeScript built by Vite. It calls the backend through same-origin `/api` routes.
- **Startup:** local development uses `uvicorn backend.main:app --port 8011` plus `npm run dev`; the production container builds the frontend and serves it from the FastAPI process.
- **Configuration:** eBay client ID, client secret, redirect URI, eBay environment, database URL, CORS origins, and business settings can be supplied through environment variables. No working credentials are required to build or validate the project.
- **Database:** SQLite stores settings, categories, auctions, jobs, and opportunities. The AWS task mounts an encrypted EFS access point at `/data` so the database survives task replacement.
- **Ports:** Vite uses `5173` in development; FastAPI uses `8011` by default. The AWS load balancer listens on port 80 and forwards to `8011`.
- **Runtime model:** analysis is initiated as discrete background jobs, but the UI and job-status APIs require a long-running web process. AWS therefore uses a one-task ECS service behind an ALB. EventBridge optionally starts the same image with `python -m backend.scheduled_scan` for a single refresh and exit.
- **Deployment unit:** UI and API are deployed together in one image. No separate frontend hosting or reverse-proxy container is needed.
- **External services:** eBay Browse/Taxonomy APIs, Georgian marketplace sites, and the National Bank of Georgia exchange-rate endpoint are accessed over public HTTPS.

## Deliberate tradeoffs

SQLite on EFS is the smallest change that preserves current behavior and state. The ECS service is fixed at one task because SQLite is not intended for horizontally scaled concurrent writers. A future multi-user or high-volume version should move relational state to a managed database; that migration is intentionally outside this portfolio deployment.

The two public subnets avoid NAT gateway cost. Tasks receive public IPs for outbound API access, but their security group accepts application traffic only from the ALB. The ALB is HTTP-only because domains and certificates are outside scope; restrict `allowed_ingress_cidr` for a personal demo.

The upstream repository currently contains no license file. This project does not invent or change an upstream license; reuse remains subject to the upstream author's terms.
