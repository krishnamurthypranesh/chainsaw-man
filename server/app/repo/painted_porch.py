from typing import Optional

from boto3.dynamodb.conditions import Key, Attr

from app import models
from app.exceptions import ObjectNotFound
from app.repo.base import BaseRepo

class PaintedPorchRepo(BaseRepo):
    def get_user_by_id(self, user_id: str) -> models.User:
        rec = self.table.query(
            KeyConditionExpression=Key("primary_key").eq(user_id) & Key("secondary_key").eq(user_id)
        )

        if len(rec["Items"]) == 0:
            raise ObjectNotFound(obj="user")

        return models.User(**rec["Items"][0])
