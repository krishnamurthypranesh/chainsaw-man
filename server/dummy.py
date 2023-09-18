from datetime import datetime

import boto3
from boto3.dynamodb.conditions import Key
from ksuid import Ksuid

from app.config import get_app_config, get_db_config
from app.models import User


uid = "usr_" + str(Ksuid())
col_id = "col_" + str(Ksuid())
raw = dict(
    primary_key=uid,
    secondary_key=uid,
    name="pk",
    email="pk96ishere@gmail.com",
    created_at=datetime.now().timestamp(),
    updated_at=datetime.now().timestamp(),
    active_collections={col_id: {"name": "default"}},
    published_entries_count=0,
)

u = User(**raw)

dyn = boto3.resource(
        "dynamodb",
        region_name="ap-south-1",
        endpoint_url="http://localhost:4566",
    )

table = dyn.Table("painted_porch")

# res = table.put_item(
#     Item=u.to_dict(),
# )
