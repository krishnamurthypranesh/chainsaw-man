from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse


from app.connections import (
    DB_CONNECTION,
    COGNITO_CONNECTION,
)
from app.exceptions import BaseAppException
from app.repo import PaintedPorchRepo
from app.routers import (
    CollectionsController,
    entries_router,
    users_router
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

collections_controller = CollectionsController(
    painted_porch_repo=PaintedPorchRepo(
        db=DB_CONNECTION,
        table_name="painted_porch", # move to constants
    ),
    cognito_client=None,
)

app.include_router(collections_controller.get_router())
app.include_router(entries_router)
app.include_router(users_router)


def exception_response_builder(exc):
    response = {"details": exc.error_message}
    if hasattr(exc, "extras"):
        for key, value in exc.extra.items():
            response[key] = value

    return JSONResponse(status_code=exc.status_code, content=response)


@app.exception_handler(RequestValidationError)
async def request_validation_error_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content=str(exc),
    )


@app.exception_handler(BaseAppException)
def handle_base_exception(request: Request, exc: BaseAppException):
    return exception_response_builder(exc)

# def lambda_handler(event, context):
    # pass
