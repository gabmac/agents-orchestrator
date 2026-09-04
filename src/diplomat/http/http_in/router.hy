(defn add-route [router path handler #** opts]
  "Add a route to a router and return the router"
  (.add_api_route router path handler #** opts)
  router)
