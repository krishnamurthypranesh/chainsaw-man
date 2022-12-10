"""Module containing definitions of models that are used throughout the code at all levels
"""

from typing import Union

from pydantic import BaseModel

from app.models.journal_theme import JournalTheme
from app.models.base import JournalThemeType
from app.models.journal_entry import JournalEntry, JournalEntryContent


class CreateJournalEntryInput(BaseModel):
    theme: JournalTheme
    content: JournalEntryContent


class GetJournalEntryInput(JournalEntry):
    pass


class ListJournalEntryInput(BaseModel):
    created_after: int = 0
    created_before: int = 0
    theme: Union[JournalThemeType, None]


class JournalOut(BaseModel):
    pass


class ListJournalsOut(BaseModel):
    pass
