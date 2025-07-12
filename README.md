Hướng dẫn sử dụng :

- Đầu tiên là hãy tải Flutter SDK ở: https://docs.flutter.dev/get-started/install/windows/mobile
- Set up biến môi trường cho flutter:
 + Tại thanh search trên window, gõ edit the system environment variables 
 + Chọn "Environment Variables"
 + Trong phần "System variables", tìm và chọn "Path", nhấn "Edit"
 + Thêm đường dẫn đến thư mục bin trong Flutter SDK (ví dụ: C:\flutter\bin)
 + Nhấn "OK" để lưu thay đổi
- Tiếp tục tải Android Studio ở: https://developer.android.com/studio
 + Cài đặt Android Studio theo hướng dẫn
 + Mở Android Studio, chọn "More Actions" > "SDK Manager"
 + Trong "SDK Platforms", chọn Android version muốn phát triển (Android 11/12 trở lên)
 + Trong "SDK Tools", đảm bảo đã chọn "Android SDK Build-Tools" và "Android SDK Command-line Tools"
 + Nhấn "Apply" để tải và cài đặt

Chạy dự án Flutter:
- Clone dự án từ git: `git clone <repository-url>`
- Vào thư mục dự án: `cd frauddetection`
- Chạy lệnh: `flutter pub get` để cài đặt các dependencies
- Kết nối thiết bị Android hoặc mở máy ảo Android
- Chạy ứng dụng: `flutter run`

Chạy phần Web (Vite React):
- Vào thư mục web: `cd vite-web`
- Cài đặt dependencies: `npm install`
- Chạy dự án: `npm run dev`

Sử dụng máy ảo Android:
- Kiểm tra các máy ảo có sẵn: `flutter emulators`
- Khởi chạy máy ảo: `flutter emulators --launch <emulator-id>`
- Ví dụ: `flutter emulators --launch Pixel_5_API_30`
- Sau khi máy ảo khởi động, chạy ứng dụng: `flutter run`

Các lệnh Flutter hữu ích:
- `flutter clean`: Xóa thư mục build và các file tạm để fix lỗi
- `flutter doctor`: Kiểm tra môi trường phát triển Flutter
- `flutter devices`: Liệt kê các thiết bị đang kết nối
- `flutter pub outdated`: Kiểm tra các package cần cập nhật
- `flutter build apk`: Đóng gói ứng dụng Android (tạo file APK)
- `flutter analyze`: Phân tích mã nguồn, kiểm tra lỗi

