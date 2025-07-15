import google.generativeai as genai
import os
from dotenv import load_dotenv
from googleapiclient.discovery import build # Để gọi Google Search API

# 1. Tải API Keys và cấu hình
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY")
GOOGLE_SEARCH_CX = os.getenv("GOOGLE_SEARCH_CX")

if not all([GEMINI_API_KEY, GOOGLE_SEARCH_API_KEY, GOOGLE_SEARCH_CX]):
    print("Lỗi: Thiếu một hoặc nhiều biến môi trường (API Key, CX).")
    exit()

genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel('gemini-2.0-flash')

# Khởi tạo dịch vụ Google Custom Search
search_service = build("customsearch", "v1", developerKey=GOOGLE_SEARCH_API_KEY)

def search_google(query, num_results=5):
    """
    Thực hiện tìm kiếm trên Google Custom Search API.
    """
    try:
        res = search_service.cse().list(q=query, cx=GOOGLE_SEARCH_CX, num=num_results).execute()
        
        search_results = []
        if 'items' in res:
            for item in res['items']:
                search_results.append({
                    "title": item.get('title'),
                    "link": item.get('link'),
                    "snippet": item.get('snippet')
                })
        return search_results
    except Exception as e:
        print(f"Lỗi khi tìm kiếm Google: {e}")
        return []

def check_fake_news_with_search(news_text):
    """
    Sử dụng Gemini và Google Search để kiểm tra tin giả.
    """
    # Bước 1: Tin tức gốc từ người dùng
    original_news = news_text

    # Bước 2: Tạo truy vấn tìm kiếm
    # Bạn có thể dùng một prompt đơn giản hoặc phức tạp hơn để Gemini tạo truy vấn tìm kiếm
    # Ví dụ đơn giản:
    search_query = f"kiểm tra thông tin {original_news[:100]} sự thật tin tức" 
    
    # Ví dụ nâng cao: Dùng Gemini để tạo truy vấn tối ưu
    # response_query = gemini_model.generate_content(f"Dựa vào đoạn tin tức sau, hãy tạo 3 truy vấn tìm kiếm ngắn gọn nhất để xác minh tính xác thực của nó:\n\n{original_news}\n\nTruy vấn:")
    # search_queries = response_query.text.split('\n') # Giả sử Gemini trả về mỗi truy vấn trên một dòng
    # Lấy truy vấn đầu tiên hoặc kết hợp chúng
    # search_query = search_queries[0] if search_queries else f"kiểm tra tin tức {original_news[:50]}"


    print(f"Đang tìm kiếm Google với truy vấn: '{search_query}'...")
    
    # Bước 3 & 4: Thực hiện tìm kiếm và xử lý kết quả
    search_results = search_google(search_query, num_results=5) # Lấy 5 kết quả hàng đầu

    search_info_for_gemini = ""
    if search_results:
        search_info_for_gemini += "\n\n--- THÔNG TIN TÌM KIẾM TRÊN WEB LIÊN QUAN ---\n"
        for i, res in enumerate(search_results):
            search_info_for_gemini += f"Kết quả {i+1}:\n"
            search_info_for_gemini += f"  Tiêu đề: {res.get('title', 'N/A')}\n"
            search_info_for_gemini += f"  Link: {res.get('link', 'N/A')}\n"
            search_info_for_gemini += f"  Mô tả: {res.get('snippet', 'N/A')}\n\n"
    else:
        search_info_for_gemini += "\n\n--- KHÔNG TÌM THẤY THÔNG TIN LIÊN QUAN TRÊN WEB ---"

    # Bước 5: Xây dựng Prompt "bổ sung" cho Gemini
    full_prompt = f"""
    Bạn là một trợ lý AI chuyên gia trong việc phân tích độ tin cậy của tin tức hoặc ý kiến cá nhân.
    Dưới đây là một đoạn tin tức hoặc ý kiến cá nhân và một số thông tin liên quan được tìm thấy trên web.
    
    Hãy xem xét kỹ **tin tức cần kiểm tra** và **THÔNG TIN TÌM KIẾM TRÊN WEB LIÊN QUAN**.
    Sử dụng thông tin tìm kiếm để xác minh, đối chiếu hoặc phản bác các tuyên bố trong tin tức hoặc ý kiến cá nhân gốc.

    **Tin tức cần kiểm tra:**
    ---
    {original_news}
    ---

    {search_info_for_gemini}

    **Đánh giá của bạn về tin tức gốc (là thật hay giả) và lý do chi tiết, dựa trên cả tin tức gốc và các thông tin tìm kiếm được:**
    Đánh giá: [Thật/Giả/Khó xác định - (Giải thích ngắn gọn)]
    Lý do chi tiết:
    """

    # Bước 6: Gọi Gemini API để đánh giá
    print("Đang gửi thông tin đến Gemini để phân tích...")
    try:
        response = gemini_model.generate_content(full_prompt)
        return response.text
    except Exception as e:
        return f"Đã xảy ra lỗi khi gọi Gemini API: {e}"

# --- Ví dụ sử dụng ---
if __name__ == "__main__":
    news_to_verify = """
    Hồ Chí Minh sinh năm 2015.
    """
    
    print("Bắt đầu quy trình kiểm tra tin tức...")
    result_analysis = check_fake_news_with_search(news_to_verify)
    print("\n--- Kết quả Đánh giá từ AI ---")
    print(result_analysis)