from google import genai

client = genai.Client()

response = client.models.generate_content(
    model="gemini-3.8-flash",
    contents="Say hello to GeoRemind in one short sentence."
)

print("Gemini response:")
print(response.text)