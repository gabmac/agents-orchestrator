"Initialize Uvicorn"

(import sys)
(import pathlib [Path])
(import uvicorn)

;; Add project root to Python path
(setv project-root (str (.resolve (. (Path __file__) parent parent parent parent))))
(when (not (in project-root sys.path))
  (.insert sys.path 0 project-root))


(defn api []
  "Main function to initialize a fastapi application"
  (setv log-level "info"
        reload False)

  (uvicorn.run
    "diplomat.http.http_server:init_api"
    :host "0.0.0.0"
    :port 8000
    :reload reload
    :factory True
    :log_level log-level))


(when (= __name__ "__main__")
  (api))
