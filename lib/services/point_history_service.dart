import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/point_history.dart';

class PointHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'kmt_point_history';

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _firestore.collection(_collection);

  /// Get history for a specific customer (sorted by date descending)
  Future<List<PointHistory>> getByCustomer(String maKhachHang, {int limit = 50}) async {
    final snapshot = await _historyRef
        .where('ma_khach_hang', isEqualTo: maKhachHang)
        .orderBy('ngay_tich', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => PointHistory.fromFirestore(doc)).toList();
  }

  /// Get history by store (with optional date range)
  Future<List<PointHistory>> getByStore(
    String storeId, {
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    Query<Map<String, dynamic>> query = _historyRef
        .where('cua_hang', isEqualTo: storeId)
        .orderBy('ngay_tich', descending: true);

    if (from != null) {
      query = query.where('ngay_tich', isGreaterThanOrEqualTo: from);
    }
    if (to != null) {
      query = query.where('ngay_tich', isLessThanOrEqualTo: to);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => PointHistory.fromFirestore(doc)).toList();
  }

  /// Get all history (paginated)
  Future<List<PointHistory>> getAll({
    int limit = 50,
    DocumentSnapshot? startAfter,
    String? storeFilter,
    String? customerFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    Query<Map<String, dynamic>> query = _historyRef.orderBy('ngay_tich', descending: true);

    if (storeFilter != null && storeFilter.isNotEmpty) {
      query = query.where('cua_hang', isEqualTo: storeFilter);
    }
    if (customerFilter != null && customerFilter.isNotEmpty) {
      query = query.where('ma_khach_hang', isEqualTo: customerFilter);
    }
    if (dateFrom != null) {
      query = query.where('ngay_tich', isGreaterThanOrEqualTo: dateFrom);
    }
    if (dateTo != null) {
      query = query.where('ngay_tich', isLessThanOrEqualTo: dateTo);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => PointHistory.fromFirestore(doc)).toList();
  }

  /// Add a new point history record
  Future<void> addHistory(PointHistory history) async {
    await _historyRef.add(history.toFirestore());
  }
}
