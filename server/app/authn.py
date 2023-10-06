from datetime import datetime
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import httpx
from jose import jwk, jwt, JWTError
from jose.utils import base64url_decode
from starlette.requests import Request

from app.config import get_app_config
from app.connections import DB_CONNECTION
from app.repo import PaintedPorchRepo
from app.schema.base import AuthToken, JWKS, JWTAuthorizationCredentials


class JWTBearer(HTTPBearer):
    def __init__(self, user_pool_id: str, user_pool_region: str, auto_error: bool = True):
        super().__init__(auto_error=auto_error)

        self.jwks_url = f"https://cognito-idp.{user_pool_region}.amazonaws.com/{user_pool_id}/.well-known/jwks.json"

        jwks = JWKS(
            **httpx.get(self.jwks_url).json()
            )

        self.kid_to_jwk = {jwk["kid"]: jwk for jwk in jwks.keys}

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

            return jwt_credentials


__auth = JWTBearer(
    user_pool_id=get_app_config().cognito_user_pool_id,
    user_pool_region=get_app_config().cognito_user_pool_region,
)


async def validate_expiry(jwt_credentials: JWTAuthorizationCredentials = Depends(__auth)):
    if int(jwt_credentials.claims["exp"]) < int(datetime.now().timestamp()):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Session expired"
        )

    return jwt_credentials


async def authorize(credentials: JWTAuthorizationCredentials = Depends(validate_expiry)):
    pkey = credentials.claims["sub"]
    if not pkey:
        return None

    repo = PaintedPorchRepo(db=DB_CONNECTION)

    user = repo.get_user_by_id(user_id=pkey)

    auth_token = AuthToken(
        user=user,
    )
    
    return auth_token