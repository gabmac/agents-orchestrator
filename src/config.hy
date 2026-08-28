;; finance-manager-hy/config.hy
;; Configuration - pure functions for settings

(import [pydantic_settings [BaseSettings SettingsConfigDict]])
(import [pydantic [Field field_validator]])
(import [typing [Optional]])
(import [pathlib [Path]])

(defclass Settings [BaseSettings]
  "Application settings loaded from environment variables."
  
  app-name : str = (Field default="finance-manager-hy" description="Application name")
  version : str = (Field default="0.1.0" description="Application version")
  environment : str = (Field default="development" description="Environment")
  debug : bool = (Field default=True description="Debug mode")
  
  ;; Database
  database-url : str = (Field default="postgresql+asyncpg://postgres:postgres@localhost:5432/finance_manager" description="Database connection URL")
  database-echo : bool = (Field default=False description="Echo SQL queries")
  database-pool-size : int = (Field default=5 description="Connection pool size")
  database-max-overflow : int = (Field default=10 description="Max overflow connections")
  
  ;; API
  api-host : str = (Field default="0.0.0.0" description="API host")
  api-port : int = (Field default=8000 description="API port")
  api-reload : bool = (Field default=True description="Auto-reload on changes")
  api-workers : int = (Field default=1 description="Number of workers")
  
  ;; Security
  secret-key : str = (Field default="dev-secret-change-in-production" description="Secret key for JWT")
  algorithm : str = (Field default="HS256" description="JWT algorithm")
  access-token-expire-minutes : int = (Field default=30 description="Access token expiration")
  
  ;; Logging
  log-level : str = (Field default="INFO" description="Log level")
  log-format : str = (Field default="json" description="Log format: json, text")
  
  model_config = SettingsConfigDict(
    env_file = ".env"
    env_file_encoding = "utf-8"
    case_sensitive = false
    extra = "ignore"
  )
  
  @field_validator("database-url")
  @classmethod
  def validate_database_url [cls v: str] -> str
    (if (not (any (v.startswith prefix) (for [prefix ["postgresql://" "postgresql+asyncpg://" "sqlite://" "sqlite+aiosqlite://"]] prefix)))
      (raise ValueError "Database URL must be PostgreSQL or SQLite")
      v))

;; Global settings cache
(def _settings-cache None)

(defn get-settings [] -> Settings
  "Get or create settings instance (cached)."
  (global _settings-cache)
  (if (is _settings-cache None)
    (do
      (setv _settings-cache (Settings))
      _settings-cache)
    _settings-cache))

(defn reset-settings-cache [] -> None
  "Reset settings cache (for testing)."
  (global _settings-cache)
  (setv _settings-cache None))