# Throttle Client Portal

An organization-aware client-agency portal that gives businesses a unified real-time dashboard for advertising performance, task approvals, file deliverables, and direct communication.

![React](https://img.shields.io/badge/Frontend-React_19_%2B_Vite-61DAFB?logo=react)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL_Scoped-4169E1?logo=postgresql)
![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## Overview

Traditional client-agency communication is fragmented across WhatsApp groups, email threads, Google Drive links, spreadsheets, and Meta Ads Manager dashboards.

**Throttle Client Portal** consolidates these workflows into a single organization-isolated client portal where clients can:
- View ongoing advertising performance and historical ROAS metrics.
- Review and approve agency deliverables with structured feedback loops.
- Track task progress, priority levels, and upcoming due dates.
- Communicate directly with agency account managers in an encrypted messaging hub.

---

## Key Features

### Implemented Features

- **Multi-Tenant Organization Isolation:** Every entity (tasks, messages, ad metrics) is strictly scoped to the authenticated user's `organization_id` in PostgreSQL.
- **Tasks & Approvals Engine:** 
  - Priority indicators (`HIGH`, `MEDIUM`, `LOW`) and status tracking (`READY_FOR_REVIEW`, `PENDING_APPROVAL`, `COMPLETED`).
  - Interactive "+ Create Task" modal for client deliverables and agency assignments.
  - Approve & Change-Request workflow buttons with structured reviewer notes.
  - Timestamped task comment threads.
- **Meta Marketing Analytics (v26.0):**
  - Direct integration with Meta Graph API `v26.0`.
  - Ingests daily spend, impressions, CTR, CPC, conversions, and ROAS.
  - Interactive time-series visual charts and date range filtering (7d, 30d, custom).
  - Secure credential storage using Fernet token encryption at rest.
  - Automatic demo fallback mode for local development without live Meta Developer credentials.
- **Encrypted Messaging Hub:** Organization-aware chat interface for client-agency discussions.
- **JWT Dual-Token Authentication:** `bcrypt` password hashing via `passlib`, with 30-minute access tokens and 7-day refresh token rotation.

### Planned Features

- **Google Drive Integration:** Automatic sync of client creative collateral.
- **Push & Email Notifications:** Automated alerts on task status changes.
- **White-Label Custom Branding:** Custom tenant subdomains and logo uploads.

---

## Tech Stack

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Frontend Web** | React 19, Vite 6, Recharts, Lucide Icons | Single-page app with light-theme glassmorphism |
| **Frontend Mobile** | Flutter 3.x, Provider | Cross-platform client companion app |
| **Backend API** | Python 3.12, FastAPI, Uvicorn | Async REST API engine |
| **Database** | PostgreSQL, Async SQLAlchemy 2.0, asyncpg | Scoped multi-tenant schema with Alembic migrations |
| **Security** | PyJWT, Passlib (Bcrypt), Cryptography (Fernet) | Token-based auth & token encryption |
| **External API** | Meta Graph API (v26.0) | Ad insights & campaign metrics ingestion |

---

## Project Structure

```text
throttle-client-portal/
├── README.md                 # Main recruiter-facing documentation
├── LICENSE                   # MIT License terms
├── .gitignore                # Multi-stack git ignore patterns
├── .env.example              # Environment variable template
├── CONTRIBUTING.md           # Developer contribution guidelines
├── SECURITY.md               # Vulnerability reporting & security architecture
├── CHANGELOG.md              # Semantic version release notes
│
├── frontend/                 # React 19 + Vite web portal application
│   ├── src/
│   │   ├── api/              # Axios API client with auth interceptors
│   │   ├── components/       # Header, Sidebar, MetaModal components
│   │   ├── context/          # AuthContext provider
│   │   └── pages/            # Dashboard, Tasks, Chat, Insights, Profile, Login
│   ├── package.json
│   └── vercel.json           # SPA rewrite configuration
│
├── backend/                  # Python FastAPI REST API backend
│   ├── app/
│   │   ├── api/v1/           # API routes (auth, tasks, analytics, meta, chat)
│   │   ├── core/             # Database session, config, JWT security
│   │   ├── models/           # Async SQLAlchemy database entities
│   │   ├── schemas/          # Pydantic validation models
│   │   └── services/         # Meta Graph API synchronization services
│   ├── scripts/              # Database initialization & seed scripts
│   ├── requirements.txt      # Python dependencies
│   └── pytest.ini            # Pytest configuration
│
├── mobile/                   # Flutter cross-platform client mobile app
├── docs/                     # Detailed technical documentation
│   ├── architecture.md       # Layered system architecture & diagrams
│   ├── multi-tenancy.md      # Tenant isolation & security model
│   ├── authentication.md     # JWT lifecycle & role-based access control
│   ├── api.md                # Endpoint reference catalog
│   ├── database.md           # Entity relationship diagram & schema details
│   ├── meta-integration.md   # Meta Graph API OAuth & token encryption
│   └── deployment.md         # Production deployment guide
└── screenshots/              # UI screenshots & visual assets
```

---

## Local Development Setup

### Prerequisites
- **Node.js**: v20+ and `npm`
- **Python**: v3.12+
- **PostgreSQL**: v14+ (running locally or via Docker)

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/throttle-client-portal.git
cd throttle-client-portal
```

---

### Step 2: Setup Database
Start local PostgreSQL service and create the database user:
```bash
psql -U postgres -c "CREATE USER throttle WITH PASSWORD 'throttle123';"
psql -U postgres -c "CREATE DATABASE throttle OWNER throttle;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE throttle TO throttle;"
```

---

### Step 3: Setup & Run Backend (FastAPI)
```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Seed test database (Creates demo orgs & accounts)
python scripts/seed_db.py

# Start FastAPI dev server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
The FastAPI backend will run at **`http://localhost:8000`** (Swagger docs available at `http://localhost:8000/docs`).

---

### Step 4: Setup & Run Frontend (React / Vite)
In a new terminal window:
```bash
cd frontend

# Install dependencies
npm install

# Start Vite dev server
npm run dev
```
The Web App will run at **`http://localhost:3000`**.

---

## Default Test Credentials

| Role | Email | Password | Scope |
| :--- | :--- | :--- | :--- |
| **Throttle Admin** | `admin@throttle.agency` | `admin123` | Multi-Tenant Agency Admin |
| **Client Admin (BLUEFORCE)** | `raj@blueforce.com` | `password123` | BLUEFORCE Tenant |
| **Client Admin (Acme Corp)** | `john@acme.com` | `password123` | Acme Corp Tenant |

---

## Testing & Build Verification

### Validate Frontend Build
```bash
cd frontend
npm run build
```

### Run Backend Tests
```bash
cd backend
pytest
```

---

## Security

Please review [`SECURITY.md`](SECURITY.md) for details on secret management, tenant isolation, and vulnerability disclosure procedures.

---

## Roadmap

- [x] Multi-Tenant Organization Scope (`organization_id`)
- [x] JWT Dual-Token Authentication
- [x] Task & Approval Workflow Engine with Priority Tags
- [x] Meta Marketing API (`v26.0`) Analytics & ROAS Charts
- [x] Fernet Token Encryption at Rest
- [x] Encrypted Client-Agency Chat Interface
- [ ] Google Drive Collateral Integration *(Planned)*
- [ ] Push & Email Activity Notifications *(Planned)*

---

## Documentation Index

- [Architecture Overview](docs/architecture.md)
- [Multi-Tenancy & Security](docs/multi-tenancy.md)
- [Authentication & RBAC](docs/authentication.md)
- [API Reference Catalog](docs/api.md)
- [Database Schema & ERD](docs/database.md)
- [Meta Graph API Integration](docs/meta-integration.md)
- [Production Deployment Guide](docs/deployment.md)

---

## License

This project is licensed under the [MIT License](LICENSE).
