import os
import urllib
from typing import Any

from motor import motor_asyncio


def get_client() -> Any:
    uname: str = urllib.parse.quote_plus(os.environ.get("MONGO_INITDB_ROOT_USERNAME"))
    passwd: str = urllib.parse.quote_plus(os.environ.get("MONGO_INITDB_ROOT_PASSWORD"))
    url: str = os.environ.get("MONGO_DB_URL")

    conn_str: str = (
        f"mongodb://{uname}:{passwd}@{url}:27017/?retryWrites=true&w=majority"
    )
    print(conn_str)

    client = motor_asyncio.AsyncIOMotorClient(conn_str)

    return client


def get_journal_entries_collection():
    client = get_client()
    yield getattr(client, "journal_entries")["journal_entries"]
