import os
from dotenv import load_dotenv

def load_config():
    load_dotenv()

    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
    GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY")
    GOOGLE_SEARCH_CX = os.getenv("GOOGLE_SEARCH_CX")

    if not all([GEMINI_API_KEY, GOOGLE_SEARCH_API_KEY, GOOGLE_SEARCH_CX]):
        raise ValueError("Thiếu một hoặc nhiều biến môi trường")

    return {
        "GEMINI_API_KEY": GEMINI_API_KEY,
        "GOOGLE_SEARCH_API_KEY": GOOGLE_SEARCH_API_KEY,
        "GOOGLE_SEARCH_CX": GOOGLE_SEARCH_CX
    }