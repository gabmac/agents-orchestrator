## Learned User Preferences

## Learned Workspace Facts

- HyLang macros must use `defmacro/g!` with `gensym` for hygiene; expanded forms tested with `hy.eval` in unit tests
- Python interop: prefer `(import [module [name]])` over `import` statement; use `.` for method calls `(.method obj args)` and attribute access `(.attr obj)`
- Type hints: use `#_` annotations on `defn` or `typing` module imports; mypy supports Hy via `hy.lang.ast` annotations
- Threading macros (`->`, `->>`, `as->`, `some->`, `some->>`) preferred over nested calls for readability
- Destructuring with `let` bindings: `(let [[a b & rest] coll] ...)` for sequences, `(let [{:keys [k1 k2] :as m} map] ...)` for dicts
- Test files named `test_*.hy`; run with `poetry run python -m pytest tests/ -v`
- All commands must use `poetry run`; never invoke `hy`, `python`, `pytest`, `mypy`, `ruff`, `hyfmt` directly
- Functional patterns: use `fn`/`lambda` for anonymous functions, `partial` for currying, `comp`/`compose` for function composition
- Transducers via `transducers` library or custom `xform` functions for data pipelines
- Error handling: prefer `Result`/`Either` monads over exceptions for domain logic; exceptions only at infrastructure boundary