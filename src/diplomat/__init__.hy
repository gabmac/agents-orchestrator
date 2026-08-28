;; finance-manager-hy/diplomat/__init__.hy
;; Diplomat Architecture - Public API

(import [finance_manager_hy.diplomat.interceptors
         [RequestIDMiddleware create-request-id-middleware
          RequestIDInterceptor InterceptorChain Interceptor BaseInterceptor
          create-default-interceptors create-interceptor-middleware
          generate-request-id get-request-id set-request-id
          request-id-var]])

;; Re-export for convenience
(__all__ [
  RequestIDMiddleware create-request-id-middleware
  RequestIDInterceptor InterceptorChain Interceptor BaseInterceptor
  create-default-interceptors create-interceptor-middleware
  generate-request-id get-request-id set-request-id
  request-id-var
])
