---
description: Run semgrep with project rules and community packs
agent: build
---

Run semgrep static analysis with project rules and community security packs.

```bash
uv run semgrep --config .semgrep/rules --config p/python --config p/security-audit --config p/secrets --config p/owasp-top-ten --config p/cwe-top-25 --config p/command-injection --config p/insecure-transport --config p/docker --error --metrics=off --quiet --skip-unknown-extensions
```