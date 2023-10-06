from datetime import datetime

import boto3
from boto3.dynamodb.conditions import Key
from ksuid import Ksuid

from app.config import get_app_config, get_db_config
from app.models import Collection, User

# setup dynamodb
dyn = boto3.resource(
        "dynamodb",
        region_name="ap-south-1",
        endpoint_url="http://localhost:4566",
    )

dyn.create_table(
    TableName="painted_porch",
    AttributeDefinitions=[
        {
            "AttributeName": "primary_key",
            "AttributeType": "S",
        },
        {
            "AttributeName": "secondary_key",
            "AttributeType": "S",
        },
    ],
    KeySchema=[
        {
            "AttributeName": "primary_key",
            "KeyType": "HASH",
        },
        {
            "AttributeName": "secondary_key",
            "KeyType": "RANGE",
        }
    ],
    BillingMode="PROVISIONED",
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5,
    },
    TableClass="STANDARD",
)

pkey = "c1c34d2a-6051-7046-f7db-6c2d06467cc2"

user_id = "usr_2WOlqMxaJlIsYpcS1WPvl647iMt"
col_id = "col_2Vcq8qrgoCUrW9ZudUnIdDRzWS8"

user = User(
    primary_key=pkey,
    secondary_key=pkey,
    public_id=user_id,
    name="pk",
    email="pk96ishere@gmail.com",
    created_at=datetime.now().timestamp(),
    updated_at=datetime.now().timestamp(),
    active_collections={col_id: {"name": "default"}},
    published_entries_count=0,
)

collection = Collection(
    primary_key=pkey,
    secondary_key=col_id,
    name="default",
    template={
        "fields": [
            {"key": "title", "display_name": "Title",},
            {"key": "content", "display_name": "Collection",}
        ]
    },
    active=True,
    published_entries_count=0,
    created_at=datetime.now().timestamp(),
    updated_at=datetime.now().timestamp(),
)

table = dyn.Table("painted_porch")
res = table.put_item(
    Item=user.to_dict(),
)

res = table.put_item(
    Item=collection.to_dict(),
)
