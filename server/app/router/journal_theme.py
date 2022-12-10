from fastapi import APIRouter, Depends

from app.api import theme
from app.repository import get_journal_theme_data_repo

JOURNAL_THEME_ROUTER = APIRouter(prefix="/v1/themes")


@JOURNAL_THEME_ROUTER.get("")
async def list_journal_themes(
    journal_theme_data_repo=Depends(get_journal_theme_data_repo),
):
    return await theme.list_themes(journal_theme_data_repo)
