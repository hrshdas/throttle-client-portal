# Authentication & Authorization Documentation

## Overview

Authentication in **Throttle Client Portal** relies on stateless JSON Web Tokens (JWT) with dual-token validation (Access Token + Refresh Token).

---

## Token Lifecycles

| Token Type | Expiration | Purpose | Storage |
| :--- | :--- | :--- | :--- |
| **Access Token** | 30 Minutes | Authorizes API requests via `Authorization: Bearer <token>` header | Browser `localStorage` |
| **Refresh Token** | 7 Days | Re-issues access tokens when expired | Database (`refresh_tokens` table) |

---

## User Registration & Authentication Flow

### 1. User Registration (`POST /api/v1/auth/register`)
- Accepts `name`, `email`, `password`, `company_name`.
- Automatically generates a unique company slug and `Organization` entity.
- Creates the user with role `CLIENT_ADMIN`.
- Returns access & refresh tokens.

### 2. User Login (`POST /api/v1/auth/login`)
- Verifies credentials against `bcrypt` password hash.
- Issues new signed JWT access token and records refresh token hash.

### 3. Protected Request Interceptor
The web client (`frontend/src/api/apiClient.js`) automatically attaches the JWT token to every HTTP request:
```javascript
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

---

## Role-Based Access Control (RBAC)

Supported Roles:
* `THROTTLE_ADMIN`: Agency superuser. Can manage all tenants, review tasks, and communicate with all clients.
* `CLIENT_ADMIN`: Client organization administrator. Can invite users, manage ad account connections, and approve deliverables.
* `CLIENT_MEMBER`: Standard client team member. Can create tasks and post comments.
* `CLIENT_VIEWER`: Read-only access to analytics dashboards and tasks.
