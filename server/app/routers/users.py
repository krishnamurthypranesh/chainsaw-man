import logging
from typing import List, Optional

from fastapi import APIRouter, Depends


router = APIRouter(prefix="/v1/users")

logger = logging.getLogger(__name__)


@router.post("/sign-up")
def sign_up():
    pass


@router.post("/login")
def login():
    pass