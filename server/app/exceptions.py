from fastapi import status

class BaseAppException(Exception):
    def __init__(self, status_code: int, error_message: str):
        self.status_code = status_code
        self.error_message = error_message


class ObjectAlreadyExists(BaseAppException):
    pass

class ObjectNotFound(BaseAppException):
    def __init__(self, obj: str):
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, error_message=f"{obj} not found")