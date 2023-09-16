import boto3

from app.config import get_db_config

def __get_db():
    ddb = boto3.resource('dynamodb',
                         region_name=get_db_config().region,
                         aws_access_key_id=get_db_config().access_key_id,
                         aws_secret_access_key=get_db_config().secret_access_key)

    return ddb


def __get_cognito_connection():
    """ Returns the AWS cognito client
    """
    pass


DB_CONNECTION = __get_db()
COGNITO_CONNECTION = __get_cognito_connection()
