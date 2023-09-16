import logging
from typing import List, Optional

from fastapi import APIRouter, Depends

from app.connections import DB

router = APIRouter(prefix="/v1/entry")

logger = logging.getLogger(__name__)


@router.post("")
def create() -> List:
    pass


@router.get("")
def list_items() -> List:
    return []


@router.get("/{entry_id}")
def get():
    pass


@router.get("/{entry_id}")
def patch():
    pass


@router.delete("/{entry_id}")
def delete():
    pass
