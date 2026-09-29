from fastapi import APIRouter
from backend.models.user import UserCreate

router = APIRouter(prefix="/users", tags=["Users"])


@router.post("/")
def create_user(user: UserCreate):
    return {
        "message": "User received successfully",
        "user": {
            "name": user.name,
            "home_location": user.home_location
        }
    }