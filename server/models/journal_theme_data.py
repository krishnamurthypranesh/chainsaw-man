from typing import Union
from bson import ObjectId

from pydantic import BaseModel, Field

from models.base import PyObjectId
from models.journal_theme import JournalTheme

class JournalThemeData(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    created_at: int = None
    updated_at: int = None
    theme: str
    quote: str
    idea_nudge: str
    thought_nudge: str

    class Config:
        allow_population_by_field_name = True
        json_encoders = {ObjectId: str}


class GetJournalThemeDataInput(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    theme: JournalTheme = None
    get_random: bool = True



class GetJournalThemeDataQuery(BaseModel):
    id: PyObjectId
    theme: str = None