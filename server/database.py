import os
import urllib
from typing import Any

from motor import motor_asyncio

def get_db(db: str) -> Any:
    uname: str = urllib.parse.quote_plus(os.environ.get('MONGO_INITDB_ROOT_USERNAME'))
    passwd: str = urllib.parse.quote_plus(os.environ.get('MONGO_INITDB_ROOT_PASSWORD'))
    db_name: str = os.environ.get('MONGO_INITDB_DATABASE')
    url: str = os.environ.get('MONGO_DB_URL')

    conn_str: str = f'mongodb://{uname}:{passwd}@{url}:27017/?retryWrites=true&w=majority'
    print(conn_str)

    client = motor_asyncio.AsyncIOMotorClient(conn_str)
    return getattr(client, db)