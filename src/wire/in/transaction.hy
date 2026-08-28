;; finance-manager-hy/wire/in/transaction.hy
;; Wire-in schema (HTTP request - snake_case)

(import [pydantic [BaseModel Field ConfigDict]])
(import [typing [Optional List Dict Any]])
(import [datetime [date]])
(import [decimal [Decimal]])
(import [uuid [UUID]])
(import [finance_manager_hy.entities.transaction [Currency TransactionType]])

(defclass TransactionCreate [BaseModel]
  "Inbound transaction create request."
  account-id : UUID
  amount : Decimal = (Field gt=0)
  currency : Currency = Currency.USD
  type : TransactionType
  description : str = ""
  category-id : Optional[UUID] = None
  tags : List[str] = (Field default_factory=list)
  date : date = (Field default_factory=date.today)
  metadata : Dict[str, Any] = (Field default_factory=dict)
  ;; Transfer
  from-account-id : Optional[UUID] = None
  to-account-id : Optional[UUID] = None
  exchange-rate : Optional[Decimal] = (Field default=None gt=0)
  
  model_config = ConfigDict(
    populate_by_name = true
    use_enum_values = true
  ))

(defclass TransactionUpdate [BaseModel]
  "Inbound transaction update request."
  amount : Optional[Decimal] = (Field default=None gt=0)
  currency : Optional[Currency] = None
  type : Optional[TransactionType] = None
  status : Optional["TransactionStatus"] = None
  description : Optional[str] = None
  category-id : Optional[UUID] = None
  tags : Optional[List[str]] = None
  date : Optional[date] = None
  metadata : Optional[Dict[str, Any]] = None
  exchange-rate : Optional[Decimal] = (Field default=None gt=0)
  
  model_config = ConfigDict(populate_by_name = true))

;; Import for status
(import [finance_manager_hy.entities.transaction [TransactionStatus]])