import os
import tempfile
from unittest import mock

import boto3
from moto import mock_cognitoidp
import pytest


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
    with mock_cognitoidp as mock_idp:
        cognito = boto3.client("cognito-idp", region_name="ap-south-1")

        # create a user pool
        user_pool_id = cognito.create_user_pool(PoolName="")["UserPool"]["Id"]

        # create a user pool client
        user_pool_client = cognito.create_user_pool_client(UserPoolId=user_pool_id, ClientName="painted-porch-backend")

        # sigup and verify user

        # create a user in dynamo db
    