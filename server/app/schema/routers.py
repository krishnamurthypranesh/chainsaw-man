from datetime import datetime
import json
from typing import List

from pydantic import validator

from app.schema.base import CustomBase



class CollectionTemplateField(CustomBase):
    key: str
    display_name: str


class CollectionTemplate(CustomBase):
    fields: List[CollectionTemplateField]


class CreateCollectionRequest(CustomBase):
    name: str    
    template: CollectionTemplate
    active: bool = True


class CreateCollectionResponse(CustomBase):
    collection_id: str
    name: str
    template: CollectionTemplate
    active: bool
    created_at: datetime