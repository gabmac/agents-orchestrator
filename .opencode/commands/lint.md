---
description: Run ruff linting on the project
agent: build
---

Run ruff check and format on the project.

```bash
uv run ruff check src/ tests/
uv run ruff format src/ tests/
```