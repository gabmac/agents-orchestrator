---
description: Diplomat architecture rules for
globs: ["**/*.hy"]
alwaysApply: true
---

# Diplomat Architecture Rules

## Layer Structure & Responsibilities

1. **Wire In** (`wire.in`) - HTTP request schemas (snake_case, Pydantic models)
2. **Wire Out** (`wire.out`) - HTTP response schemas (snake_case, Pydantic models)
3. **Wire DB** (`wire.db`) - Database schemas (namespaced snake_case, DB-specific formats)
4. **Entities** (`entities`) - Internal domain models (kebab-case keys, pure data)
5. **Logic** (`logic`) - Pure business logic, entity-level utilities, no I/O
6. **Adapters** (`adapters`) - Conversion functions ONLY: wire-in→entity, entity→wire-out, entity→wire-db, wire-db→entity. Only layer that knows wire schemas.
7. **Controllers** (`controllers`) - Flow orchestration entrypoints. Call logic and diplomat out. CANNOT call adapters directly.
8. **Diplomat HTTP** (`diplomat.http`) - HTTP server layer: routes → calls adapters & controllers. Maps wire-in to entity via adapter, calls controller, returns wire-out via adapter.
9. **Diplomat DB** (`diplomat.db`) - Database layer: uses adapters for entity↔wire-db conversion.
10. **Diplomat Interceptors** (`diplomat.interceptors`) - Cross-cutting concerns: validation, logging, auth.
11. **Components** (`components`) - Infrastructure: external APIs, message queues, etc.

## Dependency Rules (Enforced by importlinter)

- **Only adapters** import wire schemas (`wire.in`, `wire.out`, `wire.db`)
- **Controllers** call: `logic`, `diplomat.http` (diplomat out)
- **Adapters** call: `logic`, `entities` (for conversions)
- **Diplomat HTTP/DB** call: `adapters`, `controllers`
- **Logic** imports: `entities` only. Never imports `wire`, `adapters`, `controllers`, `diplomat`, `components`
- **Entities** imports: nothing (pure data)
- **Wire** imports: nothing (pure schemas)
- **Components** imports: anything (infrastructure boundary)

## Flow: Request → Response

```
HTTP Request (snake_case)
    → diplomat.http (route mapping)
    → adapter.wire-in->entity (snake_case → kebab-case, build entity)
    → controller (orchestrates: calls logic, diplomat out)
    → logic (pure business rules on entities)
    → diplomat out (external APIs, etc.)
    → adapter.entity->wire-out (kebab-case → snake_case)
    → HTTP Response (snake_case)
```

## Flow: Entity ↔ Database

```
Entity (kebab-case)
    → adapter.entity->wire-db (kebab-case → namespaced snake_case + DB formats)
    → Database

Database Record (namespaced snake_case)
    → adapter.wire-db->entity (reverse conversion)
    → Entity (kebab-case)
```

## Code Conventions

- All adapters registered via `register-adapter` in diplomat
- Controllers receive adapters as dependencies (injected)
- Wire schemas defined as Pydantic models in `wire/in`, `wire/out`, `wire/db`
- Entities as plain dicts or dataclasses with kebab-case keys
- Use threading macros (`->`, `->>`) for data pipeline readability
- All conversions explicit through adapters - no implicit transformations

## No Trivial Indirection

Do not create functions that just call another function. Call the target directly. Wrappers, aliases, and pass-throughs that add no transformation, validation, defaulting, or domain meaning are forbidden. See `docs/llm-rules/indirection.md` for full guidance (also enforced by `.semgrep/rules/indirection.yaml`).
