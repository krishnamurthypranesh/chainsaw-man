import json

from pydantic import BaseModel, validator

from app.models import User

class CustomBase(BaseModel):
    pass


class AuthToken(CustomBase):
    user: User