from fastapi import FastAPI

from backend.routes.user_routes import router as user_router
from backend.routes.chat_routes import router as chat_router


app = FastAPI(title="GeoRemind API")


@app.get("/")
def root():
    return {"message": "GeoRemind API is running"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


app.include_router(user_router)
app.include_router(chat_router)