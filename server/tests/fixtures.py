import os
import tempfile
from unittest import mock

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
