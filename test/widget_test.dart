import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khuyen_mai_tram/core/theme/app_theme.dart';
import 'package:khuyen_mai_tram/core/widgets/customer_info_card.dart';
import 'package:khuyen_mai_tram/core/widgets/point_history_tile.dart';
import 'package:khuyen_mai_tram/core/widgets/empty_state.dart';
import 'package:khuyen_mai_tram/models/customer.dart';
import 'package:khuyen_mai_tram/models/point_history.dart';

void main() {
  testWidgets('CustomerInfoCard renders customer name, phone, and points', (tester) async {
    final customer = Customer(
      maKhachHang: 'KH000001',
      hoTen: 'NGUYỄN NGỌC DUY',
      soDienThoai: '0901238405',
      diemHienTai: 22,
      ngayTao: DateTime(2026, 8, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tramTheme,
        home: Scaffold(
          body: CustomerInfoCard(customer: customer),
        ),
      ),
    );

    expect(find.text('NGUYỄN NGỌC DUY'), findsOneWidget);
    expect(find.text('0901238405'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('điểm'), findsOneWidget);
  });

  testWidgets('PointHistoryTile renders points delta and store name', (tester) async {
    final history = PointHistory(
      id: 'hist-1',
      maKhachHang: 'KH000001',
      ngayTich: DateTime(2026, 8, 30, 14, 30),
      cuaHang: 'tram_chanh',
      tenCuaHang: 'Trạm Chanh',
      diemTruoc: 0,
      diemThayDoi: 22,
      diemSau: 22,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tramTheme,
        home: Scaffold(
          body: PointHistoryTile(history: history),
        ),
      ),
    );

    expect(find.text('+22 điểm'), findsOneWidget);
    expect(find.textContaining('Trạm Chanh'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
  });

  testWidgets('EmptyState renders message and subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tramTheme,
        home: Scaffold(
          body: EmptyState.search(),
        ),
      ),
    );

    expect(find.text('Không tìm thấy kết quả'), findsOneWidget);
    expect(find.text('Thử tìm kiếm với từ khóa khác'), findsOneWidget);
  });
}
