from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite+aiosqlite:///./local_db.db"

    JWT_SECRET: str = "f0v1AkvK9a9d+xJl9RM8ThWftL/ZIAoJKY0aZECXDdhRI5TUnDldSnOdjLgxgKF+ijPNTr1i30mq0/BZ2YMKQQ=="
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
    )


settings = Settings()
