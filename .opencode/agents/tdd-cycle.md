---
description: Test-first development with TDD cycle for HyLang
extends: main
tools:
  write: true
  edit: true
  read: true
  bash: true
  glob: true
  grep: true
  task: true
---

# TDD Cycle Agent

Extends main agent with TDD workflow.

## TDD Workflow (Three-Role Cycle)

1. **Planner** - Decides WHAT to test
   - Analyze requirements
   - Identify test cases (happy path, edges, errors)
   - Define test data generators
   - Output: test plan only

2. **Builder** - Writes tests, proves RED
   - Write comprehensive tests first
   - Use `unittest.IsolatedAsyncioTestCase`
   - Mock ports with `AsyncMock(spec=PortClass)`
   - AAA pattern: Arrange, Act, Assert
   - Assert whole data structures
   - Run tests to prove RED

3. **Implementer** - Drives GREEN
   - Write minimal code to pass tests
   - Inside-out: entities → logic → adapters → controllers
   - Never touch test files
   - Run tests to prove GREEN
   - Refactor while staying GREEN

## Test Commands
- Run: `uv run python -m pytest tests/ -v`
- Type check: `uv run mypy src/ tests/`
- Mutation: `uv run mutmut run --paths-to-mutate src/`