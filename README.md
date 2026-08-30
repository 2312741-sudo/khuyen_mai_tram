# Khuyến Mãi Trạm

Ứng dụng quản lý khuyến mãi, tra cứu và tích điểm khách hàng cho hệ sinh thái **Trạm**, hỗ trợ cả nền tảng **Mobile (Nhân viên)** và **Web (Chủ)**.

---

## 🚀 Tính Năng Chính

### 1. Dành cho Nhân viên (Mobile App)
- **Tra cứu thông tin khách hàng**: Tìm kiếm tức thì theo Số điện thoại hoặc Mã khách hàng.
- **Thẻ tích điểm**: Hiển thị điểm tích lũy hiện tại và lịch sử tích/đổi điểm chi tiết theo từng cửa hàng (Trạm Chanh, Trạm Sữa...).

### 2. Dành cho Chủ (Web App Dashboard)
- **Tổng quan hệ thống (Dashboard)**: Thống kê số lượng khách hàng, các cửa hàng đang hoạt động.
- **Import Excel KiotViet**: Nhập file Excel danh sách khách hàng từ KiotViet theo từng cửa hàng, tự động so sánh tính độ lệch điểm và cập nhật điểm gộp chung.
- **Xuất báo cáo Excel**: Xuất toàn bộ danh sách khách hàng và điểm tích lũy ra file `.xlsx`.
- **Quản lý khách hàng**: Bảng danh sách chi tiết, tìm kiếm và xem hồ sơ tích điểm từng khách hàng.
- **Lịch sử tích điểm**: Xem toàn bộ nhật ký tích / đổi điểm trên toàn hệ thống.

---

## 🎨 Design System

Hệ thống đồng bộ 100% với **Chấm Công Trạm**:
- **Font chữ**: Be Vietnam Pro
- **Màu chủ đạo (Primary)**: Đỏ `#CB2D2E`
- **Màu thành công / Tích điểm**: Xanh `#1A6B5A`
- **Màu nền**: Kem `#F8F4EE`

---

## 🛠 Công Nghệ Sử Dụng

- **Flutter / Dart**: Flutter SDK >= 3.0.0
- **State Management**: `flutter_riverpod` 2.6.1
- **Navigation & Routing**: `go_router` 14.8.1
- **Backend & Authentication**: Firebase Auth (Email, Google, Apple) & Cloud Firestore
- **Excel Processing**: Package `excel`

---

## 📦 Cài Đặt & Chạy Thử Nghiệm

1. Cài đặt dependencies:
```bash
flutter pub get
```

2. Chạy trên Web (Dành cho Chủ quán):
```bash
flutter run -d chrome
```

3. Chạy trên Thiết bị di động (Dành cho Nhân viên):
```bash
flutter run
```

4. Chạy kiểm thử tự động:
```bash
flutter test
```
