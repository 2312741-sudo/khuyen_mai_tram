/// Cấu hình mapping cột file Excel từ KiotViet.
/// Khi KiotViet thay đổi tên cột, chỉ cần sửa ở đây.
class ExcelColumnConfig {
  ExcelColumnConfig._();

  static const String colMaKhachHang = 'Mã khách hàng';
  static const String colHoTen = 'Tên khách hàng';
  static const String colDienThoai = 'Điện thoại';
  static const String colGioiTinh = 'Giới tính';
  static const String colNgaySinh = 'Ngày sinh';
  static const String colDiemHienTai = 'Điểm hiện tại';
  static const String colTongDiem = 'Tổng điểm';

  static const List<String> requiredColumns = [colHoTen, colDiemHienTai];
  static const List<String> optionalColumns = [colMaKhachHang, colDienThoai, colNgaySinh, colGioiTinh, colTongDiem];
  static const List<String> ignoredColumns = ['Nợ hiện tại', 'Tổng bán trừ trả hàng'];

  static const int headerRowIndex = 0;
  static const int dataStartRowIndex = 2;
  static const String dateFormat = 'dd/MM/yyyy';
}
