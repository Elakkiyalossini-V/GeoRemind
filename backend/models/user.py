from pydantic import BaseModel


class UserCreate(BaseModel):
    name: str
    home_location: str | None = None