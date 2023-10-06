from typing import Optional

from boto3.dynamodb.conditions import Key, Attr

from app import models
from app.exceptions import ObjectNotFound
from app.repo.base import BaseRepo

class PaintedPorchRepo(BaseRepo):
    def __init__(self, db):
        super().__init__(db=db, table_name="painted_porch")

    def get_user_by_id(self, user_id: str) -> models.User:
        rec = self.table.query(
            KeyConditionExpression=Key("primary_key").eq(user_id) & Key("secondary_key").eq(user_id)
        )

        if len(rec["Items"]) == 0:
            raise ObjectNotFound(obj="user")

        return models.User(**rec["Items"][0])

    def insert_collection(self, collection: models.Collection):
        res = self.table.put_item(
            Item=collection.to_dict(),
        )

        return collection

    def update_user_active_collection(self, collection: models.Collection, user: models.User):
        updated_collections = {**user.active_collections, **{collection.collection_id: {"name": collection.name}}}
        response = self.table.update_item(
            Key={
                "primary_key": user.user_id,
                "secondary_key": user.user_id,
            },
            UpdateExpression="set #name = :value",
            ExpressionAttributeNames={
                "#name": "active_collections",
            },
            ExpressionAttributeValues={
                ":value": updated_collections,
            },
            ReturnValues="UPDATED_NEW",
        )

        return response["Attributes"]