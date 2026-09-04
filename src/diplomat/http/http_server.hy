"Application Settings - Functional Style"

(require hyrule [->])
(import fastapi [FastAPI APIRouter])
(import fastapi.middleware.cors [CORSMiddleware])

(import diplomat.http.http_in.health [create-health-router])
(import diplomat.interceptors [add-request-id-middleware])


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


(defn add-cors [app]
  "Add CORS middleware to app"
  (.add_middleware app
                   CORSMiddleware
                   :allow_origins ["*"]
                   :allow_credentials True
                   :allow_methods ["*"]
                   :allow_headers ["*"])
  app)


(defn add-router [app router]
  "Include a router in the app"
  (.include_router app router)
  app)


(defn init-api []
  "Initialize the full API application"
  (setv health-router (create-health-router "health"))
  (setv api-router (create-api-router health-router))

  (-> (create-app :title "Agents Manager"
                  :description "Agents Manager")
      (add-cors)
      (add-request-id-middleware)
      (add-router api-router)))
