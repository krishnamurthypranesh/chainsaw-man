from fastapi import Depends, APIRouter

from app.api import journal_theme_data
from app.models import journal_theme_data as journal_theme_data_models
from app.repository.journal_theme_data import get_journal_theme_data_repo

JOURNAL_THEME_DATA_ROUTER = APIRouter(prefix="/v1/theme_data")


@JOURNAL_THEME_DATA_ROUTER.post(
    "", response_model=journal_theme_data_models.JournalThemeData
)
async def get_journal_theme_data(
    input: journal_theme_data_models.GetJournalThemeDataInput,
    journal_theme_data_repo=Depends(get_journal_theme_data_repo),
):
    return await journal_theme_data.get()
