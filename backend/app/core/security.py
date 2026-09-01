"""
Security and Cryptography Utilities
Provides:
1. AES-256 Token Encryption & Decryption via Fernet (Guarantees zero plain-text storage of credentials)
2. Secure Password Hashing & Verification (Bcrypt)
3. JWT Authentication Token Creation & Decoding
"""

from datetime import datetime, timedelta, timezone
from typing import Any, Optional, Union
from cryptography.fernet import Fernet, InvalidToken
from passlib.context import CryptContext
from jose import jwt, JWTError

from app.core.config import settings

# Password hashing context using standard bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Initialize Fernet cipher suite for AES-256 encryption
_fernet_instance: Optional[Fernet] = None


def get_fernet() -> Fernet:
    """
    Retrieves or initializes the Fernet cipher using FERNET_SECRET_KEY.
    """
    global _fernet_instance
    if _fernet_instance is None:
        key = settings.FERNET_SECRET_KEY.encode()
        _fernet_instance = Fernet(key)
    return _fernet_instance


def encrypt_token(plain_token: str) -> str:
    """
    Encrypts a sensitive plain-text token (e.g. OAuth refresh token) with AES-256.
    Returns URL-safe base64-encoded encrypted string.
    """
    if not plain_token:
        return ""
    cipher = get_fernet()
    encrypted_bytes = cipher.encrypt(plain_token.encode("utf-8"))
    return encrypted_bytes.decode("utf-8")


def decrypt_token(encrypted_token: str) -> str:
    """
    Decrypts an encrypted token string back to plain-text.
    Raises ValueError if decryption fails or token is tampered.
    """
    if not encrypted_token:
        return ""
    cipher = get_fernet()
    try:
        decrypted_bytes = cipher.decrypt(encrypted_token.encode("utf-8"))
        return decrypted_bytes.decode("utf-8")
    except InvalidToken as exc:
        raise ValueError("Failed to decrypt token: Invalid key or corrupted payload.") from exc


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifies a plain password against the bcrypt hash.
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Generates a secure bcrypt hash from a plain password.
    """
    return pwd_context.hash(password)


def create_access_token(
    subject: Union[str, Any],
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    Creates a signed JWT access token for user authentication.
    """
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "exp": expire,
        "iat": now,
        "sub": str(subject)
    }
    encoded_jwt = jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM
    )
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Decodes and validates a JWT token signature and expiration.
    """
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM]
        )
        return payload
    except JWTError:
        return None
