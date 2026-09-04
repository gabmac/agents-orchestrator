"Health Check Router - Functional Style"

(require hyrule [->])
(import fastapi [APIRouter status])
(import diplomat.http.http_in.router [add-route])


(defn health-handler []
  "Health check endpoint handler"
  {"message" "OK"})


(defn create-health-router [#^ str name]
  "Create and configure the health check router"
  (-> (APIRouter
        :prefix f"/{name}"
        :tags [name])
      (add-route "/"
                 health-handler
                 :methods ["GET"]
                 :status_code status.HTTP_200_OK
                 :description "Health check")))
