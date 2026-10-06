# Multi-Tenancy & Tenant Isolation

## Overview

**Throttle Client Portal** implements multi-tenancy using **Organization-Scoped Shared Database Isolation**. This approach provides strict privacy and data boundaries while allowing high performance and low infrastructure cost.

---

## Data Model & Hierarchy

```
                      ┌──────────────────────┐
                      │     Organization     │
                      └──────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│      Users       │    │  Tasks & Approvals│   │ Meta Connections │
└──────────────────┘    └──────────────────┘    └──────────────────┘
```

Every user, task, chat message, and analytics metric belongs strictly to one **Organization**.

---

## Security Model

### 1. Token-Driven Context Resolution
When a user logs in, the backend issues a signed JWT containing:
* `sub`: User ID
* `org_id`: Organization ID
* `role`: User Role (`THROTTLE_ADMIN`, `CLIENT_ADMIN`, `CLIENT_MEMBER`, `CLIENT_VIEWER`)

### 2. Backend Enforcement
The API server extracts `org_id` directly from the validated JWT token context. **The client cannot supply or override the `organization_id` in request payloads to access another tenant's data.**

#### Example Backend Implementation Pattern:
```python
@router.get("/tasks")
async def get_organization_tasks(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    # Query is explicitly filtered by the authenticated user's organization_id
    query = select(Task).where(Task.organization_id == current_user.organization_id)
    result = await db.execute(query)
    return result.scalars().all()
```

### 3. Super Admin Exception
Users with the `THROTTLE_ADMIN` role belong to the agency organization and possess multi-tenant visibility across all client organizations for cross-organization task management and chat support.
