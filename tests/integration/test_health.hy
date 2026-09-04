"Integration tests for /health endpoint"

(import re)
(import tests.integration.conftest [make-test-client])


(setv uuid7-pattern (re.compile "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"))


(defn test-health-endpoint []
  "GET /api/health returns 200 with OK payload and a uuid7-shaped x-request-id."
  ;; Given: an initialized FastAPI app
  (setv client (make-test-client))
  ;; When: GET /api/health
  (setv response (.get client "/api/health"))
  ;; Then: response is 200 with OK body and uuid7-shaped x-request-id
  (assert (= response.status_code 200))
  (assert (= (.json response) {"message" "OK"}))
  (setv request-id (response.headers.get "x-request-id"))
  (assert request-id "x-request-id header must be present")
  (assert (uuid7-pattern.match request-id)
          f"x-request-id must be a uuid7 string, got {request-id!r}"))
