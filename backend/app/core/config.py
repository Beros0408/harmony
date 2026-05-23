from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # Application
    app_name: str = "Harmony API"
    app_version: str = "0.1.0"
    debug: bool = False
    environment: str = "development"

    # Serveur
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 1

    # Base de données PostgreSQL
    database_url: str = "postgresql+asyncpg://harmony:harmony@localhost:5432/harmony_db"
    database_pool_size: int = 10
    database_max_overflow: int = 20

    # Redis
    redis_url: str = "redis://localhost:6379/0"
    redis_password: str = ""

    # JWT
    secret_key: str = "changeme-in-production-use-openssl-rand-hex-32"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30

    # CORS
    allowed_origins: list[str] = ["http://localhost:3000", "http://localhost:8080"]
    allowed_methods: list[str] = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    allowed_headers: list[str] = ["*"]

    # Rate limiting
    rate_limit_per_minute: int = 60
    rate_limit_auth_per_minute: int = 10

    # Firebase (pour les push notifications)
    firebase_credentials_path: str = "firebase-credentials.json"

    # Google Maps (pour le calcul de trajet)
    google_maps_api_key: str = ""

    # Sécurité
    bcrypt_rounds: int = 12
    password_min_length: int = 8


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
