import time
import asyncio
from typing import Dict

from fastapi import status, APIRouter
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

import models.journal_entry as entry_models


class JournalEntry:
    def __init__(
        self,
        journal_entries_repo,
        journal_entries_helper,
    ):

        self.journal_entries_repo = journal_entries_repo
        self.journal_entries_helper = journal_entries_helper

    async def create(self, input: entry_models.CreateJournalEntryInput):
        journal: Dict = {}

        if not self.journal_entries_helper.validate_journal_content(input.content):
            print(f"invalid json entry: {input.content}")
            return JSONResponse(
                status_code=status.HTTP_406_NOT_ACCEPTABLE, content=journal
            )

        raw = jsonable_encoder(
            JournalEntry(
                created_at=time.time(),
                updated_at=time.time(),
                content=input.content,
            )
        )
        new = await self.journal_entries_repo.insert_one(raw)
        journal = await self.journal_entries_repo.find_one({"_id": new.inserted_id})

        return JSONResponse(status_code=status.HTTP_201_CREATED, content=journal)

    async def get(self, entry_id: str):
        journal_entry = await self.journal_entries_repo.find_one_journal_entry(entry_id)
        return JSONResponse(status_code=status.HTTP_200_OK, content=journal_entry)

    async def list_journals(self, input: entry_models.ListJournalEntryInput):
        entries = await self.journal_entries_repo.find()

        return JSONResponse(status_code=status.HTTP_200_OK, content=entries)