from typing import Union
from bson import ObjectId

from pydantic import BaseModel, Field

from models.journal_theme import JournalTheme
from models.base import JournalThemeType, PyObjectId


class JournalEntryContent(BaseModel):
    quote: str
    idea_nudge: str
    idea: str
    thought_nudge: str
    thought: str


class JournalEntry(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    theme: JournalTheme
    created_at: int = None
    updated_at: int = None
    content: JournalEntryContent

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "theme": {
                    "theme": JournalThemeType.none,
                    "name": "amor fati",
                    "short_description": "",
                    "detailed_description": "",
                    "accent_color": "",
                    "data": {
                        "created_at": 0,
                        "updated_at": 0,
                        "theme": JournalThemeType.none,
                        "quote": "",
                        "idea_nudge": "",
                        "thought_nudge": "",
                    },
                },
                "created_at": 12345678,
                "updated_at": 12345678,
                "content": {
                    "quote": "",
                    "idea_nudge": "",
                    "idea": "",
                    "thought_nudge": "",
                    "thought": "",
                },
            }
        }


class CreateJournalEntryInput(BaseModel):
    theme: JournalTheme
    content: JournalEntryContent


class GetJournalEntryInput(JournalEntry):
    pass


class ListJournalEntryInput(BaseModel):
    created_after: int = None
    created_before: int = None
    theme: Union[JournalThemeType, None]
