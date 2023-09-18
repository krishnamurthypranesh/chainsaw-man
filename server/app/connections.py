import boto3

from app.config import get_db_config

def __get_db():
    ddb = boto3.resource(
        'dynamodb',
        region_name=get_db_config().region,
        endpoint_url=get_db_config().endpoint_url,
    )

    return ddb


def __get_cognito_connection():
    """ Returns the AWS cognito client
    """
    pass


DB_CONNECTION = __get_db()
COGNITO_CONNECTION = __get_cognito_connection()
