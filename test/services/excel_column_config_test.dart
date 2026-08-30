import 'package:flutter_test/flutter_test.dart';
import 'package:khuyen_mai_tram/core/config/excel_column_config.dart';

void main() {
  group('ExcelColumnConfig Tests', () {
    test('Required columns contain customer name and current points', () {
      expect(ExcelColumnConfig.requiredColumns, contains(ExcelColumnConfig.colHoTen));
      expect(ExcelColumnConfig.requiredColumns, contains(ExcelColumnConfig.colDiemHienTai));
    });

    test('Data start row index is 2 (skips header and summary row)', () {
      expect(ExcelColumnConfig.dataStartRowIndex, 2);
      expect(ExcelColumnConfig.headerRowIndex, 0);
    });

    test('Column names match KiotViet export format', () {
      expect(ExcelColumnConfig.colMaKhachHang, 'Mã khách hàng');
      expect(ExcelColumnConfig.colHoTen, 'Tên khách hàng');
      expect(ExcelColumnConfig.colDienThoai, 'Điện thoại');
      expect(ExcelColumnConfig.colGioiTinh, 'Giới tính');
      expect(ExcelColumnConfig.colNgaySinh, 'Ngày sinh');
      expect(ExcelColumnConfig.colDiemHienTai, 'Điểm hiện tại');
      expect(ExcelColumnConfig.colTongDiem, 'Tổng điểm');
    });
  });
}
