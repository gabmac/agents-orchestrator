---
description: Run the full test suite with coverage report
agent: tdd-cycle
---

Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.

```bash
uv run python -m pytest tests/ -v --cov=src --cov-report=term-missing
```