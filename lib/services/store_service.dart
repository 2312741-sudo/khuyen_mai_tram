import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/store.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'kmt_stores';

  CollectionReference<Map<String, dynamic>> get _storesRef =>
      _firestore.collection(_collection);

  static List<KmtStore> get defaultStores => [
    KmtStore(id: 'tram_chanh', name: 'Trạm Chanh', createdAt: DateTime(2026, 1, 1)),
    KmtStore(id: 'tram_sua', name: 'Trạm Sữa', createdAt: DateTime(2026, 1, 1)),
  ];

  /// Get all KMT stores (with fallback to default stores if collection is empty or uninitialized)
  Future<List<KmtStore>> getAllStores() async {
    try {
      final snapshot = await _storesRef.orderBy('name').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => KmtStore.fromFirestore(doc)).toList();
      }
    } catch (_) {
      // Fallback to default stores on error or before collection created
    }
    return defaultStores;
  }

  /// Get a single store by ID
  Future<KmtStore?> getStore(String storeId) async {
    try {
      final doc = await _storesRef.doc(storeId).get();
      if (doc.exists) {
        return KmtStore.fromFirestore(doc);
      }
    } catch (_) {}
    // Fallback to default stores
    final found = defaultStores.where((s) => s.id == storeId);
    return found.isNotEmpty ? found.first : null;
  }

  /// Create a new store
  Future<void> createStore(KmtStore store) async {
    await _storesRef.doc(store.id).set(store.toFirestore());
  }

  /// Seed default stores if user is authenticated and they don't exist
  Future<void> seedDefaultStores() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      for (final store in defaultStores) {
        final doc = await _storesRef.doc(store.id).get();
        if (!doc.exists) {
          await _storesRef.doc(store.id).set(store.toFirestore());
        }
      }
    } catch (_) {
      // Best-effort seeding
    }
  }
}
