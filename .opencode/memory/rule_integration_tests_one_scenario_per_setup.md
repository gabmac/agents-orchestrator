---
name: integration-tests-one-scenario-per-setup
description: Integration tests follow BDD/Gherkin — one test function per scenario; assertions that share the same setup must be combined into one test, not split across multiple functions.
type: rule
originSessionId: unknown
related: []
---

Integration tests in this project follow BDD with a Gherkin-style structure: each test function models one scenario, and all assertions that share the same setup belong in that single scenario. Do not write two test functions that each repeat the same setup just to assert different things.

**Why:** Splitting one logical scenario across multiple functions duplicates the arrange step, makes the test report noisy, and breaks the BDD read-as-spec contract. A reader should be able to follow one function from setup to all expected outcomes.

**How to apply:**

- When writing an integration test, define the scenario first: a single user-facing behavior with all its observable outcomes (status, body, headers, side effects).
- Put every assertion for that scenario in one `defn` after one shared setup.
- If two tests would have identical arrange steps but different asserts, merge them — they are one scenario.
- Unit tests (no shared I/O setup) are exempt: a separate `defn` per case is fine when the setup is trivial or absent.

**Examples:**

```hy
;; GOOD — one scenario, one test, all assertions for the response
(defn test-health-endpoint []
  "GET /api/health returns 200 with OK payload and x-request-id header."
  (setv client (TestClient (init-api)))
  (setv response (.get client "/api/health"))
  (assert (= response.status_code 200))
  (assert (= (.json response) {"message" "OK"}))
  (assert (in "x-request-id" (.keys response.headers))))

;; BAD — same setup repeated just to check different things
(defn test-health-returns-200 []
  (setv client (TestClient (init-api)))
  (setv response (.get client "/api/health"))
  (assert (= response.status_code 200)))
(defn test-health-has-request-id []
  (setv client (TestClient (init-api)))
  (setv response (.get client "/api/health"))
  (assert (in "x-request-id" (.keys response.headers))))
```
