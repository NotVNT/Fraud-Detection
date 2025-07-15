import google.generativeai as genai
import os
from dotenv import load_dotenv
from googleapiclient.discovery import build
from search import search_google
from analysis import check_fake_news_with_search

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY")
GOOGLE_SEARCH_CX = os.getenv("GOOGLE_SEARCH_CX")

if not all([GEMINI_API_KEY, GOOGLE_SEARCH_API_KEY, GOOGLE_SEARCH_CX]):
    print("Thiếu một hoặc nhiều biến môi trường")
    exit()

# genai.configure(api_key=GEMINI_API_KEY)
# gemini_model = genai.GenerativeModel('gemini-2.0-flash')

if __name__ == "__main__":
    news_to_verify = """
   SỰ LẠC HẬU TRONG TƯ DUY CỦA CÁN BỘ VIÊN CHỨC ĐẢNG CSVN

Trong vài ngày vừa qua, có hai nữ quan chức đại biểu Quốc hội csVN đã phát biểu “ngô nghê” về dân số và diện tích của các tỉnh sau vụ sáp nhập các tỉnh/thành. Bà Nguyễn Thanh Hải, 55 tuổi, phó trưởng Ban Tổ Chức Trung Ương, được phát biểu tại cuộc họp: “Sau khi sắp xếp, tỉnh Phú Thọ có diện tích tự nhiên 9,361,000 cây số vuông, dân số hơn 4 triệu…” Trước bà Hải, bà Lê Thị Thủy, phó bí thư đảng ủy chính phủ, cũng bị công luận chỉ trích khi phát biểu trong một đoạn video clip quay tại cuộc họp: “Quảng Trị có dân số một tỷ tám trăm bảy mươi ngàn tám trăm bốn mươi lăm người…” Điểm trùng hợp trong cả hai đoạn clip là cả bà Hải và Thủy đều “cắm mặt đọc giấy” soạn sẵn khi đăng đàn.

Đây đúng là một sự việc rất điển hình cho thực trạng "đọc sai, hiểu sai, nhưng vẫn cứ nói như đúng rồi" trong hệ thống chính trị hiện nay. Hai phát biểu "gây cười" nhưng cũng "gây lo" của bà Nguyễn Thanh Hải và bà Lê Thị Thủy cho thấy một số vấn đề nghiêm trọng dưới lớp vỏ tưởng như chỉ là lỗi cá nhân. Nhưng thực của vấn đề là của một chế độ đang “đầu độc” đạo đức xã hội dân tộc Việt Nam hôm nay và tương lai.

Phú Thọ có diện tích 9 triệu km² tức là… lớn gấp 90 lần toàn bộ Việt Nam, tương đương cả châu Âu cộng lại. Quảng Trị có dân số 1,87 tỷ người – nghĩa là đông hơn Trung Quốc, Ấn Độ và toàn châu Phi cộng lại. Những con số không thể vô tình, không thể “đọc nhầm” một cách ngây thơ nếu người đọc thực sự biết mình đang nói gì. Điểm đáng báo động nhất là cả hai bà đều không tự phát hiện ra sai số "kinh hoàng" này trong lúc đọc. Điều đó chứng tỏ: Họ không hiểu nội dung mình đang phát biểu hoặc đọc cho có hình thức, chỉ để làm tròn vai “đại biểu chuyên nghiệp” chứ không đại diện gì cho dân trí hay dân ý.

Sự kiện nầy chứng tỏ thể chế csVN sinh ra nhóm "người đọc văn bản" thay vì các nhà lãnh đạo. Khi hệ thống chính trị độc đảng chọn lòng trung thành thay vì năng lực, thì những người như bà Hải, bà Thủy được bổ nhiệm vào vị trí cao không nhờ năng lực quản trị, mà nhờ “cơ cấu”, “lý lịch” hay “lý tưởng cộng sản”. Họ phát biểu không phải để thuyết phục, mà để… hoàn thành thủ tục. Có người chua xót nói đáng lẽ ra phải truy xét trách nhiệm người soạn văn bản. Kiểm tra lại năng lực thực tế của các đại biểu quốc hội. Nhưng rất có thể… rồi cũng chìm xuồng, như hàng loạt sự vụ “đọc nhầm – nói nhầm – làm đúng theo kịch bản” cộng hòa xã hội chủ nghĩa cộng sản Việt Nam.

Thế mới hiểu ở cái nghị trường Quốc hội “bù nhìn” này, chỉ cần biết đọc… giấy đúng thứ tự đã là hồng khúc dân tộc rồi.
    """
    
    print("Bắt đầu quy trình kiểm tra tin tức...")
    result_analysis = check_fake_news_with_search(news_to_verify)
    print("\n--- Kết quả Đánh giá từ AI ---")
    print(result_analysis)