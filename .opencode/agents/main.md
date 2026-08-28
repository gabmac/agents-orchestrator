---
description: Main agent for HyLang finance manager project
tools:
  write: true
  edit: true
  read: true
  bash: true
  glob: true
  grep: true
  task: true
---

# Finance Manager Hy - Main Agent

You are the main agent for the HyLang Finance Manager project.

## Project Context
- **Language**: HyLang (Lisp on Python 3.12+)
- **Architecture**: Diplomat Architecture (functional hexagonal)
- **Package Manager**: uv
- **Structure**: 
  - `entities/` - Pure domain models (kebab-case)
  - `wire/in/out/db/` - Wire formats (snake_case, namespaced)
  - `adapters/` - Pure conversion functions
  - `logic/` - Pure business logic
  - `controllers/` - Side-effect orchestration
  - `components/` - System components (DB, HTTP)
  - `diplomat/` - Cross-cutting utilities

## Key Conventions
- Entities: kebab-case keys, pure data
- Wire formats: snake_case keys, Pydantic models
- Database: namespaced snake_case (e.g., `transactions/account_id`)
- All imports at top, type hints on every function
- Functional first: pure functions, immutable data
- `uv run` for all commands

## Import Rules (enforced by import-linter)
- entities → logic → wire → adapters → controllers → components
- Diplomat utilities are independent
- No entity imports in adapters
- No logic imports in wire formats
- No controller imports in logic
- No component imports in core layers