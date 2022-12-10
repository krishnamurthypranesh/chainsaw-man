from fastapi import Depends

from app.constants import error
from app.models import journal_entry as entry_models
from app.connections.database import get_journal_entries_collection


class JournalEntryRepo:
    def __init__(self, db):
        self.db = db

    async def find_one_journal_entry(self, entry_id: str):
        if entry_id == "" or entry_id is None:
            raise error.InvalidResourceID()

        journal_entry = await self.db.find_one({"_id": entry_id})

        return journal_entry

    async def find(self):
        entries = list()
        cursor = self.db.find({})

        for doc in await cursor.to_list(length=100):  # use pagination
            entries.append(doc)

        return entries

    async def insert_one(self, data: entry_models.JournalEntry):
        new = await self.db.insert_one(data)
        journal = await self.find_one_journal_entry(new.inserted_id)

        return journal


async def get_journal_entry_repo(db=Depends(get_journal_entries_collection)):
    return JournalEntryRepo(db)
