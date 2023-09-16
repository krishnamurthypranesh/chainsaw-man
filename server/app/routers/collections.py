import logging
from typing import List, Optional

from fastapi import APIRouter, Depends

from app.connections import DB_CONNECTION

router = APIRouter(prefix="/v1/collection")

logger = logging.getLogger(__name__)


@router.post("")
def create() -> List:
    pass


@router.get("")
def list_items() -> List:
    return []


@router.get("/{collection_id}")
def get():
    pass


@router.get("/{collection_id}")
def patch():
    pass


@router.delete("/{collection_id}")
def delete():
    pass
