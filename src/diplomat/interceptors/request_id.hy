"Request ID Interceptor - Functional Style"

(require hyrule [->])
(import uuid6 [uuid7])
(import fastapi [FastAPI Request Response])
(import starlette.middleware.base [BaseHTTPMiddleware])


(defn :async dispatch-request-id [request call-next]
  "Process request and add x-request-id to response headers"
  (setv response (-> request
                    call-next
                    await))
  (.setdefault response.headers "x-request-id" (str (uuid7)))
  response)
