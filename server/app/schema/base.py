import json
from typing import Dict, List

from pydantic import BaseModel, validator

from app.models import User


class CustomBase(BaseModel):
    pass


class AuthToken(CustomBase):
    user: User


JWK = Dict[str, str]


class JWKS(CustomBase):
    keys: List[JWK]


class JWTAuthorizationCredentials(CustomBase):
    jwt_token: str
    header: Dict[str, str]
    claims: Dict[str, str]
    signature: str
    message: str