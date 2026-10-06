# Security Policy

## Reporting Vulnerabilities

We take security seriously. If you discover a potential security vulnerability within **Throttle Client Portal**, please report it immediately by contacting the repository maintainers directly instead of opening a public issue.

### Preferred Reporting Method
- Email: `security@throttle.agency` (or contact maintainer on GitHub)
- Include details such as:
  - Description of the issue
  - Steps to reproduce
  - Potential impact
  - Suggested remediation if available

Please allow up to 48 hours for an acknowledgment before taking any secondary action.

---

## Security Architecture & Best Practices

### 1. Secret Management
- **Never Commit Secrets:** API keys, database connection strings containing passwords, JWT secrets, and Meta App secrets are strictly stored in environment variables (`.env`).
- **Secret Scanning:** All pull requests and commits are scanned to prevent hardcoded credentials.

### 2. Multi-Tenant Scoped Isolation
- **Organization-Level Scoping:** All API endpoints and database operations resolve tenant isolation using the authenticated JWT token context (`organization_id`).
- **Authorization Enforcement:** Direct object references are protected. Users cannot manipulate `organization_id` parameters to query another tenant's database records.

### 3. Authentication & Session Security
- **Password Hashing:** Passwords are hashed using `bcrypt` via `passlib`. Plaintext passwords are never logged or stored.
- **JWT Signature Verification:** Access tokens (`HS256`) expire after 30 minutes. Refresh tokens are hashed and stored securely for session management.

### 4. Data Protection in Transit & at Rest
- **HTTPS Enforcement:** Production deployments require HTTPS for all API interactions.
- **Token Encryption:** External integration access tokens (such as Meta Graph API access tokens) are encrypted at rest using Fernet symmetric encryption (`cryptography` library).

---

## Supported Versions

| Version | Supported |
| :--- | :--- |
| `1.0.x` | ✅ Yes |
| `< 1.0` | ❌ No |
