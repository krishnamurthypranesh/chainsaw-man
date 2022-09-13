from bson import ObjectId

from pydantic import BaseModel, Field

from models.base import PyObjectId


class JournalEntry(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    created_at: int = None
    updated_at: int = None
    content: dict

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "created_at": 12345678,
                "updated_at": 12345678,
                "content": {
                    "amor_fati": {},
                    "premeditatio_malorum": {},
                },
            }
        }


class CreateJournalEntryInput(JournalEntry):
    pass


class GetJournalEntryInput(JournalEntry):
    pass


class ListJournalEntryInput(BaseModel):
    created_after: int = None
    created_before: int = None
    journal_type: str = None
