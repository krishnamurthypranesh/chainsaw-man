import logging
from typing import List, Optional

from fastapi import APIRouter, Depends

from app.config import get_app_config
from app.services import UsersService

router = APIRouter(prefix="/v1/users")

logger = logging.getLogger(__name__)
