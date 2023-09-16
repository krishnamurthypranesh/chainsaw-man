from datetime import timedelta
import logging.config
import os
from typing import List

import envyaml
from pydantic import BaseSettings
import yaml

from app import constants

# yml_conf = os.environ.get("APP_CONFIG_YAML", "./config.yml")
env_file = os.environ.get("ENV_FILE", ".env")

# ROOTCONFIG = envyaml.EnvYAML(yml_conf)


# APPLICATION CONFIG
class AppConfig(BaseSettings):
    environment: str

    class Config:
        env_file = env_file
        env_file_encoding = "utf-8"
        case_sensitive = False
        env_prefix = "app_"

__APP_CONFIG = AppConfig()


def get_app_config():
    return __APP_CONFIG


class DatabaseConfig(BaseSettings):
    # connection related settings
    region: str
    access_key_id: str
    secret_access_key: str

    class Config:
        env_file = env_file
        env_file_encoding = "utf-8"
        case_sensitive = False
        env_prefix = "db_"


__DB_CONFIG = DatabaseConfig()


def get_db_config():
    return __DB_CONFIG
