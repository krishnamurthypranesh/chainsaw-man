import asyncio

from fastapi import status
from fastapi.responses import JSONResponse

from models.journal_theme import JournalTheme

THEMES = [
    {
        "theme": JournalTheme.amor_fati,
        "name": "Amor Fati",
        "short_description": "A Love of Fate",
        "detailed_description": "Treating each and every moment—no matter how challenging—as something to be embraced, not avoided.",
        "accent_color": "#008fb3",
    },
    {
        "theme": JournalTheme.premeditatio_malorum,
        "name": "Premeditatio Malorum",
        "short_description": "Premeditation of Evils",
        "detailed_description": "This is a Stoic exercise of imagining things that could go wrong or be taken away from us",
        "accent_color": "#7575a3",
    },
]


class Theme:
    def __init__(self, journal_theme_data_repo):
        self.journal_theme_data_repo = journal_theme_data_repo

    async def list_themes(self):
        themes = THEMES

        for idx, t in enumerate(themes):
            _td = await self.journal_theme_data_repo.get_n_random(
                theme=t["theme"], sample_size=1
            )
            data = {
                "quote": _td[0]["quote"],
                "idea_nudge": _td[0]["idea_nudge"],
                "thought_nudge": _td[0]["thought_nudge"],
            }

            themes[idx]["data"] = data

        return JSONResponse(status_code=status.HTTP_200_OK, content=themes)
