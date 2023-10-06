from datetime import datetime
from typing import Dict, List

from pydantic import BaseModel, Field

class Base(BaseModel):
    def to_dict(self):
        _d = self.dict(by_alias=True)
        for k in ["created_at", "updated_at"]:
            if k in _d and isinstance(_d[k], datetime):
                _d[k] = int(_d[k].timestamp())
        return _d

    def to_output(self):
        _d = self.dict(by_alias=False)
        for k in ["created_at", "updated_at"]:
            if k in _d and isinstance(_d[k], datetime):
                _d[k] = _d[k].isoformat()
        return _d



class User(Base):
    user_id: str = Field(alias="primary_key")
    secondary_key: str
    public_id: str
    name: str
    email: str = Field()
    created_at: datetime
    updated_at: datetime
    active_collections: Dict
    published_entries_count: int


class CollectionTemplateField(Base):
    key: str
    display_name: str


class CollectionTemplate(Base):
    fields: List[CollectionTemplateField]


class Collection(Base):
    user_id: str = Field(alias="primary_key")
    collection_id: str = Field(alias="secondary_key")
    name: str
    # this is a good candidate for FormIO
    # TODO: replace dictionary with a type that can be serialized to FormIO when returning the response
    template: CollectionTemplate 
    active: bool
    published_entries_count: int
    created_at: datetime
    updated_at: datetime


class Entry(Base):
    user_id: str = Field(alias="primary_key")
    entry_id: str = Field(alias="secondary_key")
    collection_id: str
    content: Dict
    template: Dict
    is_draft: bool
    created_at: datetime
    updated_at: datetime
    published_at: datetime
