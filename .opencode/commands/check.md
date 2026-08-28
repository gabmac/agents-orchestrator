---
description: Run all quality checks (lint, typecheck, test)
agent: build
---

Run all quality checks in sequence: pre-commit, format, lint, typecheck, test.

```bash
uv run pre-commit run --all-files
uv run hyfmt src/ tests/
uv run ruff check src/ tests/
uv run mypy src/ tests/
uv run python -m pytest tests/ -v
```