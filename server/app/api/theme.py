import asyncio

from fastapi import status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from app.models.base import JournalThemeType
from app.models.journal_theme import JournalTheme
from app.models.journal_theme_data import JournalThemeData

THEMES = [
    {
        "theme": JournalThemeType.amor_fati,
        "name": "Amor Fati",
        "short_description": "A Love of Fate",
        "detailed_description": "Treating each and every moment—no matter how challenging—as something to be embraced, not avoided.",
        "accent_color": "#008fb3",
    },
    {
        "theme": JournalThemeType.premeditatio_malorum,
        "name": "Premeditatio Malorum",
        "short_description": "Premeditation of Evils",
        "detailed_description": "This is a Stoic exercise of imagining things that could go wrong or be taken away from us",
        "accent_color": "#7575a3",
    },
]


async def list_themes(journal_theme_data_repo):
    themes = []

    for t in THEMES:
        # TODO: perform the random selection per group in the db to speed up call
        _td = await journal_theme_data_repo.get_n_random(
            theme=t["theme"], sample_size=1
        )
        theme_data = jsonable_encoder(
            JournalThemeData(
                theme=t["theme"],
                quote=_td[0]["quote"],
                idea_nudge=_td[0]["idea_nudge"],
                thought_nudge=_td[0]["thought_nudge"],
            )
        )
        theme = jsonable_encoder(
            JournalTheme(
                id=_td[0]["_id"],
                theme=t["theme"],
                name=t["name"],
                short_description=t["short_description"],
                detailed_description=t["detailed_description"],
                accent_color=t["accent_color"],
                data=theme_data,
            )
        )

        themes.append(theme)

    return JSONResponse(status_code=status.HTTP_200_OK, content=themes)
