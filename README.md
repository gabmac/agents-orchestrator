# Finance Manager Hy

A personal finance manager built with **HyLang** (Lisp on the Python VM), following hexagonal architecture principles.

## Features

- **Multi-currency support** with exchange rates
- **Double-entry accounting** with hierarchical accounts
- **Transaction management** (income, expenses, transfers, adjustments)
- **Budgeting** with period-based budgets and rollover
- **Reporting** (cash flow, net worth, spending by category)
- **Data import** (CSV, OFX, QIF, YNAB)
- **Bank integration** (Plaid, Open Banking)
- **RESTful API** with FastAPI

## Tech Stack

- **Language**: HyLang 1.0+ (Lisp on Python 3.12+)
- **Framework**: FastAPI for API
- **Database**: PostgreSQL with SQLModel (async)
- **Migrations**: Alembic
- **Testing**: pytest, hypothesis, mutmut
- **Linting**: ruff, mypy, hyfmt
- **DI**: Custom container (Lagom-style)

## Quick Start

```bash
# Install dependencies
uv sync

# Install pre-commit hooks
uv run pre-commit install

# Copy environment template
cp .env.example .env

# Run database migrations
uv run alembic upgrade head

# Start development server
uv run hy src/finance_manager_hy/main.hy

# Or with uvicorn
uv run uvicorn finance_manager_hy.adapters.api:create-app --factory --reload
```

## Commands

```bash
# Format code
uv run hyfmt src/ tests/

# Lint
uv run ruff check src/ tests/

# Type check
uv run mypy src/ tests/

# Run tests
uv run python -m pytest tests/ -v

# Run tests with coverage
uv run python -m pytest tests/ -v --cov=src --cov-report=term-missing

# Mutation testing
uv run mutmut run --paths-to-mutate src/

# Run all checks
uv run hyfmt src/ tests/ && uv run ruff check src/ tests/ && uv run mypy src/ tests/ && uv run python -m pytest tests/ -v
```

## Project Structure

```
src/
  finance_manager_hy/
    config.hy                    # Configuration (pure functions)
    entities/                    # Pure domain models (kebab-case)
      transaction.hy
      account.hy
      category.hy
    wire/                        # Wire formats (snake_case)
      in/                        # HTTP request schemas
      out/                       # HTTP response schemas
      db/                        # Database schemas (namespaced)
    adapters/                    # Pure conversion functions (wire ↔ entity)
    logic/                       # Pure business logic
    controllers/                 # Side-effect orchestration
    components/                  # System components (DB, HTTP)
    diplomat/                    # Diplomat utilities
      schema.hy                  # Schema validation utilities
      wire.hy                    # Key conversion, namespace handling
      adapter.hy                 # Adapter pattern base classes
      interceptors/              # FastAPI interceptors
      http/                      # HTTP-specific utilities
      db/                        # Database utilities
    macros.hy                    # Custom macros
tests/
  unit/                          # Unit tests
  integration/                   # Integration tests
  property_based_test/           # Property tests
  generators.hy                  # Test data factories
```

## Architecture

Diplomat Architecture (Nubank-inspired functional hexagonal):

- **Entities** (`entities/`) — Pure domain models, kebab-case keys, immutable
- **Wire formats** (`wire/in/`, `wire/out/`, `wire/db/`) — Explicit schemas per boundary (snake_case, namespaced for DB)
- **Adapters** (`adapters/`) — Pure bidirectional converters (wire ↔ entity)
- **Logic** (`logic/`) — Pure business logic, no side effects
- **Controllers** (`controllers/`) — Side-effect orchestration, call ports
- **Components** (`components/`) — Stateful infrastructure (DB pool, HTTP client)
- **Diplomat** (`diplomat/`) — Cross-cutting utilities (schemas, interceptors, adapters)

Key conventions:
- Internal: kebab-case (`:account-id`)
- HTTP: snake_case (`account_id`)
- Database: namespaced snake_case (`transactions/account_id`)
- JSON APIs: camelCase (`accountId`)

Dependencies flow: entities → logic → wire → adapters → controllers → components
Never import outward. Diplomat utilities are independent.

## Development

### Adding a New Feature

1. Define wire schemas in `wire/in/`, `wire/out/`, `wire/db/`
2. Create entity in `entities/`
3. Write adapter in `adapters/`
4. Implement logic in `logic/`
5. Create controller in `controllers/`
6. Wire in DI container (`components/container.hy`)

### Macro Development

All macros in `src/finance_manager_hy/macros.hy`:
- Use `defmacro/g!` with `gensym` for hygiene
- Document with docstrings
- Test expanded forms with `hy.eval`

### Testing

- **Unit**: Logic/usecases only, mock ports with `AsyncMock(spec=PortClass)`
- **Integration**: Entrypoints (API routes, CLI), real DB via testcontainers
- **Property**: Pure functions with hypothesis (adapter round-trips, key conversions)
- **Mutation**: Mutmut on `src/` (survivors = weak assertions)

## Configuration

Environment variables in `.env`:

```env
# App
APP_NAME=finance-manager-hy
VERSION=0.1.0
ENVIRONMENT=development
DEBUG=true

# Database
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/finance_manager
DATABASE_ECHO=false

# API
API_HOST=0.0.0.0
API_PORT=8000

# Security
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# External APIs
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENVIRONMENT=sandbox
```

## License

MIT