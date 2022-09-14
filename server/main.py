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

from router import JOURNAL_ENTRY_ROUTER, JOURNAL_THEME_ROUTER, JOURNAL_THEME_DATA_ROUTER

from helpers.journal_entry_helpers import JournalEntryHelper
import models.journal_entry as journal_entry_models

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

journal_entry_helper = JournalEntryHelper()


app.include_router(JOURNAL_ENTRY_ROUTER)

app.include_router(JOURNAL_THEME_ROUTER)

app.include_router(JOURNAL_THEME_DATA_ROUTER)