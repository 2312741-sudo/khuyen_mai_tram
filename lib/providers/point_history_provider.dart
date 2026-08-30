import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/point_history.dart';
import '../services/point_history_service.dart';

final pointHistoryServiceProvider = Provider<PointHistoryService>((ref) => PointHistoryService());

final customerHistoryProvider = FutureProvider.family<List<PointHistory>, String>((ref, maKhachHang) async {
  return ref.read(pointHistoryServiceProvider).getByCustomer(maKhachHang);
});

final allHistoryProvider = FutureProvider<List<PointHistory>>((ref) async {
  return ref.read(pointHistoryServiceProvider).getAll(limit: 100);
});
