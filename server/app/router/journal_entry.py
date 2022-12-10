from fastapi import APIRouter, Depends

from app.api import journal_entry
from schema import ListJournalEntryInput, CreateJournalEntryInput
from app.repository import get_journal_entry_repo
from app.helpers import get_journal_entry_helper


ROUTER_BASE_URL: str = "/journals"
JOURNAL_ENTRY_ROUTER = APIRouter(prefix=ROUTER_BASE_URL)
JOURNAL_ENTRY_ROUTER = APIRouter()


@JOURNAL_ENTRY_ROUTER.post("/")
async def list_journals(
    input: ListJournalEntryInput,
    db=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.list()    


@JOURNAL_ENTRY_ROUTER.get("/{entry_id}")
async def get_journal_entry(
    entry_id: str,
    journal_entry_repo=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.get()


@JOURNAL_ENTRY_ROUTER.post("/")
async def create(
    input: CreateJournalEntryInput,
    journal_entry_repo=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.create()
