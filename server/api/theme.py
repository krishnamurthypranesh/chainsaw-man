import asyncio

from fastapi import status
from fastapi.responses import JSONResponse

THEMES = [
    {
        "theme": "amor fati",
        "name": "Amor Fati",
        "short_description": "A Love of Fate",
        "detailed_description": "Treating each and every moment—no matter how challenging—as something to be embraced, not avoided.",
        "accent_color": "#008fb3",
    },
    {
        "theme": "premeditatio malorum",
        "name": "Premeditatio Malorum",
        "short_description": "Premeditation of Evils",
        "detailed_description": "This is a Stoic exercise of imagining things that could go wrong or be taken away from us",
        "accent_color": "#7575a3",
    },
]


class Theme:
    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs

    async def list_themes(self):
        await asyncio.sleep(2)
        return JSONResponse(status_code=status.HTTP_200_OK, content=THEMES)
