import uuid
import asyncio
from datetime import datetime, timezone

from fastapi.encoders import jsonable_encoder

from app.api.theme import THEMES
from app.models.base import PyObjectId
from app.models.journal_entry import JournalEntry, JournalEntryContent
from app.models.journal_theme import JournalTheme
from app.models.journal_theme_data import JournalThemeData
from app.connections.database import _get_client
from app.constants import collection
from app.repository import get_journal_entry_repo
from app.repository import get_journal_theme_data_repo

client = _get_client()
entries_collection = client.journal_entries[collection.JOURNAL_ENTRIES_COLLECTION]
theme_data_collection = client.journal_entries[collection.JOURNAL_THEME_DATA_COLLECTION]

TEST_THOUGHT: str = "Lorem ipsum dolor set amet"
TEST_QUOTE: str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id laoreet lacus. Duis quis mattis. "
TEST_IDEA: str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id laoreet lacus. Duis quis mattis. "
TEST_IDEA_NUDGE: str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id laoreet lacus. Duis quis mattis. "
TEST_THOUGHT_NUDGE: str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id laoreet lacus. Duis quis mattis. "
NOW = datetime.utcnow()

THEME_WITH_DATA = []
ENTRIES = []

for idx, t in enumerate(THEMES):
    theme_data = JournalThemeData(
        theme=t["theme"],
        quote=f"{TEST_QUOTE} {idx+1}",
        idea_nudge=f"{TEST_IDEA_NUDGE} {idx+1}",
        thought_nudge=f"{TEST_THOUGHT_NUDGE} {idx + 1}",
    )
    _id = str(uuid.uuid1())[:12].encode()
    theme = JournalTheme(
        id=PyObjectId(_id),
        theme=t["theme"],
        name=t["name"],
        short_description=t["short_description"],
        detailed_description=t["detailed_description"],
        accent_color=t["accent_color"],
        data=theme_data,
    )

    THEME_WITH_DATA.append(theme)


for i in range(len(THEMES)):
    content = JournalEntryContent(
        quote=f"{TEST_QUOTE} {i}",
        idea_nudge=f"{TEST_IDEA_NUDGE} {i}",
        idea=f"{TEST_IDEA} {i}",
        thought_nudge=f"{TEST_THOUGHT_NUDGE} {i}",
        thought=f"{TEST_THOUGHT} {i}",
    )

    entry = JournalEntry(
        theme=THEME_WITH_DATA[i],
        created_at=int(NOW.timestamp()),
        updated_at=int(NOW.timestamp()),
        content=content,
    )

    ENTRIES.append(entry)


async def insert_data():
    theme_data_repo = await get_journal_theme_data_repo(theme_data_collection)
    entries_repo = await get_journal_entry_repo(entries_collection)

    for entry in ENTRIES:
        journal = await entries_repo.insert_one(jsonable_encoder(entry))
        print(f"{journal['_id']}")

    for theme in THEME_WITH_DATA:
        theme_data = await theme_data_repo.insert_one(jsonable_encoder(theme.data))
        print(f"{theme_data['_id']}")


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(insert_data())
