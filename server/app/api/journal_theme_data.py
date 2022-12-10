from fastapi import status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from app.models import journal_theme_data


async def get(
    input: journal_theme_data.GetJournalThemeDataInput,
    journal_theme_data_repo,
):
    if input.id is None and input.theme is None and (input.get_random is None or not input.get_random):
        return Exception("invalid resource id")

    theme_data = None

    if input.get_random:
        res = await journal_theme_data_repo.get_n_random(theme=input.theme, sample_size=1)
        if len(res) < 1:
            raise Exception("no records found!")

        theme_data = res[0]
    else:
        theme_data = await journal_theme_data_repo.get()

    return theme_data