import os
import tempfile
from unittest import mock

import boto3
from jose import jwk, jwt
from jose.utils import base64url_decode
from moto import mock_cognitoidp
import pytest
import requests


def get_hmac_key(token: str, jwks):
    kid = jwt.get_unverified_header(token).get("kid")
    for key in jwks.get("keys", []):
        if key.get("kid") == kid:
            return key


# @pytest.fixture(scope="session", autouse=True)
def setup_aws_credentials_file():
    with tempfile.NamedTemporaryFile(mode="w") as fp:
        fp.name = "~/.aws/credentials" 
        fp.write("[default]")
        fp.write("aws_access_key_id=AKIAIOSFODNN7EXAMPLE")
        fp.write("aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
        yield


# @pytest.fixture(scope="session", autouse=True)
def setup_aws_credentials():
    with mock.patch.dict(os.environ, {
        "AWS_PROFILE": "default",
        "AWS_DEFAULT_REGION": "ap-south-1",
    }):
        yield

@pytest.fixture(scope="session", autouse=True)
def setup_cognito_resources(request):
    with mock_cognitoidp():
        class _Cognito:
            pass

        idp = boto3.client("cognito-idp", region_name="ap-south-1")

        # create a user pool
        user_pool_id = idp.create_user_pool(PoolName="test-user-pool")["UserPool"]["Id"]

        # create a user pool client
        user_pool_client = idp.create_user_pool_client(UserPoolId=user_pool_id, ClientName="painted-porch-backend")["UserPoolClient"]


        # sigup and verify user
        idp.sign_up(
            ClientId=user_pool_client["ClientId"],
            Username="test_user",
            Password="qwertY!23456",
            UserAttributes=[
                {
                    "Name": "email",
                    "Value": "pk96ishere@gmail.com",
                },
                {
                    "Name": "custom:user_id",
                    "Value": "usr_2Vcq8qrgoCUrW9ZudUnIdDRzWS8"
                }
            ],
        )
        idp.admin_confirm_sign_up(UserPoolId=user_pool_id, Username="test_user")


        # create a user in dynamo db

        jwks_url = f"https://cognito-idp.ap-south-1.amazonaws.com/{user_pool_id}/.well-known/jwks.json"
        response = idp.initiate_auth(
            AuthFlow="USER_PASSWORD_AUTH",
            AuthParameters={
                "USERNAME": "test_user",
                "PASSWORD": "qwertY!23456",
            },
            ClientId=user_pool_client["ClientId"],
        )

        jwks = requests.get(jwks_url).json()

        hmac_key = jwk.construct(get_hmac_key(access_token, jwks))

        message, encoded_signature = access_token.rsplit(".", 1)
        decoded_signature = base64url_decode(encoded_signature.encode())

        x = hmac_key.verify(message.encode(), decoded_signature)

        access_token = response["AuthenticationResult"]["AccessToken"]

        request.cognito_resources = _Cognito()
        request.cognito_resources.idp = idp
        request.cognito_resources.user_pool_id = user_pool_id
        request.cognito_resources.user_pool_client = user_pool_client

        yield
    