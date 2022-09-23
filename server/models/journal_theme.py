from re import S
from bson import ObjectId

from pydantic import BaseModel

from models.base import JournalThemeType
from models.journal_theme_data import JournalThemeData


class JournalTheme(BaseModel):
    theme: JournalThemeType
    name: str
    short_description: str
    detailed_description: str
    accent_color: str
    data: JournalThemeData

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
