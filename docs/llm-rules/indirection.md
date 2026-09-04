# LLM Coding Rules — Indirection

These rules are guidelines for LLMs (and humans) generating code in this repository.
They complement the automated semgrep rules in `.semgrep/rules/indirection.yaml`.

## Core Principle

> Do not create functions that just call another function. Call the target directly.

Trivial wrappers, aliases, and pass-through functions add indirection without
providing abstraction, testing seams, or transformation. They make code harder
to read, harder to refactor, and harder to follow.

## Forbidden Patterns

### 1. Trivial forwarding wrapper

```hy
;; BAD — request_id.hy: add-request-id-middleware just forwards
(defn add-request-id-middleware [app]
  (.add_middleware app BaseHTTPMiddleware :dispatch dispatch-request-id))

;; BAD — same logic duplicated with a different name
(defn configure-middleware [app]
  (add-request-id-middleware app))
```

**Fix**: call `(.add_middleware app BaseHTTPMiddleware :dispatch dispatch-request-id)` directly at the call site.

### 2. Single-call wrapper

```hy
;; BAD
(defn get-health [] (health-handler))

;; BAD
(defn empty-list [] (list))

;; BAD
(defn get-user [id] (fetch-user id))
```

**Fix**: call `health-handler`, `list`, `fetch-user` directly.

### 3. `apply`-based pass-through

```hy
;; BAD
(defn call-fn [f & args] (apply f args))

;; BAD
(defn passthrough [f & rest] (apply f rest))
```

**Fix**: call `f` with the arguments directly, or use a higher-order function only when genuinely needed.

### 4. Function aliasing

```hy
;; BAD
(setv gen-id generate-request-id)
(setv new-uuid generate-request-id)

;; BAD
(def add-cors! add-cors)
```

**Fix**: rename at the call site, or use a real binding only when a transformation is added.

## When Wrappers Are Acceptable

A function that calls another function is **not** trivial indirection when it:

- Adds a transformation, validation, or defaulting of arguments
- Returns a different type or shape
- Encapsulates a side effect (logging, metrics, transactions)
- Provides a meaningful name that documents a domain concept
- Has tests that pin down its specific behavior

```hy
;; OK — adds default + logging
(defn get-user [id]
  (log.info f"fetching user {id}")
  (or (.get cache id) (fetch-user id)))

;; OK — adapts a Python method to kebab-case Hy convention
(defn from-wire [wire] (-> wire kebab-case-keys entity))
```

## Rule of Thumb

If deleting the wrapper would change **zero** behavior, **zero** semantics, and
**zero** documentation value at the call site — the wrapper is pure indirection
and should be removed.

## See Also

- `.semgrep/rules/indirection.yaml` — automated detection rules
- AGENTS.md — repository-wide architecture and conventions
