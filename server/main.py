import json
import time
import random
from bson import ObjectId

from fastapi import FastAPI, status
from pydantic import BaseModel, Field
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware

from server.database import get_db

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
                    "key": "value",
                },
            }
        }


class CreateJournalEntryInput(JournalEntry):
    pass


class GetJournalEntryInput(JournalEntry):
    pass


class ListJournalEntryInput(JournalEntry):
    pass


@app.post("/journalEntry/create/")
async def create(input: CreateJournalEntryInput):
    raw = jsonable_encoder(
        JournalEntry(
            created_at=time.time(),
            updated_at=time.time(),
            content=input.content,
        )
    )
    new = await db["journal_entries"].insert_one(raw)
    saved_entry = await db["journal_entries"].find_one({"_id": new.inserted_id})
    return JSONResponse(status_code=status.HTTP_201_CREATED, content=saved_entry)

@app.get("/journalEntry/{entry_id}/")
async def get(entry_id: int):
    return {"key": "entry_id", "value": f"{entry_id}", "type": "int"}


@app.get("/journalEntries/")
async def list(created_at_gt: int = None, created_at_lt: int = None):
    if (created_at_gt is None) and (created_at_lt is None):
        return []
    return [
        JournalEntry(
            id=round(random.random() * 10, 0),
            created_at=time.time(),
            updated_at=time.time(),
            content=dict(),
        )
    ]
