# Contributing to Throttle Client Portal

Thank you for considering contributing to **Throttle Client Portal**! This document provides guidelines and standards for submitting contributions.

---

## Getting Started

1. **Fork the Repository** and clone your fork locally.
2. **Setup Local Environment**:
   - Follow the instructions in [`README.md`](./README.md) to set up both the **Frontend (React/Vite)** and **Backend (FastAPI/PostgreSQL)**.
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

---

## Code Quality Standards

### Frontend Guidelines
- **Framework:** React 19 + Vite.
- **Styling:** Vanilla CSS design system tokens (`index.css`). Use predefined CSS variables (`var(--bg-glass)`, `var(--text-secondary)`).
- **Icons:** Use `lucide-react`.
- **Validation:** Run `npm run build` inside `frontend/` to verify clean compilation without warnings or syntax errors.

### Backend Guidelines
- **Framework:** FastAPI (Python 3.12+).
- **Database Access:** Async SQLAlchemy models (`app/models`) and Pydantic v2 schemas (`app/schemas`).
- **Formatting:** Adhere to PEP8 conventions.
- **Testing:** Add pytest test cases under `backend/tests/` for new endpoints or business logic.

---

## Pull Request Checklist

Before submitting a Pull Request, ensure:
- [ ] Code compiles/builds cleanly without errors (`npm run build` in `frontend/`).
- [ ] Backend tests pass (`pytest` in `backend/`).
- [ ] No secrets, `.env` files, or private tokens are included in commits.
- [ ] Documentation is updated if modifying APIs, models, or environment variables.
- [ ] PR title is clear and concise (e.g., `feat(tasks): add status filter dropdown`).

---

## Commit Message Format

Use clear, descriptive commit messages:
- `feat(scope): add feature description`
- `fix(scope): fix bug description`
- `docs(scope): update documentation`
- `refactor(scope): refactor code without behavior change`
