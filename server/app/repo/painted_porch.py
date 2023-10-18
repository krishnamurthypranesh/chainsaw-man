from typing import List, Optional

from boto3.dynamodb.conditions import Key, Attr

from app import models
from app import constants
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

    def get_collection_by_id(self, user_id: str, collection_id: str) -> models.Collection:
        rec = self.table.query(
            KeyConditionExpression=Key("primary_key").eq(user_id) & Key("secondary_key").eq(collection_id)
        )

        if len(rec["Items"]) == 0:
            raise ObjectNotFound(obj="collection")

        return models.Collection(**rec["Items"][0])

    def get_all_collections_by_params(self, user_id: str, cursor: str, limit: int, scan_forward: bool = True) -> List[models.Collection]:
        key_condition_expression = "primary_key = :primaryKeyValue and begins_with(secondary_key, :collectionIdPrefix)"
        expression_values = {
            ":primaryKeyValue": user_id,
            ":collectionIdPrefix": constants.COLLECTION_PREFIX,
        }

        if len(cursor) > 0:
            op = ">"
            if not scan_forward:
                op = "<"
            key_condition_expression += f" and secondary_key {op} :secondaryKeyValue"
            expression_values[":secondaryKeyValue"] = cursor


        records = self.table.query(
            Select="ALL_ATTRIBUTES",
            ScanIndexForward=scan_forward,
            KeyConditionExpression=key_condition_expression,
            ExpressionAttributeValues=expression_values,
            Limit=limit,
        )

        secondary_key = records.get("LastEvaluatedKey", {}).get("secondary_key")

        return [models.Collection(**rec) for rec in records["Items"]], secondary_key
