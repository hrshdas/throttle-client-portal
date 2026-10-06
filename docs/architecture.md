# System Architecture Documentation

## Overview

**Throttle Client Portal** is built as a multi-tenant client-agency application. It separates frontend client presentation, backend API business logic, and tenant-isolated database storage.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Client Tier (Frontend)                       │
│  React 19 + Vite (Web Portal)   /   Flutter 3.x (Mobile App)   │
└─────────────────────────────────────────────────────────────────┘
                                │
                        HTTPS / REST APIs
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Application API Tier                         │
│                  FastAPI (Python 3.12 Engine)                   │
│   ┌───────────────────┬───────────────────┬─────────────────┐   │
│   │ Auth & JWT Middleware│ Organization Scope│ CORS / Security │   │
│   └───────────────────┴───────────────────┴─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
            │                                         │
    SQLAlchemy (Async)                         HTTPX (Async)
            ▼                                         ▼
┌─────────────────────────┐               ┌───────────────────────┐
│     Database Tier       │               │ External Services     │
│ PostgreSQL (Scoped DB)  │               │ Meta Graph API v26.0  │
└─────────────────────────┘               └───────────────────────┘
```

---

## Architectural Principles

### 1. Multi-Tenant Scoped Isolation
Every core entity in the system (`User`, `Project`, `Task`, `Message`, `MetaConnection`, `MetaDailyInsight`) is linked to an `organization_id`. Database queries strictly execute within the scope of the authenticated user's organization.

### 2. Async Non-Blocking Operations
The backend leverages Python's `asyncio` ecosystem (`FastAPI`, `asyncpg`, `httpx`) to perform concurrent database queries and external Meta API requests without blocking event loops.

### 3. Decoupled Presentation Layer
The web portal (`frontend/`) and mobile client (`mobile/`) operate as stateless single-page applications. They communicate exclusively via RESTful JSON endpoints (`/api/v1/*`) with Bearer JWT tokens.

---

## Component Breakdown

### Frontend Web Portal (`frontend/`)
- **Framework:** React 19 + Vite 6
- **Routing:** React Router v7 (`/`, `/tasks`, `/chat`, `/profile`, `/login`, `/meta/callback`)
- **State Management:** React Context API (`AuthContext`) for token persistence and authentication states
- **Styling:** Vanilla CSS design tokens (`index.css`) with light-theme glassmorphism and Lucide icons

### Backend Service (`backend/`)
- **Framework:** FastAPI
- **Data Access:** Async SQLAlchemy 2.0 with `asyncpg` connection pooling
- **Migrations:** Alembic
- **Security:** Passlib (Bcrypt) for password hashing, PyJWT for access/refresh token generation, Fernet for credential encryption

### Database Layer (`backend/app/models/`)
- **DBMS:** PostgreSQL
- **Key Tables:** `organizations`, `users`, `projects`, `tasks`, `task_comments`, `messages`, `meta_connections`, `meta_campaigns`, `meta_daily_insights`
