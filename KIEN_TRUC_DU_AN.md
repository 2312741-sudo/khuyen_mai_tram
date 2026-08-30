# TÀI LIỆU KIẾN TRÚC & KỸ THUẬT DỰ ÁN — KHUYẾN MÃI TRẠM

## 1. Tổng Quan Dự Án
- **Tên dự án**: Khuyến Mãi Trạm
- **Mục tiêu**: Xây dựng hệ thống quản lý khuyến mãi, tra cứu và tích lũy điểm khách hàng cho hệ sinh thái **Trạm** (Trạm Chanh, Trạm Sữa).
- **Phân hệ**:
  1. **Mobile App (Flutter Mobile)**: Dành riêng cho **Nhân viên / Quản lý** tại cửa hàng để tra cứu tức thì thông tin khách hàng, xem số điểm hiện tại và lịch sử tích/đổi điểm khi khách mua hàng.
  2. **Web App (Flutter Web)**: Dành riêng cho **Chủ quán** để xem báo cáo tổng quan (Dashboard), nhập file Excel điểm khách hàng từ KiotViet theo từng cửa hàng, quản lý danh sách khách hàng, quản lý nhân viên và xuất báo cáo Excel.

---

## 2. Mô Hình Dữ Liệu & Quy Tắc Gộp Điểm (Firestore Schema)

Dự án dùng chung Firebase Project với **Chấm Công Trạm** (`chamcongtram`), tách biệt các collection với tiền tố `kmt_`:

### A. Collection `kmt_customers` (Hồ sơ Khách Hàng)
- `id`: Mã khách hàng hoặc SĐT (khóa chính).
- `ma_khach_hang`: Mã KH từ KiotViet (vd: `KH000123`).
- `ho_ten`: Họ tên khách hàng.
- `so_dien_thoai`: Số điện thoại (dùng để tìm kiếm tức thì).
- `gioi_tinh`: Nam / Nữ / Khác.
- `ngay_sinh`: Ngày sinh nhật.
- `diem_hien_tai`: **Tổng điểm gộp chung của khách hàng trên toàn bộ hệ thống Trạm** (Trạm Chanh + Trạm Sữa).
- `tong_diem`: Tổng tích lũy lịch sử.
- `ngay_cap_nhat`: Thời gian cập nhật gần nhất.

### B. Collection `kmt_point_history` (Lịch Sử Tích/Đổi Điểm)
- `id`: Auto ID.
- `ma_khach_hang`: Mã khách hàng liên kết.
- `so_dien_thoai`: SĐT khách hàng.
- `thoi_gian`: Thời điểm phát sinh giao dịch.
- `loai_giao_dich`: `cong_diem` (+ điểm mua hàng) / `tru_diem` (- đổi quà khuyến mãi) / `import_excel` (đồng bộ từ KiotViet).
- `so_diem_thay_doi`: Số điểm delta (+/-).
- `diem_sau_khi_thay_doi`: Điểm số sau thay đổi.
- `cua_hang`: Cửa hàng thực hiện (`tram_chanh`, `tram_sua`).
- `ghi_chu`: Chi tiết giao dịch hoặc tên đợt import Excel.

### C. Collection `kmt_stores` (Danh Mục Cửa Hàng)
- `tram_chanh`: Trạm Chanh
- `tram_sua`: Trạm Sữa

---

## 3. Quy Tắc Đồng Bộ Tài Khoản & Phân Quyền (Role Mapping)

Tái sử dụng 100% tài khoản đã đăng ký trên **Chấm Công Trạm**:
- **Role `owner` (Chủ)** $\rightarrow$ Toàn quyền truy cập Web Dashboard, Import Excel KiotViet, Xuất báo cáo, Quản trị nhân viên và khách hàng.
- **Role `manager`, `manager_1`, `manager_2`, `employee` (Quản lý & Nhân viên)** $\rightarrow$ Tự động gộp chung thành Role **Nhân viên (`staff`)** trong Khuyến Mãi Trạm, chỉ truy cập màn hình tra cứu điểm và lịch sử.

---

## 4. Cấu Trúc Import File Excel KiotViet

- **File nguồn**: File Excel xuất từ KiotViet (`.xlsx`).
- **Cấu trúc dòng**:
  - Dòng 0: Tiêu đề cột (Header).
  - Dòng 1: Dòng tổng hợp / thống kê chung của KiotViet $\rightarrow$ **Hệ thống tự động bỏ qua (Skip)**.
  - Dòng 2 trở đi: Dữ liệu khách hàng thực tế.
- **Mapping cột chuẩn**:
  - Cột `Mã khách hàng` $\rightarrow$ `ma_khach_hang`
  - Cột `Tên khách hàng` $\rightarrow$ `ho_ten`
  - Cột `Điện thoại` $\rightarrow$ `so_dien_thoai`
  - Cột `Giới tính` $\rightarrow$ `gioi_tinh`
  - Cột `Ngày sinh` $\rightarrow$ `ngay_sinh`
  - Cột `Điểm hiện tại` $\rightarrow$ Tính toán delta chênh lệch và **cộng dồn điểm gộp chung**.
- **Cơ chế Batch Write**: Chia các batch tối đa 450 documents/lô để tối ưu tốc độ và an toàn với giới hạn Firestore.

---

## 5. Design System & Bộ Nhận Diện Thương Hiệu (Brand Assets)

- **Font chữ chính**: `Be Vietnam Pro` (Google Fonts CDN).
- **Màu sắc thương hiệu**:
  - Primary (Chủ đạo): Đỏ `#CB2D2E`
  - Success / Points (Tích điểm): Xanh `#1A6B5A`
  - Accent / Gold: Vàng cam `#D48806`
  - Neutral / Text: `#1E1E1E`
  - Background (Nền app): Nền kem `#F8F4EE`
  - White Surface: `#FFFFFF`
- **Bộ Logo & Icon Đồng Bộ 100% Từ Chấm Công Trạm**:
  - **Flutter Assets**: `assets/images/logo.png`, `logo.jpg`, `logo_padded.png`
  - **iOS AppIcon & LaunchImage**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` và `LaunchImage.imageset/`
  - **Android Icons**: `android/app/src/main/res/mipmap-*` và `mipmap-anydpi-v26/launcher_icon.xml`
  - **Web Favicon & PWA Icons**: `web/favicon.png` và `web/icons/`

---

## 6. Kiến Trúc Mã Nguồn (Codebase Structure)

```
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp config
│   └── router.dart                # GoRouter phân quyền & SPA redirect
├── core/
│   ├── config/
│   │   └── excel_column_config.dart # Cấu hình cột KiotViet
│   ├── constants/
│   │   └── app_colors.dart        # Bảng màu Design System
│   ├── theme/
│   │   └── app_theme.dart         # Theme Be Vietnam Pro chuẩn
│   └── widgets/                   # LoadingOverlay, EmptyState, Shimmer, v.v.
├── features/
│   ├── auth/screens/              # Splash & Login (Email, Google, Apple)
│   ├── owner/screens/             # Dashboard, Import, Customers, Staff, Reports
│   └── staff/screens/             # Tra cứu SĐT & Chi tiết tích điểm
├── models/                        # Customer, PointHistory, Store, AppUser, ImportResult
├── providers/                     # StateNotifier Riverpod providers
└── services/                      # AuthService, CustomerService, ExcelImport, ExcelExport
```

---

## 7. Cấu Hình Nền Tảng iOS & Xcode Native

- **Deployment Target**: iOS 14.0+ (Tương thích Firebase SDK 11.x).
- **CocoaPods Build Settings**: 
  - `IPHONEOS_DEPLOYMENT_TARGET = '14.0'`
  - `ENABLE_USER_SCRIPT_SANDBOXING = 'NO'` (chống lỗi PhaseScriptExecution trên Xcode 15/16).
- **Firebase Auth URL Scheme**: Đăng ký `CFBundleURLTypes` với scheme `app-1-476583007511-ios-53970f3be146a349ce1352` trong `Info.plist`.
- **Xcode Scheme**: Mặc định cấu hình `LaunchAction` sang chế độ **Release** để tối ưu hóa hiệu năng AOT khi chạy và đóng gói.

---

## 8. Triển Khai & Vận Hành (CI/CD)

- **Mã nguồn GitHub**: [github.com/2312741-sudo/khuyen_mai_tram](https://github.com/2312741-sudo/khuyen_mai_tram)
- **Web App Production (Vercel)**: [https://khuyen-mai-tram.vercel.app](https://khuyen-mai-tram.vercel.app)
- **Tự động Build**: Mỗi khi có commit mới lên branch `main`, Vercel sẽ tự động build bản phát hành release và tối ưu cache tĩnh `Cache-Control`.
- **Chạy & Build Xcode cục bộ**:
  ```bash
  # 1. Cài đặt dependencies và pods
  flutter pub get
  cd ios && pod install && cd ..
  
  # 2. Chạy test
  flutter test
  
  # 3. Mở Xcode Workspace để build Release / Archive
  open ios/Runner.xcworkspace
  ```
