from datetime import datetime

from ksuid import Ksuid


def generate_id(prefix: str) -> str:
    return f"{prefix}_{Ksuid()}"


def get_current_datetime() -> datetime:
    return datetime.utcnow()


def get_current_timestamp() -> int:
    return int(get_current_datetime().timestamp())
