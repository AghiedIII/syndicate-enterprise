# Syndicate Enterprise — Accounting Platform

A multi-tenant engineering consulting accounting platform serving three regional syndicate branches (HAS, QAM, DER) across Syria. Manages project invoicing, engineer discipline assignments, automated K-factor payouts, and real-time ledger reconciliation across six specialized accounting models.

## Features

- **Multi-Tenant Architecture**: Per-branch JWT isolation with row-level security
- **6 Accounting Models**: GS (General Study), SR (Structural Safety), BS (Bayani Study), RI (Reinforcement Inspection), MF (Material Facility), SC (Supervision Contract)
- **Automated K-Factor Payouts**: Complex multi-stage deduction pipelines (Stage 1-4) with fund subscription logic
- **Real-Time Reconciliation**: Zero-discrepancy balance verification with JSONB audit trails
- **Document Studio**: Python-based PDF generation with regional branding and cryptographic sealing
- **Arabic/English Localization**: Full i18n support for dashboard and documents

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Frontend (React 18 + Vite + TypeScript)               │
│  - LoginPortal: JWT auth with branch-based theming    │
│  - Dashboard: Project CRUD, engineer assignments      │
│  - Recharts: Real-time fund & reconciliation metrics   │
└────────────────┬────────────────────────────────────────┘
                 │ REST API (NestJS)
┌────────────────▼────────────────────────────────────────┐
│  Backend (Node.js + NestJS)                            │
│  - Auth Module: JWT + multi-tenant RBAC               │
│  - Projects Module: Model 1-6 CRUD + estimates       │
│  - Engineers Module: Registry + discipline lookup     │
│  - Settlement Module: Lifecycle triggers & escrow     │
│  - Reconciliation Module: Balance verification        │
└────────────────┬────────────────────────────────────────┘
                 │ TypeORM + Knex.js
┌────────────────▼────────────────────────────────────────┐
│  PostgreSQL Database (v12+)                            │
│  - 6 Model-specific schemas (model_1-6_*)            │
│  - Syndicate ledger & contribution tables             │
│  - K-factor matrices + tariff configs                 │
│  - Triggers: Invoice calc, settlement escrow, audit   │
└────────────────────────────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ Document Studio │ (Python)
        │ - PDF rendering │
        │ - Signatures    │
        │ - Regional seal │
        └─────────────────┘
```

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Frontend** | React, Vite, TypeScript, Tailwind | 18.3.1, 5.3.1, 5.2.2, 3.4.4 |
| **Backend** | NestJS, TypeORM | 10.x, 0.3.x |
| **Database** | PostgreSQL | 12+ |
| **Auth** | JWT (HS256) | jsonwebtoken |
| **Document Gen** | Python, ReportLab | 3.9+ |
| **Containerization** | Docker, Docker Compose | Latest |

## Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- Python 3.9+
- Docker & Docker Compose (optional, recommended for local dev)

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/AghiedIII/syndicate-enterprise.git
cd syndicate-enterprise

# Install all service dependencies
npm install                    # Root workspaces (if configured)
cd frontend && npm install && cd ..
cd backend && npm install && cd ..

# Python dependencies
cd document-studio
pip install -r requirements.txt
cd ..
```

### 2. Set Up Environment

```bash
# Copy template files
cp .env.example .env
cp backend/.env.example backend/.env
cp document-studio/.env.example document-studio/.env

# Edit .env with your values
# DATABASE_URL, JWT_SECRET, USD_SYP_RATE, etc.
nano .env
```

### 3. Initialize Database

```bash
# Apply all migrations and seed data
npm run db:init

# Or manually:
psql -U postgres -d syndicate_enterprise \
  -f database/master-syndicate-db-setup-v5.sql \
  -f database/seed-engineers-v2.sql \
  -f database/08_central_accumulator-v2.sql
```

### 4. Start Services (Docker Recommended)

```bash
# Using Docker Compose (all-in-one)
docker-compose up -d

# Or manually start each service:
# Terminal 1: Backend
cd backend && npm run start:dev

# Terminal 2: Frontend
cd frontend && npm run dev

# Terminal 3: Document Studio (Flask/Gunicorn)
cd document-studio && gunicorn -b 0.0.0.0:5000 app:app

# Verify services
curl http://localhost:3000/health
open http://localhost:5173  # Frontend
```

## Environment Variables

### Root `.env`
```env
DATABASE_URL=postgresql://user:password@localhost:5432/syndicate_enterprise
JWT_SECRET=your_super_secret_key_min_32_chars_long
NODE_ENV=development
PORT=3000
```

### Backend `backend/.env`
```env
DATABASE_URL=postgresql://user:password@localhost:5432/syndicate_enterprise
JWT_SECRET=your_super_secret_key_min_32_chars_long
JWT_EXPIRY=24h
NODE_ENV=development
API_PORT=3000
FRONTEND_URL=http://localhost:5173
USD_SYP_RATE=15000
```

### Document Studio `document-studio/.env`
```env
API_BASE_URL=http://localhost:3000
JWT_SECRET=your_super_secret_key_min_32_chars_long
OUTPUT_DIR=/tmp/syndicate_pdfs
LOG_LEVEL=DEBUG
```

## Project Structure

```
syndicate-enterprise/
├── README.md                          ← You are here
├── docker-compose.yml                 ← All services orchestration
├── .env.example                       ← Template for root env vars
├── Makefile                           ← Common dev tasks
│
├── database/
│   ├── master-syndicate-db-setup-v5.sql    ← All 6 model schemas + triggers
│   ├── 08_central_accumulator-v2.sql       ← Reconciliation views
│   ├── seed-engineers-v2.sql               ← Test data
│   └── migrations/                         ← Future: Versioned migrations
│
├── backend/                           ← [IMPLEMENT PHASE 2]
│   ├── .env.example
│   ├── package.json
│   ├── src/
│   │   ├── main.ts                    ← NestJS bootstrap
│   │   ├── app.module.ts              ← Root module
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── jwt.strategy.ts
│   │   ├── projects/
│   │   │   ├── projects.controller.ts
│   │   │   ├── projects.service.ts
│   │   │   └── models/               ← 6 DTO/Entity pairs
│   │   ├── engineers/
│   │   │   ├── engineers.controller.ts
│   │   │   └── engineers.service.ts
│   │   ├── reconciliation/
│   │   │   └── reconciliation.service.ts
│   │   ├── common/
│   │   │   ├── guards/
│   │   │   │   ├── jwt.guard.ts
│   │   │   │   └── branch.guard.ts
│   │   │   ├── interceptors/
│   │   │   │   └── branch-isolation.interceptor.ts
│   │   │   └── filters/
│   │   │       └── exception.filter.ts
│   │   └── config/
│   │       └── database.config.ts
│   └── test/
│
├── frontend/
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   │   ├── LoginPortal.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   └── translations.ts
│   │   └── index.css
│   ├── package.json
│   └── vite.config.ts
│
├── document-studio/
│   ├── .env.example
│   ├── requirements.txt                ← Python dependencies
│   ├── generate_pdf_sc.py
│   ├── signature_authority.py
│   ├── simulate-full-pipeline.py
│   └── assets/                        ← Regional logos
│
└── docs/
    ├── syndicate-api-spec-v2.md       ← REST API docs
    ├── syndicate-query-bible.md       ← SQL reference
    ├── syndicate-system-documentation-ar.md
    └── syndicate-ui-style-kit.md
```

## Accounting Models Overview

| Model | Code | Purpose | Pricing | Fund Pools |
|-------|------|---------|---------|-----------|
| **General Study** | GS | Comprehensive architectural review | $/m² based on tariff | Joint + Audit |
| **Structural Safety** | SR | Reinforced concrete integrity assessment | Fixed USD fee | Joint only |
| **Bayani Study** | BS | Category-aware rapid assessment | Tiered $ rates | Joint + Audit |
| **Reinforcement Inspection** | RI | Column/beam validation | Variable USD | Joint + Audit |
| **Material Facility** | MF | Warehouse/storage classification | Flat rate + area | Joint only |
| **Supervision Contract** | SC | On-site monitoring (6-month term) | $/m² + sanitary | Joint only |

**Key Deduction Stages** (all models):
- **Stage 1**: 10-15% Unit/Syndicate Admin Fee
- **Stage 2**: 20-25% Joint Fund (Insider) OR 9-10% (Outsider)
- **Stage 3**: 15-25% Discipline-specific Fund (if Trainee)
- **Stage 4**: Coaching fee (15% of remaining, only for trainees)
- **Printing**: Fixed allocation pool

**K-Factor Lookup** (stateless, O(1)):
```
Insider + No Coach  → K = 0.5100-0.6750
Insider + Coach     → K = 0.4335-0.5738
Outsider + No Coach → K = 0.6120-0.8100
Outsider + Coach    → K = 0.5202-0.7685
(varies by model)
```

## Development Workflow

### Running Tests

```bash
# Unit tests
npm run test:unit

# Integration tests (requires PostgreSQL)
npm run test:integration

# Coverage report
npm run test:coverage
```

### Database Management

```bash
# Reset DB to clean state (use with CAUTION)
npm run db:reset

# Generate new migration (after schema changes)
npm run db:migrate:create -- --name add_field_X

# Apply pending migrations
npm run db:migrate
```

### API Development

```bash
# Start backend with hot reload
cd backend && npm run start:dev

# View API docs (Swagger)
open http://localhost:3000/api

# Test endpoint
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"qam_ledger_admin","password":"password"}'
```

### Frontend Development

```bash
# Start Vite dev server with hot reload
cd frontend && npm run dev

# Build production bundle
npm run build

# Preview production build locally
npm run preview
```

## API Reference

See **`docs/syndicate-api-spec-v2.md`** for full REST endpoint documentation including:
- Authentication flow
- Project CRUD (Models 1-6)
- Engineer registry & discipline assignment
- Settlement & escrow release
- Reconciliation balance verification
- PDF document compilation

### Key Endpoints

```
POST   /api/v1/auth/login                    ← Branch accountant login
GET    /api/v1/dashboard/metrics             ← Fund summary & reconciliation
GET    /api/v1/engineers?discipline=CIV      ← Filter engineers by discipline
POST   /api/v1/projects/estimate             ← Dry-run K-factor calculation
POST   /api/v1/projects                      ← Create project & initialize assignments
PUT    /api/v1/projects/:id/settle           ← Transition to SETTLED, release escrow
POST   /api/v1/documents/compile             ← Generate & seal PDF report
```

## Multi-Tenant Isolation

Every API request requires an `Authorization: Bearer <JWT>` header. The JWT payload includes:

```json
{
  "user_id": "usr_01HJ8Z3...",
  "role": "branch_accountant",
  "branch_code": "QAM"   // HAS | QAM | DER
}
```

**Backend enforces isolation via:**
1. **Middleware**: Auto-appends `WHERE branch_code = JWT.branch_code` to all queries
2. **Row-Level Security** (future): PostgreSQL RLS policies for defense-in-depth
3. **Soft Redirection**: 403 Forbidden becomes transparent filtering for UX consistency

## Deployment

### Docker Compose (Development)

```bash
docker-compose up -d
# All services available immediately
```

### Kubernetes (Production)

See `k8s/` manifests (future) for production cluster deployment.

### Environment-Specific Builds

```bash
# Staging
docker build -t syndicate:staging --build-arg ENV=staging .

# Production
docker build -t syndicate:prod --build-arg ENV=production .
docker push myregistry.azurecr.io/syndicate:prod
```

## Testing the Platform

### End-to-End Workflow (Manual)

1. **Login** as branch accountant (QAM):
   - Username: `qam_ledger_admin`
   - Password: See seed data in `database/seed-engineers-v2.sql`

2. **Create a Project** (Model 6 - Supervision Contract):
   - Area: 600 m²
   - Footprint: 120 m²
   - Assignments: Civil, Architect, Mechanical, Electrical, Sanitary

3. **Assign Engineers**:
   - Pull engineers from dropdown (filtered by branch & discipline)
   - System auto-calculates gross fees per discipline

4. **Review Estimate** before settlement:
   - POST `/api/v1/projects/estimate` with assignments
   - Verify K-factors match fund subscription status

5. **Settle Project**:
   - PUT `/api/v1/projects/:id/settle` with cash receipt number
   - Database triggers unlock escrow → release payouts → log to syndicate ledger

6. **Verify Reconciliation**:
   - Check dashboard → "reconciliation_alert.ledger_integrity_badge"
   - Should show "PERFECT_BALANCE" (discrepancy = $0.00)

### Simulating Full Pipeline (Python)

```bash
cd document-studio
python simulate-full-pipeline.py \
  --model SC \
  --engineers 3 \
  --output-dir ./test_output
```

## Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
psql -h localhost -U postgres -c "SELECT version();"

# Verify DATABASE_URL in .env
echo $DATABASE_URL
```

### JWT Token Expired
The API returns `401 Unauthorized` with message "Token expired". Re-login:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -d '{"username":"qam_ledger_admin","password":"pass"}'
```

### Branch Isolation Not Enforced
Verify middleware is loaded in `backend/src/auth/branch-isolation.interceptor.ts`. Middleware should fire BEFORE controller handlers.

### K-Factor Calculation Mismatch
1. Check `k_factor_matrix_model_X` row matches engineer's `fund_status` + `has_coach`
2. Verify triggers on `model_X_assignments` update (BEFORE UPDATE, not AFTER)
3. See SQL in `docs/syndicate-query-bible.md` for manual verification

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/add-model-7`
3. Write tests for your changes
4. Ensure CI passes: `npm run test && npm run lint`
5. Open a pull request with a clear description

## License

Proprietary — Syndicate Engineering Governance Platform. All rights reserved.

## Support

For issues, bugs, or questions:
- GitHub Issues: https://github.com/AghiedIII/syndicate-enterprise/issues
- Documentation: See `docs/` directory
- Contact: engineering-support@syndicate.local

---

**Last Updated**: Sept 8, 2026  
**Version**: 0.1.0-alpha  
**Status**: Core schemas complete. Backend + API under development.
