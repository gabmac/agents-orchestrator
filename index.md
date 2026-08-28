# Codebase Index

> Auto-generated. Update on every structural change.

## Flows

### Transaction Creation
- Entry: POST /api/v1/transactions
- Controller: `src/finance_manager_hy/controllers/transaction.hy:create-transaction`
- Use Case: `src/finance_manager_hy/logic/transaction.hy:CreateTransaction`
- Adapter: `src/finance_manager_hy/adapters/transaction.hy:TransactionAdapter`
- Wire In: `src/finance_manager_hy/wire/in/transaction.hy:TransactionCreate`
- Wire Out: `src/finance_manager_hy/wire/out/transaction.hy:TransactionResponse`
- Wire DB: `src/finance_manager_hy/wire/db/transaction.hy:TransactionDB`
- Entity: `src/finance_manager_hy/entities/transaction.hy:Transaction`
- Repository Port: `src/finance_manager_hy/port.hy:TransactionRepository`
- DB Impl: `src/finance_manager_hy/components/database.hy:PostgresTransactionRepository`

### Account Management
- Entry: GET/POST /api/v1/accounts
- Controller: `src/finance_manager_hy/controllers/account.hy`
- Use Case: `src/finance_manager_hy/logic/account.hy`
- Adapter: `src/finance_manager_hy/adapters/account.hy:AccountAdapter`
- Wire In: `src/finance_manager_hy/wire/in/account.hy:AccountCreate`
- Wire Out: `src/finance_manager_hy/wire/out/account.hy:AccountResponse`
- Wire DB: `src/finance_manager_hy/wire/db/account.hy:AccountDB`
- Entity: `src/finance_manager_hy/entities/account.hy:Account`
- Repository Port: `src/finance_manager_hy/port.hy:AccountRepository`
- DB Impl: `src/finance_manager_hy/components/database.hy:PostgresAccountRepository`

### Budget Management
- Entry: GET/POST /api/v1/budgets
- Controller: `src/finance_manager_hy/controllers/budget.hy`
- Use Case: `src/finance_manager_hy/logic/budget.hy`
- Adapter: `src/finance_manager_hy/adapters/budget.hy:BudgetAdapter`
- Wire In: `src/finance_manager_hy/wire/in/budget.hy:BudgetCreate`
- Wire Out: `src/finance_manager_hy/wire/out/budget.hy:BudgetResponse`
- Wire DB: `src/finance_manager_hy/wire/db/budget.hy:BudgetDB`
- Entity: `src/finance_manager_hy/entities/budget.hy:Budget`
- Repository Port: `src/finance_manager_hy/port.hy:BudgetRepository`
- DB Impl: `src/finance_manager_hy/components/database.hy:PostgresBudgetRepository`

## Layers

### Entities
- `src/finance_manager_hy/entities/transaction.hy`
- `src/finance_manager_hy/entities/account.hy`
- `src/finance_manager_hy/entities/category.hy`
- `src/finance_manager_hy/entities/budget.hy`

### Wire Formats

#### In (HTTP Request)
- `src/finance_manager_hy/wire/in/transaction.hy`
- `src/finance_manager_hy/wire/in/account.hy`
- `src/finance_manager_hy/wire/in/budget.hy`

#### Out (HTTP Response)
- `src/finance_manager_hy/wire/out/transaction.hy`
- `src/finance_manager_hy/wire/out/account.hy`
- `src/finance_manager_hy/wire/out/budget.hy`

#### DB (Database)
- `src/finance_manager_hy/wire/db/transaction.hy`
- `src/finance_manager_hy/wire/db/account.hy`
- `src/finance_manager_hy/wire/db/budget.hy`

### Logic
- `src/finance_manager_hy/logic/transaction.hy`
- `src/finance_manager_hy/logic/account.hy`
- `src/finance_manager_hy/logic/budget.hy`
- `src/finance_manager_hy/logic/report.hy`

### Adapters
- `src/finance_manager_hy/adapters/transaction.hy`
- `src/finance_manager_hy/adapters/account.hy`
- `src/finance_manager_hy/adapters/budget.hy`

### Controllers
- `src/finance_manager_hy/controllers/transaction.hy`
- `src/finance_manager_hy/controllers/account.hy`
- `src/finance_manager_hy/controllers/budget.hy`
- `src/finance_manager_hy/controllers/report.hy`

### Components
- `src/finance_manager_hy/components/container.hy`
- `src/finance_manager_hy/components/database.hy`
- `src/finance_manager_hy/components/http.hy`
- `src/finance_manager_hy/components/cli.hy`

### Diplomat
- `src/finance_manager_hy/diplomat/schema.hy`
- `src/finance_manager_hy/diplomat/wire.hy`
- `src/finance_manager_hy/diplomat/adapter.hy`
- `src/finance_manager_hy/diplomat/interceptors.hy`
- `src/finance_manager_hy/diplomat/http/interceptors.hy`
- `src/finance_manager_hy/diplomat/db/connection.hy`

## Ports
- `src/finance_manager_hy/port.hy:TransactionRepository`
- `src/finance_manager_hy/port.hy:AccountRepository`
- `src/finance_manager_hy/port.hy:BudgetRepository`
- `src/finance_manager_hy/port.hy:ExchangeRateProvider`
- `src/finance_manager_hy/port.hy:EventPublisher`
- `src/finance_manager_hy/port.hy:FileStorage`
- `src/finance_manager_hy/port.hy:NotificationService`

## Config
- `src/finance_manager_hy/config.hy:Settings`
- `src/finance_manager_hy/macros.hy`

## Tests
- `tests/unit/`
- `tests/integration/`
- `tests/unit/property_based_test/`
- `tests/generators.hy`