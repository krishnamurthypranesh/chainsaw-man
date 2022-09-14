from fastapi import Depends, APIRouter
from api import JournalThemeData
from models import journal_theme_data as journal_theme_data_models
from repository.journal_theme_data import get_journal_theme_data_repo

JOURNAL_THEME_DATA_ROUTER = APIRouter()

@JOURNAL_THEME_DATA_ROUTER.post("/journals/themes/data/", response_model=journal_theme_data_models.JournalThemeData)
async def get_journal_theme_data(input: journal_theme_data_models.GetJournalThemeDataInput,
    journal_theme_data_repo=Depends(get_journal_theme_data_repo)
):
    return await JournalThemeData(journal_theme_data_repo).get(input)