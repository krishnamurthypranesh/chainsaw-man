from functools import wraps
import logging
from typing import List, Optional

from fastapi import APIRouter, Depends, status

from app.exceptions import ObjectAlreadyExists
from app.middleware import authorize
from app.schema.base import AuthToken
from app.schema.routers import CreateCollectionRequest

logger = logging.getLogger(__name__)


class CollectionsController:
    def __init__(self, painted_porch_repo, cognito_client):
        self.painted_porch_repo = painted_porch_repo
        self.cognito_client = cognito_client
        self.router = APIRouter(prefix="/v1/collections")

    def get_router(self):
        self.register_routes()
        return self.router


    def register_routes(self):
        self.router.add_api_route("", self.create, methods=["POST"])
        self.router.add_api_route("", self.list_items, methods=["GET"])


    def create(
        self,
        request: CreateCollectionRequest,
        token: AuthToken = Depends(authorize),
    ):
        # the user object will be set in the beginning
        # check if a given name already exists in the user object's active templates

        user = self.painted_porch_repo.get_user_by_id(user_id="usr_2VZUfSatXLi6eDvfVtlAJDfhl3T")

        for _, v in token.user.active_collections.items():
            if v["name"] == request.name:
                raise ObjectAlreadyExists(
                    status_code=status.HTTP_409_CONFLICT,
                    error_message="An active collection with the given name already exists!"
                )

        return {}


    def list_items(self) -> List:
        return []


    def get():
        pass


    def patch():
        pass
