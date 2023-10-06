from datetime import timedelta
import logging.config
import os
from typing import Optional

from pydantic import BaseSettings

from app import constants


env_file = os.environ.get("ENV_FILE", ".env")


# APPLICATION CONFIG
class AppConfig(BaseSettings):
    environment: str

    cognito_user_pool_id: str
    cognito_user_pool_client_id: str
    cognito_user_pool_region: str

    class Config:
        env_file = env_file
        env_file_encoding = "utf-8"
        case_sensitive = False
        env_prefix = "app_"

__APP_CONFIG = AppConfig()


def get_app_config():
    return __APP_CONFIG


class DatabaseConfig(BaseSettings):
    region: str
    access_key_id: str
    secret_access_key: str
    endpoint_url: Optional[str]

    class Config:
        env_file = env_file
        env_file_encoding = "utf-8"
        case_sensitive = False
        env_prefix = "db_"


__DB_CONFIG = DatabaseConfig()


def get_db_config():
    return __DB_CONFIG
