# Changelog

All notable changes to the **Throttle Client Portal** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Multi-tenant client portal web interface built with React 19 and Vite 6.
- Organization-scoped backend architecture powered by FastAPI and Async SQLAlchemy (PostgreSQL).
- Real-time Meta Graph API (v26.0) integration for advertising insights, campaign metrics, and historical ROAS tracking.
- Client Task & Approvals module featuring task priority tags, deadline tracking, and interactive approval/change-request workflows.
- Task comment discussions with timestamped message history.
- Encrypted live chat interface with contact selection and message status tags.
- JWT-based authentication system supporting access and refresh tokens.
- Light-themed UI with glassmorphism visual aesthetics and micro-animations.
- Cross-platform Flutter client app structure for mobile deployment.

### Fixed
- Organization slug generation conflict during user registration.
- Meta OAuth callback redirect URI handling.
- Text truncation and layout formatting on chat screen headers.
- Multi-tenant data boundary isolation across task and analytics endpoints.
