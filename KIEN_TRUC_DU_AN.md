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

## 5. Design System Đồng Bộ Chấm Công Trạm

- **Font chữ chính**: `Be Vietnam Pro` (Google Fonts CDN).
- **Màu sắc thương hiệu**:
  - Primary (Chủ đạo): Đỏ `#CB2D2E`
  - Success / Points (Tích điểm): Xanh `#1A6B5A`
  - Accent / Gold: Vàng cam `#D48806`
  - Neutral / Text: `#1E1E1E`
  - Background (Nền app): Nền kem `#F8F4EE`
  - White Surface: `#FFFFFF`

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

## 7. Triển Khai & Vận Hành (CI/CD)

- **Mã nguồn GitHub**: [github.com/2312741-sudo/khuyen_mai_tram](https://github.com/2312741-sudo/khuyen_mai_tram)
- **Web App Production (Vercel)**: [https://khuyen-mai-tram.vercel.app](https://khuyen-mai-tram.vercel.app)
- **Tự động Build**: Mỗi khi có commit mới lên branch `main`, Vercel sẽ tự động build bản phát hành release và tối ưu cache tĩnh `Cache-Control`.
