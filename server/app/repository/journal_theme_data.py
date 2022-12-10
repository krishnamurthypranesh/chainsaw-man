from fastapi import Depends

from app.connections.database import get_journal_themes_data_collection
from app.models.journal_theme_data import JournalThemeData
from app.constants.error import InvalidResourceID


class JournalThemeDataRepo:
    def __init__(self, db):
        self.db = db

    # TODO: implement this method properly
    async def get_journal_theme_data(self):
        pass

    async def get_n_random(self, theme: str, sample_size: int = 1):
        entries = []
        queries = []

        if theme is not None and theme != "":
            queries.append({"$match": {"theme": theme}})

        if sample_size is None or (sample_size is not None and sample_size < 1):
            raise Exception("invalid sample_size")

        queries.append({"$sample": {"size": 1}})

        try:
            cursor = self.db.aggregate(queries)
            async for entry in cursor:
                entries.append(entry)

        except Exception as e:
            print(f"an error occurred when fetching a random record: {e}")

        return entries

    async def find_one(self, entry_id: str):
        if entry_id == "" or entry_id is None:
            raise InvalidResourceID()
        theme_data = await self.db.find_one({"_id": entry_id})
        return theme_data

    async def insert_one(self, data: JournalThemeData):
        new = await self.db.insert_one(data)
        theme_data = await self.find_one(new.inserted_id)
        return theme_data


async def get_journal_theme_data_repo(db=Depends(get_journal_themes_data_collection)):
    return JournalThemeDataRepo(db)
