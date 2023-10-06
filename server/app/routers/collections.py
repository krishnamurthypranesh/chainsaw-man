from datetime import datetime
from functools import wraps
import logging
from typing import List, Optional

from fastapi import APIRouter, Depends, status

from app.authn import authorize
from app import constants
from app.exceptions import BadPaginationParameter, ObjectAlreadyExists
from app.models import Collection
from app.repo import PaintedPorchRepo
from app.routers import helpers 
from app.schema.base import AuthToken
from app.schema.routers import CollectionOut, CreateCollectionRequest, CreateCollectionResponse, ListCollectionResponse

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
        self.router.add_api_route("/{gid}", self.get, methods=["GET"])

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

        collection_id = helpers.generate_id(prefix=constants.COLLECTION_PREFIX)
        now = helpers.get_current_timestamp()
        collection = Collection(
            primary_key=auth_token.user.user_id,
            secondary_key=collection_id,
            name=request.name,
            template=request.template,
            active=request.active,
            published_entries_count=0,
            created_at=now,
            updated_at=now,
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

    def get(
        self,
        gid: str,
        auth_token = Depends(authorize),
    ):
        collection = self.painted_porch_repo.get_collection_by_id(user_id=auth_token.user.user_id, collection_id=gid)
        return collection.to_output()

    def list_items(
        self,
        next_cursor: Optional[str] = None,
        prev_cursor: Optional[str] = None,
        limit: int = 20,
        auth_token = Depends(authorize),
    ) -> ListCollectionResponse:
        # for now, the list api will just accept the limit and next_cursor parameters
        if limit > constants.MAX_PAGINATION_LIMIT:
            limit = constants.MAX_PAGINATION_LIMIT

        conditions = [
            next_cursor is not None,
            prev_cursor is not None,
        ]

        if all(conditions):
            raise BadPaginationParameter()

        scan_forward = True
        cursor = ""
        if next_cursor is not None:
            cursor = next_cursor

        if prev_cursor is not None:
            cursor = prev_cursor
            scan_forward = False

        # the response will be a list of collections of the given size (provided the list is less than 1MB in size)
        records, key = self.painted_porch_repo.get_all_collections_by_params(
            user_id=auth_token.user.user_id,
            cursor=cursor,
            scan_forward=scan_forward,
            limit=limit,
        )

        ret_val = []
        for rec in records:
            ret_val.append(
                CollectionOut(
                    collection_id=rec.collection_id,
                    name=rec.collection_id,
                    template=rec.template,
                    active=rec.active,
                    created_at=rec.created_at.isoformat(),
                )
            )

        if scan_forward:
            prev_cursor = next_cursor
            next_cursor = key
        else:
            next_cursor = prev_cursor
            prev_cursor = key

        return ListCollectionResponse(
            next_cursor=next_cursor,
            prev_cursor=prev_cursor,
            limit=limit,
            records=ret_val,
        )

    def patch():
        pass
