# Database Entity Relationship & Schema Documentation

## Database Schema Overview

**Throttle Client Portal** uses PostgreSQL with Async SQLAlchemy 2.0. Every table enforces organization-level multi-tenancy.

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ USERS : contains
    ORGANIZATIONS ||--o{ PROJECTS : owns
    ORGANIZATIONS ||--o{ TASKS : owns
    ORGANIZATIONS ||--o{ META_CONNECTIONS : links
    PROJECTS ||--o{ TASKS : contains
    TASKS ||--o{ TASK_COMMENTS : includes
    TASKS ||--o{ TASK_APPROVAL_HISTORY : tracks

    ORGANIZATIONS {
        string id PK
        string name
        string slug UK
        string logo_url
        datetime created_at
    }

    USERS {
        string id PK
        string organization_id FK
        string name
        string email UK
        string hashed_password
        enum role
        boolean is_active
    }

    TASKS {
        string id PK
        string organization_id FK
        string project_id FK
        string title
        text description
        enum priority
        enum status
        boolean requires_client_approval
        enum approval_status
        date due_date
    }

    META_CONNECTIONS {
        string id PK
        string organization_id FK
        string ad_account_id
        string ad_account_name
        string encrypted_access_token
        datetime token_expires_at
        string status
    }
```

---

## Entity Descriptions

1. **`organizations`**: Master tenant table. Stores tenant name, unique URL slug, and configuration.
2. **`users`**: User account credentials, hashed password, role (`THROTTLE_ADMIN`, `CLIENT_ADMIN`, `CLIENT_MEMBER`, `CLIENT_VIEWER`), and organization FK.
3. **`projects`**: Top-level client campaigns or deliverables.
4. **`tasks`**: Actionable work items, deliverables, and approval items. Includes `priority`, `status`, `requires_client_approval`, and `approval_status`.
5. **`task_comments`**: Timestamped comment discussion entries per task.
6. **`meta_connections`**: Stores encrypted Meta Graph API access tokens, connected ad account details, and sync statuses.
7. **`meta_daily_insights`**: Normalized daily ad performance analytics (spend, impressions, clicks, conversions, ROAS).
