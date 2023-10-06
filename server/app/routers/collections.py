from datetime import datetime
from functools import wraps
import logging
from typing import List

from fastapi import APIRouter, Depends, status

from app.authn import authorize
from app import constants
from app.exceptions import ObjectAlreadyExists
from app.models import Collection
from app.repo import PaintedPorchRepo
from app.routers.helpers import generate_id, get_current_timestamp
from app.schema.base import AuthToken
from app.schema.routers import CreateCollectionRequest, CreateCollectionResponse

logger = logging.getLogger(__name__)


class CollectionsController:
    def __init__(self, painted_porch_repo: PaintedPorchRepo, cognito_client):
        self.cognito_client = cognito_client
        self.painted_porch_repo = painted_porch_repo
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
        auth_token=Depends(authorize),
    ) -> CreateCollectionResponse:
        for _, v in auth_token.user.active_collections.items():
            if v["name"] == request.name:
                raise ObjectAlreadyExists(
                    status_code=status.HTTP_409_CONFLICT,
                    error_message="An active collection with the given name already exists!"
                )

        collection_id = generate_id(prefix=constants.COLLECTION_PREFIX)
        collection = Collection(
            primary_key=auth_token.user.user_id,
            secondary_key=collection_id,
            name=request.name,
            template=request.template,
            active=request.active,
            published_entries_count=0,
            created_at=get_current_timestamp(),
            updated_at=get_current_timestamp(),
        )

        self.painted_porch_repo.insert_collection(collection)

        self.painted_porch_repo.update_user_active_collection(collection=collection, user=auth_token.user)

        return {
            "collection_id": collection_id,
            "name": request.name,
            "template": request.template,
            "active": request.active,
            "created_at": collection.created_at.isoformat(),
        }

    def list_items(
        self,
        auth_token = Depends(authorize),
    ) -> List:
        return []

    def get():
        pass

    def patch():
        pass
