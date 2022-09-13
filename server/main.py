import json
import time
import random
import asyncio
from typing import Dict
from bson import ObjectId

from fastapi import FastAPI, status
from pydantic import BaseModel, Field
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware

from database import get_db
from helpers import validate_journal_content
from theme import THEMES

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# mongo client
db = get_db("journal_entries")


class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")


class JournalEntry(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    created_at: int = None
    updated_at: int = None
    content: dict

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "created_at": 12345678,
                "updated_at": 12345678,
                "content": {
                    "amor_fati": {},
                    "premeditatio_malorum": {},
                },
            }
        }


class CreateJournalEntryInput(JournalEntry):
    pass


class GetJournalEntryInput(JournalEntry):
    pass


class ListJournalEntryInput(BaseModel):
    created_after: int = None
    created_before: int = None
    journal_type: str = None


@app.post("/journal/entry/create/")
async def create(input: CreateJournalEntryInput):
    journal: Dict = {}

    if not validate_journal_content(input.content):
        print(f"invalid json entry: {input.content}")
        return JSONResponse(status_code=status.HTTP_406_NOT_ACCEPTABLE, content=journal)

    raw = jsonable_encoder(
        JournalEntry(
            created_at=time.time(),
            updated_at=time.time(),
            content=input.content,
        )
    )
    new = await db["journal_entries"].insert_one(raw)
    journal = await db["journal_entries"].find_one({"_id": new.inserted_id})

    return JSONResponse(status_code=status.HTTP_201_CREATED, content=journal)


@app.get("/journal/entries/{entry_id}/")
async def get(entry_id: str):
    journal_entry = await db["journal_entries"].find_one({"_id": entry_id})
    return JSONResponse(status_code=status.HTTP_200_OK, content=journal_entry)


@app.post("/journals/entries/")
async def list_journals(input: ListJournalEntryInput):
    entries = list()
    cursor = db["journal_entries"].find({})

    for doc in await cursor.to_list(length=100):  # use pagination
        entries.append(doc)

    return JSONResponse(status_code=status.HTTP_200_OK, content=entries)


@app.get("/journals/themes/")
async def list_themes():
    await asyncio.sleep(2)
    return JSONResponse(status_code=status.HTTP_200_OK, content=THEMES)
