from datetime import datetime
import json
from typing import Dict

from pydantic import validator

from app.schema.base import CustomBase


class CreateCollectionRequest(CustomBase):
    name: str    
    template: Dict
    active: bool = True

    @validator("template", pre=True, always=True)
    def validate_template(v):
        """Check if template is a valid json
        """
        try:
            return json.loads(v)
        except:
            raise ValueError("template is not a valid json")


class CreateCollectionResponse(CustomBase):
    collection_id: str
    name: str
    template: str
    active: bool
    created_at: datetime