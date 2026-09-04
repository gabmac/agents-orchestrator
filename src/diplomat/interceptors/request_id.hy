"Request ID Interceptor - Functional Style"

(require hyrule [->])
(import uuid [uuid4])
(import fastapi [FastAPI Request Response])
(import starlette.middleware.base [BaseHTTPMiddleware])

(defn :async dispatch-request-id [request call-next]
  "Process request and add x-request-id to response headers"
  (setv request-id (str (uuid4)))
  (setv response (-> request
                    call-next
                    await))
  (.setdefault response.headers "x-request-id" request-id)
  response)


(defn add-request-id-middleware [app]
  "Add request ID middleware to FastAPI app"
  (.add_middleware app BaseHTTPMiddleware :dispatch dispatch-request-id)
  app)
