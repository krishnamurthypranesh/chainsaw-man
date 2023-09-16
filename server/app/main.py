from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import (
    collections_router,
    entries_router,
    users_router
)

from app.connections import (
    DB_CONNECTION,
    COGNITO_CONNECTION,
)

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(collections_router)
app.include_router(entries_router)
app.include_router(users_router)

# def lambda_handler(event, context):
    # pass
