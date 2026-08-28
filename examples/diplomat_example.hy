;; finance-manager-hy/examples/diplomat_example.hy
;; Example: Using Diplomat Architecture in Finance Manager
;; This demonstrates the wire-in/wire-out/wire-db/entity pattern

(import [typing [Dict List Optional Any]])
(import [uuid [UUID uuid7]])
(import [datetime [datetime date]])
(import [decimal [Decimal]])
(import [pydantic [BaseModel Field]])
(import [finance_manager_hy.diplomat [schema-select loose-schema strict-schema
                                        assoc-some wire-schema required-key optional-key
                                        kebab-key->snake-str snake-str->kebab-key
                                        update-keys add-namespace add-namespaces-to-dict
                                        to-db-format from-db-format
                                        BaseWireAdapter create-simple-adapter
                                        register-adapter get-adapter]])

;; ============================================================================
;; 1. DEFINE WIRE SCHEMAS (Inbound, Outbound, Database)
;; ============================================================================

;; Wire-in schema (HTTP request body - snake_case keys)
(def transaction-wire-in-skeleton
  {:account-id UUID
   :amount Decimal
   :currency str
   :type str
   :description str
   :category-id UUID
   :tags List[str]
   :date date
   :metadata Dict[str, Any]
   ;; Transfer fields
   :from-account-id UUID
   :to-account-id UUID
   :exchange-rate Decimal})

(def transaction-wire-in-schema
  (wire-schema transaction-wire-in-skeleton
    #{"account-id" "amount" "currency" "type"}           ; required
    #{"description" "category-id" "tags" "date" "metadata"  ; optional
      "from-account-id" "to-account-id" "exchange-rate"}
    #{"category-id" "from-account-id" "to-account-id" "exchange-rate"}  ; nullable
    False))  ; strict

;; Wire-out schema (HTTP response - snake_case keys with extra fields)
(def transaction-wire-out-skeleton
  (merge transaction-wire-in-skeleton
    {:id UUID
     :status str
     :posted-at datetime
     :created-at datetime
     :updated-at datetime}))

(def transaction-wire-out-schema
  (wire-schema transaction-wire-out-skeleton
    #{"id" "account-id" "amount" "currency" "type" "status"
      "created-at" "updated-at"}                           ; required
    #{"description" "category-id" "tags" "date" "metadata"
      "from-account-id" "to-account-id" "exchange-rate"
      "posted-at"}                                         ; optional
    #{"category-id" "from-account-id" "to-account-id" "exchange-rate" "posted-at"}  ; nullable
    False))

;; Wire-db schema (Database - snake_case with namespace prefix)
(def transaction-wire-db-skeleton
  {:id UUID
   :account_id UUID
   :amount Decimal
   :currency str
   :type str
   :status str
   :description str
   :category_id UUID
   :tags List[str]
   :date date
   :posted_at datetime
   :created_at datetime
   :updated_at datetime
   :metadata Dict[str, Any]
   :from_account_id UUID
   :to_account_id UUID
   :exchange_rate Decimal})

(def transaction-wire-db-schema
  (wire-schema transaction-wire-db-skeleton
    #{"id" "account_id" "amount" "currency" "type" "status"
      "created_at" "updated_at"}                           ; required
    #{"description" "category_id" "tags" "date" "metadata"
      "from_account_id" "to_account_id" "exchange_rate"
      "posted_at"}                                         ; optional
    #{"category_id" "from_account_id" "to_account_id" "exchange_rate" "posted_at"}  ; nullable
    False))

;; ============================================================================
;; 2. DEFINE ENTITY (Internal domain model - kebab-case keys)
;; ============================================================================

(def transaction-entity-skeleton
  {:id UUID
   :account-id UUID
   :amount Decimal
   :currency str
   :type str
   :status str
   :description str
   :category-id UUID
   :tags List[str]
   :date date
   :posted-at datetime
   :created-at datetime
   :updated-at datetime
   :metadata Dict[str, Any]
   :from-account-id UUID
   :to-account-id UUID
   :exchange-rate Decimal})

;; ============================================================================
;; 3. CREATE ADAPTER
;; ============================================================================

;; Using the simple adapter factory
(def transaction-adapter
  (create-simple-adapter
    ;; Entity class (using dict for example)
    dict
    :wire-in-schema transaction-wire-in-schema
    :wire-out-schema transaction-wire-out-schema
    :wire-db-schema transaction-wire-db-schema
    :namespace "transactions"
    :custom-in (fn [data id as-of-time]
                 ;; Build entity from wire-in data
                 (assoc-some
                   {:id id
                    :account-id (get data "account-id")
                    :amount (get data "amount")
                    :currency (get data "currency")
                    :type (get data "type")
                    :status "pending"
                    :description (get data "description" "")
                    :category-id (get data "category-id")
                    :tags (get data "tags" [])
                    :date (get data "date" (date.today))
                    :metadata (get data "metadata" {})
                    :created-at as-of-time
                    :updated-at as-of-time}
                   :from-account-id (get data "from-account-id")
                   :to-account-id (get data "to-account-id")
                   :exchange-rate (get data "exchange-rate")))
    :custom-out (fn [entity]
                 ;; Convert entity to wire-out (kebab-case to snake_case)
                 (update-keys entity kebab-key->snake-str))
    :custom-db (fn [entity]
                 ;; Convert entity to wire-db (add namespace, convert values)
                 (let [snake (update-keys entity kebab-key->snake-str)
                       db-format (to-db-format snake)]
                   (add-namespaces-to-dict db-format "transactions")))))

;; Register the adapter
(register-adapter dict transaction-adapter)

;; ============================================================================
;; 4. USAGE EXAMPLES
;; ============================================================================

(defn example-usage []
  "Demonstrate the diplomat architecture flow."
  
  ;; Simulate incoming HTTP request (snake_case keys)
  (let [http-request-body
        {:account_id (uuid7)
         :amount (Decimal "100.50")
         :currency "USD"
         :type "income"
         :description "Salary deposit"
         :category_id (uuid7)
         :tags ["salary" "monthly"]
         :date (date.today)
         :metadata {:source "payroll"}}]
    
    (print "=== HTTP Request (snake_case) ===")
    (print http-request-body)
    
    ;; 1. WIRE-IN -> ENTITY (snake_case -> kebab-case, build entity)
    (let [entity (transaction-adapter.wire-in->entity http-request-body
                                                      :id (uuid7)
                                                      :as-of-time (datetime.now))]
      
      (print "\n=== Entity (kebab-case, internal) ===")
      (print entity)
      
      ;; 2. ENTITY -> WIRE-OUT (kebab-case -> snake_case for HTTP response)
      (let [http-response (transaction-adapter.entity->wire-out entity)]
        
        (print "\n=== HTTP Response (snake_case) ===")
        (print http-response)
        
        ;; 3. ENTITY -> WIRE-DB (kebab-case -> snake_case + namespace + DB formats)
        (let [db-record (transaction-adapter.entity->wire-db entity)]
          
          (print "\n=== Database Record (namespaced snake_case) ===")
          (print db-record)
          
          ;; 4. WIRE-DB -> ENTITY (reverse for reading from DB)
          (let [restored-entity (transaction-adapter.wire-db->entity db-record)]
            
            (print "\n=== Restored Entity ===")
            (print restored-entity)
            
            ;; Verify round-trip
            (assert (= entity restored-entity))
            (print "\n✓ Round-trip successful!"))))))

;; ============================================================================
;; 5. FASTAPI INTEGRATION EXAMPLE
;; ============================================================================

(import [fastapi [FastAPI APIRouter Depends HTTPException]])
(import [finance_manager_hy.diplomat.interceptors [create-default-interceptors
                                                    create-interceptor-middleware
                                                    SchemaValidationInterceptor]])

(defn create-transaction-router [adapter: BaseWireAdapter] -> APIRouter
  "Create FastAPI router with diplomat architecture."
  
  (let [router (APIRouter prefix="/transactions" tags=["transactions"])]
    
    ;; POST /transactions - Create transaction
    (router.post "" response_model=Dict[str, Any] status_code=201)
    (async fn [request-body: Dict[str, Any]] -> Dict[str, Any]
      (try
        ;; wire-in -> entity
        (let [entity (adapter.wire-in->entity request-body
                                                :id (uuid7)
                                                :as-of-time (datetime.now))]
          ;; Save to database (would use repository here)
          ;; db.save(adapter.entity->wire-db(entity))
          
          ;; Return wire-out
          (adapter.entity->wire-out entity))
        (except Exception e
          (raise HTTPException status_code=400 detail=(str e))))))
  
  ;; GET /transactions/{id} - Get transaction
  (router.get "/{transaction_id}" response_model=Dict[str, Any])
  (async fn [transaction_id: UUID] -> Dict[str, Any]
    ;; Simulate reading from database
    (let [db-record {:transactions/id transaction_id
                     :transactions/account_id (uuid7)
                     :transactions/amount (Decimal "100.50")
                     :transactions/currency "USD"
                     :transactions/type "income"
                     :transactions/status "pending"
                     :transactions/description "Salary deposit"
                     :transactions/created_at (datetime.now)
                     :transactions/updated_at (datetime.now)}]
      
      ;; wire-db -> entity -> wire-out
      (-> db-record
          (adapter.wire-db->entity)
          (adapter.entity->wire-out))))
  
  router)

;; ============================================================================
;; 6. SCHEMA VALIDATION INTERCEPTOR EXAMPLE
;; ============================================================================

(defn create-app-with-diplomat [] -> FastAPI
  "Create FastAPI app with diplomat interceptors."
  
  (let [app (FastAPI title="Finance Manager" version="0.1.0")
        interceptors (create-default-interceptors
                      :debug True
                      :validate-requests True
                      :validate-responses False
                      :request-schemas {"/transactions": transaction-wire-in-schema}
                      :response-schemas {"/transactions": transaction-wire-out-schema})]
    
    ;; Add interceptor middleware
    (let [middleware-class (create-interceptor-middleware interceptors)]
      (app.add_middleware middleware-class))
    
    ;; Add routes
    (let [router (create-transaction-router transaction-adapter)]
      (app.include_router router))
    
    app))

;; ============================================================================
;; 7. RUN EXAMPLE
;; ============================================================================

(if (= __name__ "__main__")
  (do
    (print "Running Diplomat Architecture Example\n")
    (example-usage)
    (print "\nExample completed successfully!")))