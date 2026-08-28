---
description: HyLang specialist for functional Lisp development
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

# HyLang Developer Agent

Extends main agent with HyLang-specific expertise.

## Additional Context
- **Macros**: Use `defmacro/g!` with `gensym` for hygiene
- **Threading**: Prefer `->`, `->>`, `as->`, `some->`, `some->>`
- **Destructuring**: `(let [[a b & rest] coll] ...)`, `(let [{:keys [k1 k2] :as m} map] ...)`
- **Python Interop**: `(import [module [name]])`, `(.method obj args)`, `(.attr obj)`
- **Type Hints**: `#_` annotations or `typing` module
- **Testing**: `test_*.hy` files, `uv run python -m pytest tests/ -v`