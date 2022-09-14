from fastapi import APIRouter, Depends

from api import JournalEntry
from api import Theme
from models import journal_entry as journal_entry_models
from repository.journal_entry import get_journal_entry_repo
from helpers.journal_entry_helpers import JournalEntryHelper

JOURNAL_ENTRY_ROUTER = APIRouter()


@JOURNAL_ENTRY_ROUTER.post(
    "/journals/entries/",
)
async def list_journals(
    input: journal_entry_models.ListJournalEntryInput,
    db=Depends(get_journal_entry_repo),
    helper=Depends(JournalEntryHelper),
):
    return await JournalEntry(
        db,
        helper,
    ).list_journals(input)



@JOURNAL_ENTRY_ROUTER.get("/journal/entries/{entry_id}/")
async def get_journal_entry(
    entry_id: str,
    journal_entry_repo=Depends(get_journal_entry_repo),
    helper=Depends(JournalEntryHelper),
):
    return await JournalEntry(journal_entry_repo, helper).get(entry_id)
