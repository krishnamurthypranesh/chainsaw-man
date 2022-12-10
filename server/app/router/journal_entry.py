from typing import List, Optional

from fastapi import APIRouter, Depends

from app.api import journal_entry
from schema import (
    ListJournalEntryInput,
    CreateJournalEntryInput,
    JournalOut,
    ListJournalsOut,
)
from app.repository import get_journal_entry_repo
from app.helpers import get_journal_entry_helper
from app.models.base import JournalThemeType


ROUTER_BASE_URL: str = "/v1/journals"
JOURNAL_ENTRY_ROUTER = APIRouter(prefix=ROUTER_BASE_URL)


@JOURNAL_ENTRY_ROUTER.get("")
async def list_journals(
    created_after: Optional[int] = 0,
    created_before: Optional[int] = 0,
    theme: Optional[JournalThemeType] = None,
    db=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.list_journals(None, db)


@JOURNAL_ENTRY_ROUTER.get(
    "/{uuid}",
    response_model=JournalOut,
)
async def get_journal_entry(
    uuid: str,
    journal_entry_repo=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.get(uuid, journal_entry_repo)


@JOURNAL_ENTRY_ROUTER.post("/", response_model=JournalOut)
async def create(
    input: CreateJournalEntryInput,
    journal_entry_repo=Depends(get_journal_entry_repo),
    helper=Depends(get_journal_entry_helper),
):
    return await journal_entry.create()
