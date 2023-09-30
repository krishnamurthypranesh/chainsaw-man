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

uid = "usr_2Vcq8qrgoCUrW9ZudUnIdDRzWS8"
col_id = "col_2Vcq8qrgoCUrW9ZudUnIdDRzWS8"

user = User(
    primary_key=uid,
    secondary_key=uid,
    name="pk",
    email="pk96ishere@gmail.com",
    created_at=datetime.now().timestamp(),
    updated_at=datetime.now().timestamp(),
    active_collections={col_id: {"name": "default"}},
    published_entries_count=0,
)

collection = Collection(
    primary_key=uid,
    secondary_key=col_id,
    name="default",
    template={
        "fields": [
            {"name": "title", "display_name": "Title", "type": "text"},
            {"name": "content", "display_name": "Collection", "type": "text"}
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

# setup cognito-idp
idp = boto3.client("cognito-idp", endpoint_url="http://localhost:4567", region_name="ap-south-1")

user_pool = idp.create_user_pool(PoolName="painted_porch")["UserPool"]
user_pool_client = idp.create_user_pool_client(UserPoolId=user_pool["Id"], ClientName="painted_porch_backend")["UserPoolClient"]

idp.sign_up(
    ClientId=user_pool_client["ClientId"],
    Username="test_user",
    Password="pass@1234",
    UserAttributes=[
        {
            "Name": "email",
            "Value": "test@test.com",
        }
    ],
)
idp.admin_confirm_sign_up(UserPoolId=user_pool["Id"], Username="test_user")
