import boto3
from boto3.resources import ServiceResource

from app.config import get_db_config

def __get_db() -> ServiceResource:
    ddb = boto3.resource('dynamodb',
                         region_name=get_db_config().DB_REGION_NAME,
                         aws_access_key_id=get_db_config().DB_ACCESS_KEY_ID,
                         aws_secret_access_key=get_db_config().DB_SECRET_ACCESS_KEY)

    return ddb


def __get_cognito_client() -> ServiceResource:
    """ Returns the AWS cognito client
    """
    pass

DB = __get_db()
COGNITO_CLIENT = __get_cognito_client()
