import google.generativeai as genai

def check_fake_news_with_search(new_text):
    original_news = new_text
    search_query = f"Kiểm tra thông tin '{original_news}'"
    print(f"Đang tìm kiếm thông tin liên quan đến truy vấn '{original_news}' ")

    from search import search_google
    search_result = search_google(search_query, 5)
    search_info_for_gemini = ""

    if search_result:
        search_info_for_gemini += "\n\n Thông tin liên quan được tìm kiếm trên trang web \n"
        for i, res in enumerate(search_result):
            search_info_for_gemini += f"Kết quả {i+1}:\n"
            search_info_for_gemini += f"  Tiêu đề: {res.get('title', 'N/A')}\n"
            search_info_for_gemini += f"  Link: {res.get('link', 'N/A')}\n"
            search_info_for_gemini += f"  Mô tả: {res.get('snippet', 'N/A')}\n\n"
    else:
        search_info_for_gemini += "Không tìm thấy thông tin."

    prompt = f"""Bạn là một trợ lý AI chuyên gia trong việc phân tích độ tin cậy của tin tức hoặc ý kiến cá nhân.
    Dưới đây là một đoạn tin tức hoặc ý kiến cá nhân và một số thông tin liên quan được tìm thấy trên web.
    
    Hãy xem xét kỹ **tin tức hoặc ý kiến cá nhân cần kiểm tra** và **THÔNG TIN TÌM KIẾM TRÊN WEB LIÊN QUAN**.
    Sử dụng thông tin tìm kiếm để xác minh, đối chiếu hoặc phản bác các tuyên bố trong tin tức hoặc ý kiến cá nhân gốc.
    

    **Tin tức hoặc ý kiến cá nhân cần kiểm tra:**
    ---
    {original_news}
    ---

    {search_info_for_gemini}

    **Nếu thông tin được mà bạn nhận được liên quan tới tin tức thì đánh giá của bạn về tin tức gốc (là thật hay giả) và lý do chi tiết(chỉ dài khoảng 200 từ), dựa trên cả tin tức gốc và các thông tin tìm kiếm được:**
    Đánh giá: Đây là thông tin [Thật/Giả/Không có bằng chứng cụ thể để xác thực thông tin này - (Giải thích ngắn gọn)]
    Lý do chi tiết:

    **Nếu thông tin được mà bạn nhận được liên quan tới ý kiến cá nhân thì đánh giá của bạn về ý kiến cá nhân (là tích cực hay tiêu cực) và lý do chi tiết tại sao tin này có thể gây hiểu lầm nếu là tiêu cực và tại sao tin này có thể mang lại thông tin hay nếu là tích cực(chỉ dài khoảng 200 từ), dựa trên cả tin tức gốc và các thông tin tìm kiếm được:**
    Đánh giá: Đây là ý kiến cá nhân mang tính [Tích cực/Tiêu cực/Không có bằng chứng cụ thể để xác thực thông tin này - (Giải thích ngắn gọn)]
    Lý do chi tiết:

    Lý do chi tiết:"""

    print("Đang gửi thông tin đến gemini để phân tích")
    from google.generativeai import GenerativeModel
    from dotenv import load_dotenv
    import os

    load_dotenv()
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
    genai.configure(api_key=GEMINI_API_KEY)
    gemini_model = genai.GenerativeModel('gemini-2.0-flash')
    # genai_model = GenerativeModel('gemini-2.0-flash')
    
    try:
        response = gemini_model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"Đã xảy ra lỗi khi gọi {e} "