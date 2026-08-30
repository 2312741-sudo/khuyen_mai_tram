# Hướng Dẫn Cấu Hình Cột Excel KiotViet

File cấu hình tại: [`lib/core/config/excel_column_config.dart`](file:///d:/khuyen_mai_tram/lib/core/config/excel_column_config.dart)

## 1. Cấu trúc bảng tính KiotViet mặc định

Theo mẫu xuất từ KiotViet:
- **Dòng 0 (Header):** Tiêu đề các cột
- **Dòng 1 (Summary):** Dòng tổng hợp (chứa tổng nợ, tổng bán, tổng điểm...) -> Hệ thống tự động bỏ qua (Skip)
- **Dòng 2 trở đi (Data):** Dữ liệu khách hàng thực tế (`dataStartRowIndex = 2`)

### Bảng mapping các cột:

| Tên cột trong file Excel | Tên biến trong Config | Bắt buộc? | Mô tả |
| :--- | :--- | :---: | :--- |
| `Mã khách hàng` | `colMaKhachHang` | Không | Mã định danh khách (KH000001, KH000002...). Nếu thiếu, hệ thống tự sinh mã `KMT...` |
| `Tên khách hàng` | `colHoTen` | **Có** | Họ và tên khách hàng |
| `Điện thoại` | `colDienThoai` | Không | Số điện thoại dùng để tra cứu |
| `Giới tính` | `colGioiTinh` | Không | Nam / Nữ / Khác |
| `Ngày sinh` | `colNgaySinh` | Không | Định dạng `dd/MM/yyyy` (vd: 30/08/1997) |
| `Điểm hiện tại` | `colDiemHienTai` | **Có** | Điểm tích luỹ của khách hàng |
| `Tổng điểm` | `colTongDiem` | Không | Tổng điểm lịch sử |
| `Nợ hiện tại` | - | *Bỏ qua* | Không sử dụng trong app khuyến mãi |
| `Tổng bán trừ trả hàng` | - | *Bỏ qua* | Không sử dụng trong app khuyến mãi |

---

## 2. Cách thay đổi mapping khi KiotViet đổi tên cột

Nếu KiotViet thay đổi giao diện/xuất file với tên cột khác (ví dụ: `Điện thoại` đổi thành `Số điện thoại`), bạn chỉ cần mở file [`lib/core/config/excel_column_config.dart`](file:///d:/khuyen_mai_tram/lib/core/config/excel_column_config.dart) và sửa:

```dart
// Trước khi sửa:
static const String colDienThoai = 'Điện thoại';

// Sau khi sửa:
static const String colDienThoai = 'Số điện thoại';
```

Hệ thống tự động tìm kiếm cột theo **Tên Header** thay vì cố định số thứ tự cột, giúp việc thêm/bớt cột từ KiotViet không làm gãy quá trình Import.
