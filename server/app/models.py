from datetime import datetime
from typing import Dict

from pydantic import BaseModel, Field

class Base(BaseModel):
    def to_dict(self):
        _d = self.dict(by_alias=True)
        for k in ["created_at", "updated_at"]:
            if k in _d and isinstance(_d[k], datetime):
                _d[k] = int(_d[k].timestamp())
        return _d


class User(Base):
    user_id: str = Field(alias="primary_key")
    secondary_key: str
    name: str
    email: str = Field()
    created_at: datetime
    updated_at: datetime
    active_collections: Dict
    published_entries_count: int


class Collection(Base):
    user_id: str = Field(alias="primary_key")
    collection_id: str = Field(alias="secondary_key")
    name: str
    template: Dict
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
