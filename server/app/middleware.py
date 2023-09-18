from datetime import datetime

from app.schema.base import AuthToken


async def authorize():
    # get the id from the token
    # get the user from the db
    # return the user object
    from app.models import User
    import ksuid

    uid = str(ksuid.Ksuid())
    return AuthToken(
        user=User(
            primary_key="usr_2VZUfSatXLi6eDvfVtlAJDfhl3T",
            secondary_key="usr_2VZUfSatXLi6eDvfVtlAJDfhl3T",
            name="pk",
            email="pk96ishere@gmail.com",
            created_at=datetime.now(),
            updated_at=datetime.now(),
            active_collections={
                f"tmpl_{ksuid.Ksuid()}": {
                    "name": "default",
                },
            },
            published_entries_count=0,
        )
    )
