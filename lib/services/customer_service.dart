import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'kmt_customers';

  CollectionReference<Map<String, dynamic>> get _customersRef =>
      _firestore.collection(_collection);

  /// Search by phone number (exact match)
  Future<List<Customer>> searchByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return [];

    final snapshot = await _customersRef
        .where('so_dien_thoai', isEqualTo: normalized)
        .get();

    return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
  }

  /// Search by customer code (exact match)
  Future<Customer?> searchByCode(String code) async {
    final doc = await _customersRef.doc(code.toUpperCase()).get();
    if (!doc.exists) return null;
    return Customer.fromFirestore(doc);
  }

  /// Smart search: auto-detect phone (all digits) vs code
  Future<List<Customer>> searchByKeyword(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];

    // If all digits or starts with 0/+, treat as phone search
    final isPhone = RegExp(r'^[+]?[0-9]+$').hasMatch(trimmed);
    if (isPhone) {
      return await searchByPhone(trimmed);
    }

    // Try exact code match first
    final byCode = await searchByCode(trimmed);
    if (byCode != null) return [byCode];

    // Fallback: search by name prefix (limited Firestore text search)
    final upper = trimmed.toUpperCase();
    final snapshot = await _customersRef
        .where('ho_ten_upper', isGreaterThanOrEqualTo: upper)
        .where('ho_ten_upper', isLessThanOrEqualTo: '$upper\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
  }

  /// Get single customer by ID
  Future<Customer?> getCustomer(String maKhachHang) async {
    final doc = await _customersRef.doc(maKhachHang).get();
    if (!doc.exists) return null;
    return Customer.fromFirestore(doc);
  }

  /// Get all customers (paginated)
  Future<List<Customer>> getAllCustomers({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query = _customersRef
        .orderBy(orderBy ?? 'ho_ten', descending: descending)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
  }

  /// Get total customer count
  Future<int> getCustomerCount() async {
    final snapshot = await _customersRef.count().get();
    return snapshot.count ?? 0;
  }

  /// Create a new customer
  Future<void> createCustomer(Customer customer) async {
    final data = customer.toFirestore();
    data['ho_ten_upper'] = customer.hoTen.toUpperCase();
    await _customersRef.doc(customer.maKhachHang).set(data);
  }

  /// Update an existing customer
  Future<void> updateCustomer(Customer customer) async {
    final data = customer.toFirestore();
    data['ho_ten_upper'] = customer.hoTen.toUpperCase();
    data['ngay_cap_nhat'] = FieldValue.serverTimestamp();
    await _customersRef.doc(customer.maKhachHang).update(data);
  }

  /// Update customer points
  Future<void> updatePoints(String maKhachHang, int newPoints) async {
    await _customersRef.doc(maKhachHang).update({
      'diem_hien_tai': newPoints,
      'ngay_cap_nhat': FieldValue.serverTimestamp(),
    });
  }

  /// Find customer by phone or code (for import matching)
  Future<Customer?> findByPhoneOrCode(String? phone, String? code) async {
    // Try by code first (faster - direct doc lookup)
    if (code != null && code.isNotEmpty) {
      final byCode = await searchByCode(code);
      if (byCode != null) return byCode;
    }
    // Then by phone
    if (phone != null && phone.isNotEmpty) {
      final byPhone = await searchByPhone(phone);
      if (byPhone.isNotEmpty) return byPhone.first;
    }
    return null;
  }
}
