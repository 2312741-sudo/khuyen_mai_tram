import 'package:flutter_test/flutter_test.dart';
import 'package:khuyen_mai_tram/models/customer.dart';
import 'package:khuyen_mai_tram/models/point_history.dart';
import 'package:khuyen_mai_tram/models/import_result.dart';
import 'package:khuyen_mai_tram/models/app_user.dart';

void main() {
  group('Customer Model Tests', () {
    test('Customer creation and props comparison', () {
      final now = DateTime(2026, 8, 30);
      final c1 = Customer(
        maKhachHang: 'KH000001',
        hoTen: 'NGUYỄN NGỌC DUY',
        soDienThoai: '0901238405',
        diemHienTai: 22,
        ngayTao: now,
      );

      final c2 = Customer(
        maKhachHang: 'KH000001',
        hoTen: 'NGUYỄN NGỌC DUY',
        soDienThoai: '0901238405',
        diemHienTai: 22,
        ngayTao: now,
      );

      expect(c1, equals(c2));
      expect(c1.diemHienTai, 22);
    });

    test('Customer copyWith updates points properly', () {
      final now = DateTime(2026, 8, 30);
      final customer = Customer(
        maKhachHang: 'KH000001',
        hoTen: 'NGUYỄN NGỌC DUY',
        soDienThoai: '0901238405',
        diemHienTai: 22,
        ngayTao: now,
      );

      final updated = customer.copyWith(diemHienTai: 50);
      expect(updated.diemHienTai, 50);
      expect(updated.maKhachHang, 'KH000001');
      expect(updated.hoTen, 'NGUYỄN NGỌC DUY');
    });
  });

  group('PointHistory Model Tests', () {
    test('PointHistory calculations and types', () {
      final now = DateTime(2026, 8, 30);
      final historyInc = PointHistory(
        id: 'hist-1',
        maKhachHang: 'KH000001',
        ngayTich: now,
        cuaHang: 'tram_chanh',
        tenCuaHang: 'Trạm Chanh',
        diemTruoc: 0,
        diemThayDoi: 22,
        diemSau: 22,
      );

      expect(historyInc.isIncrease, true);
      expect(historyInc.isDecrease, false);
      expect(historyInc.isUnchanged, false);

      final historyDec = PointHistory(
        id: 'hist-2',
        maKhachHang: 'KH000001',
        ngayTich: now,
        cuaHang: 'tram_sua',
        tenCuaHang: 'Trạm Sữa',
        diemTruoc: 22,
        diemThayDoi: -10,
        diemSau: 12,
      );

      expect(historyDec.isIncrease, false);
      expect(historyDec.isDecrease, true);
    });
  });

  group('ImportResult Tests', () {
    test('ImportResult stats computation', () {
      final result = ImportResult(
        totalRows: 10,
        newCustomers: 3,
        pointsIncreased: 5,
        pointsDecreased: 1,
        unchanged: 1,
        errors: 0,
        errorDetails: const [],
        storeName: 'Trạm Chanh',
        storeId: 'tram_chanh',
        importedAt: DateTime.now(),
      );

      expect(result.isSuccess, true);
      expect(result.hasErrors, false);
      expect(result.processed, 10);
    });
  });

  group('Role Mapping Tests', () {
    test('CCT role mapping to KMT role', () {
      expect(KmtRole.fromCctRole('owner'), KmtRole.owner);
      expect(KmtRole.fromCctRole('manager_1'), KmtRole.staff);
      expect(KmtRole.fromCctRole('manager_2'), KmtRole.staff);
      expect(KmtRole.fromCctRole('manager'), KmtRole.staff);
      expect(KmtRole.fromCctRole('employee'), KmtRole.staff);
    });
  });
}
