from fastapi import APIRouter, Depends

from api import Theme
from models import journal_entry as journal_entry_models
from repository.journal_entry import get_journal_entry_repo
from helpers.journal_entry_helpers import JournalEntryHelper

JOURNAL_THEME_ROUTER = APIRouter()

@JOURNAL_THEME_ROUTER.get("/journals/themes/")
async def list_journal_themes():
    return await Theme().list_themes()