import os
import urllib
from typing import Any

from motor import motor_asyncio

from app.constants import collection
from app.helpers.db_logger import CommandLogger


def _get_client() -> Any:
    uname: str = urllib.parse.quote_plus(os.environ.get("MONGO_INITDB_ROOT_USERNAME"))
    passwd: str = urllib.parse.quote_plus(os.environ.get("MONGO_INITDB_ROOT_PASSWORD"))
    url: str = os.environ.get("MONGO_DB_URL")

    conn_str: str = (
        f"mongodb://{uname}:{passwd}@{url}:27017/?retryWrites=true&w=majority"
    )
    print(conn_str)

    client = motor_asyncio.AsyncIOMotorClient(
        conn_str, event_listeners=[CommandLogger()]
    )

    return client


def get_journal_entries_collection():
    client = _get_client()
    yield getattr(client, "journal_entries")[collection.JOURNAL_ENTRIES_COLLECTION]


def get_journal_themes_data_collection():
    client = _get_client()
    yield getattr(client, "journal_entries")[collection.JOURNAL_THEME_DATA_COLLECTION]
