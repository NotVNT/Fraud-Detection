import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    print("Lỗi: Không tìm thấy GOOGLE_API_KEY trong file .env")
    exit()

genai.configure(api_key=GEMINI_API_KEY)

print("Đang liệt kê các mô hình Gemini khả dụng...")
try:
    for m in genai.list_models():
        # Kiểm tra xem mô hình có hỗ trợ phương thức generateContent không
        # (Đây là phương thức dùng để tạo văn bản)
        if 'generateContent' in m.supported_generation_methods:
            print(f"Mô hình khả dụng: {m.name} (hỗ trợ generateContent)")
except Exception as e:
    print(f"❌ Lỗi khi liệt kê mô hình: {e}")
    print("Vui lòng kiểm tra lại GOOGLE_API_KEY của bạn.")
