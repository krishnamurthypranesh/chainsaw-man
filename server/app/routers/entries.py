import logging
from typing import List, Optional

from fastapi import APIRouter, Depends


router = APIRouter(prefix="/v1/entry")

logger = logging.getLogger(__name__)


@router.post("")
def create() -> List:
    return {"created": True}


@router.get("")
def list_items() -> List:
    return []


@router.get("/{entry_id}")
def get():
    return None


@router.get("/{entry_id}")
def patch():
    pass


@router.delete("/{entry_id}")
def delete():
    return {"deleted": True}
