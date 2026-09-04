---
name: integration-tests-gherkin-comments
description: Integration test functions annotate `;; When` and `;; Then` phases with a short description of the action taken and the outcome asserted; `;; Given` is only emitted when the scenario has actual setup code beyond imports.
type: rule
originSessionId: unknown
related: [integration-tests-one-scenario-per-setup]
---

Integration tests in this project annotate the act and assert phases of a scenario with self-describing Gherkin comments. The `;; When` line names the action taken; the `;; Then` line names the outcome asserted. The `;; Given` marker is only emitted when the scenario contains real setup code (more than imports or module-level constants) — if the arrange step is empty, skip it rather than emit a bare marker.

**Why:** Bare `;; When` / `;; Then` markers only say "something happened, then something was checked" — they don't help a reader locate the action or the outcome. A short description of the action and the assertion turns the comment into a navigation aid: the reader can find the line that triggers behavior (the `;; When` line) and the line that pins behavior (the `;; Then` line) without re-reading the code. Skipping `;; Given` when there is no setup avoids the noise of a marker above a blank line.

**How to apply:**

- **`;; When` is required and self-describing.** Write it as `;; When: <action>` where `<action>` is a verb phrase that matches the line below. Example: `;; When: GET /api/health` above `(setv response (.get client "/api/health"))`.
- **`;; Then` is required and self-describing.** Write it as `;; Then: <outcome>` where `<outcome>` is a noun phrase or short sentence that names the assertion. Example: `;; Then: response is 200 with OK body and uuid7-shaped x-request-id` above the assertion block.
- **`;; Given` is conditional.** Emit it only if the scenario has at least one arrange line of substance (a `setv`, a fixture call, seeded data). If the only thing above `;; When` is a comment or an import, skip `;; Given` entirely. When you do emit it, write `;; Given: <what is set up>` — same self-describing style.
- **One `;; When`, one `;; Then` per test function.** If you want a second `;; When`, the test is two scenarios — split or merge.
- **Multiple assertions under the same `;; Then`.** They share the marker; don't repeat it per assertion.
- **Hy comments use `;`, not `#`.** The `Given`/`When`/`Then` keywords are Gherkin; `;` is the host-language comment syntax.

**Examples:**

```hy
;; GOOD — Given has real setup, When/Then are self-describing
(defn test-health-endpoint []
  "GET /api/health returns 200 with OK payload and a uuid7-shaped x-request-id."
  ;; Given: an initialized app
  (setv client (TestClient (init-api)))
  ;; When: GET /api/health
  (setv response (.get client "/api/health"))
  ;; Then: response is 200 with OK body and uuid7-shaped x-request-id
  (assert (= response.status_code 200))
  (assert (= (.json response) {"message" "OK"}))
  (assert (uuid7-pattern.match (response.headers.get "x-request-id"))))

;; GOOD — no real setup, so ;; Given is omitted
(defn test-no-auth-required []
  "GET /api/public returns 200 without auth headers."
  ;; When: GET /api/public
  (setv response (.get (TestClient (init-api)) "/api/public"))
  ;; Then: response is 200
  (assert (= response.status_code 200)))

;; BAD — bare markers, no information
(defn test-health-endpoint []
  "GET /api/health returns 200 with OK payload and a uuid7-shaped x-request-id."
  ;; Given
  (setv client (TestClient (init-api)))
  ;; When
  (setv response (.get client "/api/health"))
  ;; Then
  (assert (= response.status_code 200))
  (assert (= (.json response) {"message" "OK"}))
  (assert (uuid7-pattern.match (response.headers.get "x-request-id"))))
```

Pair with `[[integration-tests-one-scenario-per-setup]]`: one scenario = one function = one self-describing `;; When` + one self-describing `;; Then`, with `;; Given` only when setup is non-trivial.
