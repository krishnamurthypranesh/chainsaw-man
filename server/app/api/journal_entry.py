import time
from typing import Dict

from fastapi import Depends
from fastapi import status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

import app.models.journal_entry as entry_models
from schema import CreateJournalEntryInput
from app.repository import get_journal_entry_repo
from app.helpers.journal_entry import get_journal_entry_helper



async def create(
    input: CreateJournalEntryInput,
    journal_entry_repo = Depends(get_journal_entry_repo),
    journal_entry_helper = Depends(get_journal_entry_helper),
    ):
    journal: Dict = {}

    print(f"input.theme: {input.theme}, input.content: {input.content}")

    if not journal_entry_helper.validate_journal_content(input.content):
        print(f"invalid json entry: {input.content}")
        return JSONResponse(
            status_code=status.HTTP_406_NOT_ACCEPTABLE, content=journal
        )

    raw = jsonable_encoder(
        entry_models.JournalEntry(
            created_at=time.time(),
            updated_at=time.time(),
            content=input.content,
            theme=input.theme,
        )
    )
    journal = await journal_entry_repo.insert_one(raw)

    return JSONResponse(status_code=status.HTTP_201_CREATED, content=journal)


async def list_journals(
    _,
    journal_entry_repo = Depends(get_journal_entry_repo),
    ):
    entries = await journal_entry_repo.find()
    return JSONResponse(status_code=status.HTTP_200_OK, content=entries)


async def get(entry_id: str, 
    journal_entry_repo = Depends(get_journal_entry_repo),
):
    journal_entry = await journal_entry_repo.find_one_journal_entry(entry_id)
    return JSONResponse(status_code=status.HTTP_200_OK, content=journal_entry)