from fastapi import status
import pytest

from tests.main import CLIENT


class TestCollectionCreate:
    url = "/v1/collections"

    @pytest.fixture(scope="class", autouse=True)
    def setup(self):
        pass

    def test_returns_400_if_template_is_invalid_json(self):
        response = CLIENT.post(
            self.url,
            json={
                "name": "test_template",
                "template": "<html></html>",
            }
        )

        assert response is not None
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_returns_409_if_active_collection_with_name_already_exists(self):
        response = CLIENT.post(
            self.url,
            json={
                "name": "default",
                "template": '[{"key": "title", "display_name": "Title"}, {"key": "content", "display_name": "Content"}]',
                "active": True,
            }
        )

        assert response is not None
        assert response.status_code == status.HTTP_409_CONFLICT

    def test_returns_returns_201_if_collection_is_created(self):
        assert 1 == 0


class TestCollectionList:
    pass


class TestCollectionGetById:
    pass


class TestCollectionUpdate:
    pass
