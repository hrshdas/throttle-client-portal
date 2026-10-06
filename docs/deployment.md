# Production Deployment Guide

## Architecture Overview

For production deployment, **Throttle Client Portal** is deployed in two decoupled layers:

1. **Frontend**: Static SPA hosted on **Vercel** or **Netlify** (Global Edge CDN).
2. **Backend**: Python FastAPI service on **Render**, **Railway**, or **AWS/DigitalOcean** with managed **PostgreSQL**.

---

## Environment Variables Reference

### Backend Environment Variables (`backend/.env`)

| Variable | Description | Production Example |
| :--- | :--- | :--- |
| `DATABASE_URL` | Async PostgreSQL Connection String | `postgresql+asyncpg://user:pass@ep-db.render.com/throttle` |
| `SECRET_KEY` | JWT Signing Secret (64+ chars) | `e9f8a7b6...` |
| `ENVIRONMENT` | Deployment Environment | `production` |
| `FRONTEND_URL` | CORS Origin Allowed Domain | `https://portal.throttle.agency` |
| `META_APP_ID` | Facebook Developer App ID | `1593140032307776` |
| `META_APP_SECRET` | Facebook Developer App Secret | `54da2c7f2d...` |
| `META_REDIRECT_URI` | Valid Meta OAuth Callback URL | `https://api.throttle.agency/api/v1/meta/connect/callback` |
| `META_ENCRYPTION_KEY` | Fernet 32-byte Base64 key | `C0LNcELOE1dOA-KMVHO5w...` |

### Frontend Environment Variables (`frontend/.env`)

| Variable | Description | Production Example |
| :--- | :--- | :--- |
| `VITE_API_URL` | Live Backend API Base URL | `https://api.throttle.agency/api/v1` |

---

## Step-by-Step Deployment Instructions

### 1. Database & Backend Deployment (Render / Railway)
1. Provision a PostgreSQL instance on Render/Railway.
2. Create a Web Service pointing to `backend/`.
3. Set Build Command: `pip install -r requirements.txt`
4. Set Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Configure backend environment variables.

### 2. Frontend Deployment (Vercel)
1. Import repository on Vercel.
2. Set **Root Directory** to `frontend`.
3. Set **Framework Preset** to `Vite`.
4. Set `VITE_API_URL` environment variable.
5. Click **Deploy**.
