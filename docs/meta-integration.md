# Meta Marketing API Integration Documentation

## Overview

**Throttle Client Portal** integrates with Meta Marketing API (`v26.0`) to ingest live advertising performance metrics (Spend, Impressions, Reach, Clicks, Conversions, ROAS) for client organizations.

```
 Client Web Portal               Throttle Backend               Meta Graph API (v26.0)
       │                                │                                │
       │ ── 1. Connect Account ────────►│                                │
       │                                │ ── 2. Request OAuth Scope ────►│
       │                                │    (ads_read, read_insights)   │
       │                                │◄── 3. Access Token ───────────│
       │                                │                                │
       │                                │ ── 4. Encrypt Token (Fernet) ──┐
       │                                │    & Save to DB                │
       │                                │◄───────────────────────────────┘
       │                                │
       │                                │ ── 5. Fetch Daily Insights ───►│
       │◄── 6. Normalized Analytics ────│◄── 6. Raw Performance Data ───│
```

---

## Token Security & Storage
- **Token Encryption:** Meta Access Tokens are encrypted using Fernet symmetric encryption (`cryptography` library) before being written to PostgreSQL.
- **Key Storage:** The encryption key `META_ENCRYPTION_KEY` is loaded from environment variables and never exposed to the client interface.

---

## Demo Fallback Mode
When running in local development environments where real Meta credentials are not configured, the backend automatically provides fallback analytics data so developers can preview real-time chart visualizations without requiring live Facebook Developer app approvals.
