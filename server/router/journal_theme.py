from fastapi import APIRouter, Depends

from api import Theme
from repository.journal_theme_data import get_journal_theme_data_repo

JOURNAL_THEME_ROUTER = APIRouter()


@JOURNAL_THEME_ROUTER.get("/journals/themes/")
async def list_journal_themes(
    journal_theme_data_repo=Depends(get_journal_theme_data_repo),
):
    return await Theme(journal_theme_data_repo=journal_theme_data_repo).list_themes()
