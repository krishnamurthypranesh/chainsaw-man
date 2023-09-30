from datetime import datetime
from typing import Dict, Optional, List

from fastapi import HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwk, jwt, JWTError
from jose.utils import base64url_decode
from pydantic import BaseModel
import requests
from starlette.requests import Request

from app.schema.base import AuthToken, JWKS, JWTAuthorizationCredentials


class JWTBearer(HTTPBearer):
    def __init__(self, jwks_url: str, auto_error: bool = True):
        super().__init__(auto_error=auto_error)

        self.jwks_url = jwks_url

    def verify_jwk_token(self, jwt_credentials: JWTAuthorizationCredentials) -> bool:
        try:
            public_key = self.kid_to_jwk[jwt_credentials.header["kid"]]
        except KeyError:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="JWK public key not found"
            )

        key = jwk.construct(public_key)
        decoded_signature = base64url_decode(jwt_credentials.signature.encode())

        return key.verify(jwt_credentials.message.encode(), decoded_signature)

    def validate_expiry(self, jwt_credentials: JWTAuthorizationCredentials) -> bool:
        if jwt_credentials.claims["exp"] < datetime.now().timestamp().replace(microsecond=0):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Session expired"
            )

    def get_jwks(self) -> JWKS:
        jwks = JWKS(
            **requests.get(self.jwks_url).json()
            )

        return jwks

    async def __call__(self, request: Request) -> Optional[AuthToken]:
        credentials: HTTPAuthorizationCredentials = await super().__call__(request)

        if credentials:
            if not credentials.scheme == "Bearer":
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN, detail="Wrong authentication method"
                )

            jwt_token = credentials.credentials

            message, signature = jwt_token.rsplit(".", 1)

            try:
                jwt_credentials = JWTAuthorizationCredentials(
                    jwt_token=jwt_token,
                    header=jwt.get_unverified_header(jwt_token),
                    claims=jwt.get_unverified_claims(jwt_token),
                    signature=signature,
                    message=message,
                )
            except JWTError:
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="JWK invalid")

            if not self.verify_jwk_token(jwt_credentials):
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="JWK invalid")

            user_id = jwt_credentials.claims["user_id"]
            auth_token = AuthToken(
                user=self.painted_porch_repo.get_user_by_id(user_id),
            )

            return auth_token
