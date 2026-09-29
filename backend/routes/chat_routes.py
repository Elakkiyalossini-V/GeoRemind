from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from google import genai
from google.genai import types


router = APIRouter(prefix="/chat", tags=["Chat"])


class ChatRequest(BaseModel):
    message: str


class ReminderResponse(BaseModel):
    is_reminder: bool = Field(
        description="True if the user is asking GeoRemind to create a reminder."
    )

    reminder: str = Field(
        description="The task or thing the user wants to be reminded about."
    )

    location: str = Field(
        description="The place where the reminder should trigger. "
                    "Return the place name mentioned by the user."
    )


client = genai.Client()


@router.post("/")
def chat(request: ChatRequest):

    prompt = f"""
You are GeoRemind AI, an intelligent location-based reminder assistant.

Analyze the user's message and determine whether they are asking
GeoRemind to create a location-based reminder.

If they are creating a reminder:
- Extract the actual task as "reminder".
- Extract the destination/place as "location".
- Remove unnecessary words such as "remind me to".
- Keep the location name as naturally mentioned by the user.

Example:

User:
"Remind me to buy milk when I reach near the DMart"

Return:
is_reminder = true
reminder = "Buy milk"
location = "DMart"

Another example:

User:
"Remind me to call mom when I reach college"

Return:
is_reminder = true
reminder = "Call mom"
location = "college"

If the message is NOT a reminder request:
is_reminder = false
reminder = ""
location = ""

User message:
{request.message}
"""

    try:
        response = client.models.generate_content(
            model="gemini-3.8-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=ReminderResponse,
            ),
        )

        result = response.parsed

        if result is None:
            raise HTTPException(
                status_code=500,
                detail="Gemini did not return a valid structured response."
            )

        return result.model_dump()

    except Exception as e:
        print("Gemini API error:", e)

        raise HTTPException(
            status_code=500,
            detail="Failed to process message with Gemini."
        )