# 📱 Mô tả Layout UI - Trang chủ với chức năng Tìm người mất tích

## Trang chủ (Home Screen) - Layout mới

```
╔═══════════════════════════════════════════════════════════╗
║                    🔒 PHÒNG CHỐNG LỪA ĐẢO                 ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ┌─────────────────────┐    ┌─────────────────────┐      ║
║  │        📰           │    │        ⚠️           │      ║
║  │                     │    │                     │      ║
║  │     Tin mới         │    │    Cảnh báo         │      ║
║  │                     │    │                     │      ║
║  └─────────────────────┘    └─────────────────────┘      ║
║                                                           ║
║  ┌─────────────────────┐    ┌─────────────────────┐      ║
║  │        ✅           │    │        🔍           │      ║
║  │                     │    │                     │      ║
║  │    Xác thực         │    │     Truy nã         │      ║
║  │                     │    │                     │      ║
║  └─────────────────────┘    └─────────────────────┘      ║
║                                                           ║
║  ┌─────────────────────┐    ┌─────────────────────┐      ║
║  │        👥           │    │        ☑️           │      ║
║  │                     │    │                     │      ║
║  │  Tìm người mất tích │    │  Check tin giả      │      ║
║  │                     │    │                     │      ║
║  └─────────────────────┘    └─────────────────────┘      ║
║                                                           ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │  💬  Liên hệ hỗ trợ                                 │ ║
║  │      Nhấn để mở Facebook                            │ ║
║  └─────────────────────────────────────────────────────┘ ║
╚═══════════════════════════════════════════════════════════╝
```

## Chi tiết từng nút chức năng

### 1. Tin mới (📰)
- **Màu**: `Colors.orangeAccent`
- **Chức năng**: Xem tin tức mới nhất về lừa đảo
- **Navigation**: → `NewsScreen()`

### 2. Cảnh báo (⚠️)
- **Màu**: `Colors.redAccent`  
- **Chức năng**: Cảnh báo rủi ro, thủ đoạn lừa đảo
- **Navigation**: → `RiskWarningScreen()`

### 3. Xác thực (✅)
- **Màu**: `Colors.greenAccent`
- **Chức năng**: Xác thực thông tin, số điện thoại
- **Navigation**: → `VerificationScreen()`

### 4. Truy nã (🔍)
- **Màu**: `Colors.purpleAccent`
- **Chức năng**: Danh sách người bị truy nã
- **Navigation**: → `WantedListScreen()`

### 5. **Tìm người mất tích (👥) - MỚI**
- **Màu**: `Colors.pinkAccent` 
- **Chức năng**: Tìm kiếm người mất tích từ timnguoithatlac.vn
- **Navigation**: → `MissingPersonsScreen()`
- **Icon**: `Icons.people_alt_rounded`

### 6. Check tin giả (☑️)
- **Màu**: `Colors.blueAccent`
- **Chức năng**: Kiểm tra tính xác thực của tin tức
- **Navigation**: → `VerifyNews()`

## Trang Tìm người mất tích - Layout

```
╔═══════════════════════════════════════════════════════════╗
║  ← Danh Sách Người Mất Tích                        🔄     ║
╠═══════════════════════════════════════════════════════════╣
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ 🔍 Tìm kiếm...                              [Tìm] │ ║
║  │ Tìm theo: [Tên ▼]                                  │ ║
║  └─────────────────────────────────────────────────────┘ ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ 👤  Nguyễn Quốc Học                            →   │ ║
║  │     Năm sinh: 1930                                 │ ║
║  │     Quê quán: Quảng Ngãi                           │ ║
║  │     Thất lạc từ: 1962                              │ ║
║  │     Giới tính: Nam, Năm sinh: 1930...              │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ 👤  Phạm Thị Phúc                              →   │ ║
║  │     Năm sinh: 1935                                 │ ║
║  │     Quê quán: TP.Nha Trang, Khánh Hòa              │ ║
║  │     Thất lạc từ: 1935                              │ ║
║  │     Giới tính: Nữ, Năm sinh: 1935...               │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ 👤  Nguyễn Thị Mùi                             →   │ ║
║  │     Năm sinh: 1954                                 │ ║
║  │     Quê quán: H.Hạ Hòa, Phú Thọ                    │ ║
║  │     Thất lạc từ: 1963                              │ ║
║  │     Giới tính: Nữ, Năm sinh: 1954...               │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║                    [Tải thêm]                             ║
╚═══════════════════════════════════════════════════════════╝
```

## Popup Chi tiết người mất tích

```
╔═══════════════════════════════════════════════════════════╗
║                    Nguyễn Quốc Học                        ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║                    [Ảnh đại diện]                         ║
║                                                           ║
║  ID:              26991                                   ║
║  Tên:             Nguyễn Quốc Học                         ║
║  Năm sinh:        1930                                    ║
║  Quê quán:        Quảng Ngãi                              ║
║  Thất lạc từ:     1962                                    ║
║  Thông tin liên hệ: Tel: 0977142213                       ║
║                                                           ║
║  Mô tả:                                                   ║
║  Giới tính: Nam                                           ║
║  Năm sinh: 1930                                           ║
║  Quê quán: Quảng Ngãi                                     ║
║  Thất lạc từ: 1962                                        ║
║  Thông tin thêm: Cháu chào mọi người, cháu là Thăng       ║
║  đến từ Nghệ an, cháu mong muốn tìm ông Nội...           ║
║                                                           ║
║                                                           ║
║              [Xem chi tiết]    [Đóng]                     ║
╚═══════════════════════════════════════════════════════════╝
```

## Đặc điểm thiết kế

### 🎨 Visual Design
- **Glassmorphic effect**: Nền trong suốt với blur effect
- **Gradient background**: Màu xanh indigo đậm dần
- **Floating icons**: Các icon bảo mật bay lơ lửng trang trí
- **Rounded corners**: Bo góc 20px cho tất cả container
- **Shadows**: Đổ bóng nhẹ cho depth

### 📱 Responsive Features
- **Grid layout**: 2 cột, tự động điều chỉnh
- **Text scaling**: Font size thay đổi theo độ dài text
- **Icon sizing**: Icon 40px, phù hợp với touch target
- **Spacing**: 16px giữa các elements

### 🔄 Animations
- **Fade in**: Tất cả elements fade in khi load
- **Scale animation**: Nút nhấn có hiệu ứng scale down
- **Floating motion**: Background icons di chuyển nhẹ
- **Shimmer effect**: Hiệu ứng shimmer tinh tế

### 🎯 User Experience
- **Clear hierarchy**: Chức năng chính nổi bật
- **Consistent colors**: Mỗi chức năng có màu riêng biệt
- **Intuitive icons**: Icon dễ hiểu, phù hợp chức năng
- **Touch friendly**: Kích thước nút phù hợp cho mobile
