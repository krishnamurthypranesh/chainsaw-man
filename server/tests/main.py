from fastapi.testclient import TestClient

from app.main import app

CLIENT = TestClient(app)
