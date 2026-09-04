"Application Settings - Functional Style"

(require hyrule [->])
(import fastapi [FastAPI APIRouter])
(import fastapi.middleware.cors [CORSMiddleware])
(import starlette.middleware.base [BaseHTTPMiddleware])

(import diplomat.http.http_in.health [create-health-router])
(import diplomat.interceptors [dispatch-request-id])


(defn create-api-router [#* routers]
  "Create the main API router and include all sub-routers"
  (setv main-router (APIRouter :prefix "/api"))
  (for [router routers]
    (.include_router main-router router))
  main-router)


(defn create-app [#** opts]
  "Create a new FastAPI application"
  (FastAPI
    :title (.get opts "title" "API")
    :description (.get opts "description" "API")
    :openapi_url (.get opts "openapi_url" "/openapi.json")
    :docs_url (.get opts "docs_url" "/docs")
    :redoc_url (.get opts "redoc_url" "/redoc")))


(defn init-api []
  "Initialize the full API application"
  (setv app (create-app :title "Agents Manager"
                        :description "Agents Manager"))
  (.add_middleware app
                   CORSMiddleware
                   :allow_origins ["*"]
                   :allow_credentials True
                   :allow_methods ["*"]
                   :allow_headers ["*"])
  (.add_middleware app BaseHTTPMiddleware :dispatch dispatch-request-id)
  (.include_router app (create-api-router (create-health-router "health")))
  app)
