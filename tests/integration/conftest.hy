;; finance-manager-hy/tests/integration/conftest.hy
;; Pytest configuration for integration tests.
;;
;; This conftest only applies to tests under tests/integration/. It hosts
;; helpers that integration tests reuse (e.g. TestClient construction)
;; so each test doesn't repeat the arrange step in code, only in the
;; Gherkin comment.

(import fastapi.testclient [TestClient])
(import diplomat.http.http_server [init-api])


(defn make-test-client []
  "Build a FastAPI TestClient wired to the full app (with middleware)."
  (TestClient (init-api)))
