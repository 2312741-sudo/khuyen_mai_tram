# Cấu Trúc Dữ Liệu & Firestore Schema (Khuyến Mãi Trạm)

Hệ thống "Khuyến Mãi Trạm" dùng chung Firebase Project với "Chấm Công Trạm", trong đó:
1. **Tài khoản & Phân quyền**: Tái sử dụng dữ liệu từ Firestore `/users` và `/stores/{storeId}/members` của Chấm Công Trạm.
2. **Dữ liệu Khuyến mãi**: Lưu tại các collection độc lập có prefix `kmt_`.

---

## 1. Phân Quyền & Mapping Role

- **Chủ (Owner)**: Khi tài khoản có role `owner` trong Chấm Công Trạm. Có toàn quyền xem thống kê, import Excel từ các cửa hàng, quản lý danh sách khách hàng, xem báo cáo lịch sử và xuất file Excel.
- **Nhân viên (Staff)**: Gộp tất cả các role `manager_1`, `manager_2`, `manager`, `employee` từ Chấm Công Trạm thành vai trò `staff` trong Khuyến Mãi Trạm. Nhân viên chỉ tra cứu thông tin khách hàng và lịch sử tích/đổi điểm tại cửa hàng.

---

## 2. Firestore Collections

### A. `kmt_customers` (Khách hàng)
- **Path**: `/kmt_customers/{maKhachHang}`
- **Fields**:
  - `ma_khach_hang` (`string`): Mã khách hàng (KH000001...)
  - `ho_ten` (`string`): Họ tên khách hàng
  - `ho_ten_upper` (`string`): Họ tên viết hoa (hỗ trợ tìm kiếm prefix)
  - `so_dien_thoai` (`string`): Số điện thoại chuẩn hóa
  - `gioi_tinh` (`string?`): Nam / Nữ / Khác
  - `ngay_sinh` (`timestamp?`): Ngày sinh
  - `diem_hien_tai` (`number`): Điểm tích lũy hiện tại (Gộp chung giữa các cửa hàng)
  - `ngay_tao` (`timestamp`): Ngày tạo khách hàng
  - `ngay_cap_nhat` (`timestamp?`): Ngày cập nhật gần nhất

### B. `kmt_point_history` (Lịch sử tích / đổi điểm)
- **Path**: `/kmt_point_history/{autoId}`
- **Fields**:
  - `ma_khach_hang` (`string`): Mã khách hàng
  - `cua_hang` (`string`): ID cửa hàng (`tram_chanh`, `tram_sua`...)
  - `ten_cua_hang` (`string?`): Tên hiển thị cửa hàng (Trạm Chanh, Trạm Sữa...)
  - `diem_truoc` (`number`): Điểm trước khi thay đổi
  - `diem_thay_doi` (`number`): Điểm thay đổi (dương: tích điểm, âm: đổi/trừ điểm)
  - `diem_sau` (`number`): Điểm sau khi thay đổi
  - `ngay_tich` (`timestamp`): Thời điểm ghi nhận
  - `nguon` (`string`): Nguồn ghi nhận (`import_excel`)

### C. `kmt_stores` (Cửa hàng)
- **Path**: `/kmt_stores/{storeId}`
- **Fields**:
  - `name` (`string`): Tên cửa hàng (Trạm Chanh, Trạm Sữa...)
  - `created_at` (`timestamp`): Thời gian khởi tạo

---

## 3. Luồng Xử Lý Import Excel (KiotViet)

```
File Excel (.xlsx) tải lên từ Web
  │
  ▼
Đọc Header & Map cột theo ExcelColumnConfig
  │
  ▼
Bỏ qua dòng Header (Dòng 0) và Dòng Tổng hợp (Dòng 1)
  │
  ▼
Duyệt từng dòng khách hàng (Từ dòng 2):
  ├── Tìm khách hàng theo Mã KH hoặc SĐT trong Firestore:
  │     ├── ĐÃ TỒN TẠI:
  │     │     ├── Delta = Điểm mới trong file - Điểm hiện tại Firestore
  │     │     ├── Nếu Delta != 0:
  │     │     │     ├── Cập nhật `diem_hien_tai` = Điểm mới
  │     │     │     └── Ghi 1 bản ghi `kmt_point_history` (diemTruoc, diemThayDoi=Delta, diemSau)
  │     │     └── Cập nhật thông tin (Họ tên, SĐT, Ngày sinh...)
  │     └── CHƯA TỒN TẠI:
  │           ├── Tạo `kmt_customers` mới với điểm ban đầu = Điểm trong file
  │           └── Ghi 1 bản ghi `kmt_point_history` (diemTruoc=0, diemThayDoi=Điểm, diemSau=Điểm)
  │
  ▼
Thực thi theo Batch Write (450 docs / batch)
  │
  ▼
Trả về kết quả ImportResult (Khách mới, Tăng điểm, Giảm điểm, Không đổi, Lỗi)
```
