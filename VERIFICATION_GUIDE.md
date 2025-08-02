# Hướng Dẫn Sử Dụng Chức Năng Xác Thực Thông Tin

## Tổng Quan

Chức năng **Xác Thực Thông Tin** đã được tích hợp với dữ liệu từ **checkscam.vn** để giúp người dùng kiểm tra tính xác thực của:

- Số điện thoại
- Tài khoản ngân hàng
- Website

## Cách Hoạt Động

### 1. Tích Hợp với CheckScam.vn

- **Search Real-time**: Hệ thống thực hiện tìm kiếm trực tiếp trên checkscam.vn khi bạn nhập thông tin
- **Dữ liệu mới nhất**: Lấy thông tin cập nhật từ cơ sở dữ liệu **56.278 STK, SĐT** và **19.069 FB lừa đảo**
- **Fallback thông minh**: Nếu không kết nối được, sử dụng dữ liệu cached từ checkscam.vn
- **Bypass Cloudflare**: Sử dụng nhiều User-Agent và kỹ thuật để vượt qua bảo vệ website

### 2. Tiêu Chí Đánh Giá

- **Nguy hiểm (Đỏ)**: Tỷ lệ lừa đảo ≥ 20% hoặc có nhiều báo cáo lừa đảo
- **Cảnh báo (Cam)**: Tỷ lệ lừa đảo > 0% hoặc có cảnh báo
- **An toàn (Xanh)**: Chưa có báo cáo lừa đảo

## Hướng Dẫn Sử Dụng

### Bước 1: Truy Cập Chức Năng

1. Mở ứng dụng Fraud Detection
2. Chọn tab **"Xác Thực Thông Tin"**

### Bước 2: Nhập Thông Tin Cần Kiểm Tra

Bạn có thể kiểm tra một trong ba loại thông tin:

#### A. Số Điện Thoại

- Nhập số điện thoại cần kiểm tra (VD: 0903465968)
- Hỗ trợ định dạng: 0xxxxxxxxx, +84xxxxxxxxx

#### B. Tài Khoản Ngân Hàng

- Nhập số tài khoản ngân hàng (VD: 060180153252)
- Chỉ nhập số, không cần tên ngân hàng

#### C. Website

- Nhập địa chỉ website (VD: facebook.com hoặc https://facebook.com)

### Bước 3: Xem Kết Quả

Sau khi nhấn **"Xác thực ngay"**, hệ thống sẽ hiển thị:

#### Thông Tin Hiển Thị:

- **Trạng thái**: Nguy hiểm / Cảnh báo / An toàn
- **Thông báo chi tiết**: Mô tả tình trạng của thông tin
- **Tỷ lệ lừa đảo**: Phần trăm báo cáo lừa đảo (nếu có)
- **Cảnh báo**: Danh sách các cảnh báo cụ thể
- **Nguồn**:
  - `checkscam.vn (real-time)` = Dữ liệu lấy trực tiếp từ website
  - `checkscam.vn (cached)` = Dữ liệu đã lưu từ checkscam.vn
  - `Phân tích pattern` = Phân tích dựa trên pattern đáng ngờ

## Ví Dụ Thực Tế

### Số Điện Thoại Lừa Đảo

**Input**: 0903465968
**Kết quả**:

- Trạng thái: **Nguy hiểm**
- Tỷ lệ lừa đảo: **67%**
- Thông báo: "Số điện thoại đã bị báo cáo là lừa đảo"

### Tài Khoản Top Scammer

**Input**: 060180153252
**Kết quả**:

- Trạng thái: **Nguy hiểm**
- Tỷ lệ lừa đảo: **95%**
- Cảnh báo: "Top scammer với 53 báo cáo lừa đảo"

### Tài Khoản Được Tìm Kiếm Nhiều

**Input**: 40400792914617
**Kết quả**:

- Trạng thái: **Nguy hiểm**
- Tỷ lệ lừa đảo: **70%**
- Cảnh báo: "25 báo cáo lừa đảo"

### Thông Tin An Toàn

**Input**: Số/tài khoản chưa có báo cáo
**Kết quả**:

- Trạng thái: **An toàn**
- Thông báo: "Chưa có báo cáo lừa đảo, nhưng hãy luôn cảnh giác"

## Lưu Ý Quan Trọng

### 1. Tính Chính Xác

- Dữ liệu dựa trên báo cáo từ cộng đồng checkscam.vn
- Kết quả mang tính tham khảo, không phải bằng chứng pháp lý
- Luôn kiểm tra kỹ trước khi giao dịch

### 2. Cập Nhật Dữ Liệu

- Hệ thống tự động cập nhật từ checkscam.vn
- Nếu không kết nối được, sử dụng dữ liệu cached
- Dữ liệu được cập nhật thường xuyên từ cộng đồng

### 3. Bảo Mật

- Thông tin tìm kiếm không được lưu trữ
- Chỉ truy vấn dữ liệu công khai từ checkscam.vn
- Không chia sẻ thông tin cá nhân

## Các Trường Hợp Đặc Biệt

### Khi Không Có Dữ Liệu

- Hệ thống sẽ thông báo "An toàn" nhưng khuyến cáo cảnh giác
- Không có dữ liệu không có nghĩa là 100% an toàn

### Khi Có Lỗi Kết Nối

- Sử dụng dữ liệu cached từ checkscam.vn
- Phân tích pattern để đưa ra cảnh báo cơ bản
- Thông báo nguồn dữ liệu để người dùng biết

## Liên Hệ Hỗ Trợ

Nếu gặp vấn đề hoặc cần hỗ trợ:

- Kiểm tra kết nối internet
- Thử lại sau vài phút
- Liên hệ team phát triển nếu lỗi kéo dài

---

**Lưu ý**: Chức năng này được phát triển để hỗ trợ phòng chống lừa đảo. Luôn kiểm tra kỹ và sử dụng nhiều nguồn thông tin trước khi đưa ra quyết định giao dịch quan trọng.
