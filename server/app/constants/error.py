from app.constants.error_messages import INVALID_RESOURCE_ID


class InvalidResourceID(Exception):
    def __init__(self, errors):
        super().__init__(INVALID_RESOURCE_ID)
