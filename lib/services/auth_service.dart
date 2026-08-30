import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class StaffWithStore {
  final AppUser user;
  final String storeId;
  final List<String> storeNames;
  final String cctRole;

  const StaffWithStore({
    required this.user,
    required this.storeId,
    required this.storeNames,
    required this.cctRole,
  });

  StaffWithStore copyWith({
    AppUser? user,
    String? storeId,
    List<String>? storeNames,
    String? cctRole,
  }) {
    return StaffWithStore(
      user: user ?? this.user,
      storeId: storeId ?? this.storeId,
      storeNames: storeNames ?? this.storeNames,
      cctRole: cctRole ?? this.cctRole,
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user == null) return null;
    return await _getAppUser(credential.user!.uid);
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(googleProvider);
      }

      if (userCredential.user != null) {
        return await _getAppUser(userCredential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-cancelled' ||
          e.code == 'cancelled' ||
          e.code == 'user-cancelled' ||
          e.code == 'canceled') {
        throw FirebaseAuthException(
          code: 'cancelled',
          message: 'Người dùng đã hủy đăng nhập Google',
        );
      }
      rethrow;
    }
  }

  Future<AppUser?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(appleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(appleProvider);
      }

      if (userCredential.user != null) {
        return await _getAppUser(userCredential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-cancelled' ||
          e.code == 'cancelled' ||
          e.code == 'user-cancelled' ||
          e.code == 'canceled') {
        throw FirebaseAuthException(
          code: 'cancelled',
          message: 'Người dùng đã hủy đăng nhập Apple',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getAppUser(firebaseUser.uid);
  }

  Future<AppUser?> _getAppUser(String uid) async {
    final fbUser = _auth.currentUser;
    Map<String, dynamic> userData = {};
    String? currentStoreId;
    KmtRole role = KmtRole.staff;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (userDoc.exists && userDoc.data() != null) {
        userData = userDoc.data()!;
        currentStoreId = userData['currentStoreId'] as String?;
      }
    } catch (e) {
      debugPrint('User doc fetch notice: $e');
    }

    try {
      final ownedStores = await _firestore
          .collection('stores')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 3));

      if (ownedStores.docs.isNotEmpty) {
        role = KmtRole.owner;
        currentStoreId ??= ownedStores.docs.first.id;
      }
    } catch (e) {
      debugPrint('Owner store check notice: $e');
    }

    if (role != KmtRole.owner && currentStoreId != null && currentStoreId.isNotEmpty) {
      try {
        final memberDoc = await _firestore
            .collection('stores')
            .doc(currentStoreId)
            .collection('members')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 3));

        if (memberDoc.exists && memberDoc.data() != null) {
          final memberData = memberDoc.data()!;
          final cctRole = memberData['role'] as String? ?? 'employee';
          role = KmtRole.fromCctRole(cctRole);
        }
      } catch (e) {
        debugPrint('Member role check notice: $e');
      }
    }

    return AppUser(
      uid: uid,
      name: userData['name'] as String? ?? (fbUser?.displayName ?? 'Người dùng'),
      email: userData['email'] as String? ?? (fbUser?.email ?? ''),
      phone: userData['phone'] as String? ?? fbUser?.phoneNumber,
      avatarUrl: userData['avatarUrl'] as String? ?? fbUser?.photoURL,
      role: role,
      currentStoreId: currentStoreId,
    );
  }

  // Filter helper: ONLY Trạm Chanh and Trạm Sữa
  static bool isOfficialStore(String name, String id) {
    final lowerName = name.toLowerCase().trim();
    final lowerId = id.toLowerCase().trim();
    final isChanh = lowerName.contains('chanh') || lowerId.contains('chanh');
    final isSua = lowerName.contains('sữa') || lowerName.contains('sua') || lowerId.contains('sua');
    final isTestOrKho = lowerName.contains('test') || lowerName.contains('kho') || lowerId.contains('test') || lowerId.contains('kho');
    return (isChanh || isSua) && !isTestOrKho;
  }

  // Get official stores (Only Trạm Chanh & Trạm Sữa)
  Future<Map<String, String>> getAvailableStores() async {
    final storeMap = <String, String>{};
    try {
      final storesSnapshot = await _firestore.collection('stores').get();
      for (final doc in storesSnapshot.docs) {
        final name = doc.data()['name'] as String? ?? doc.id;
        if (isOfficialStore(name, doc.id)) {
          storeMap[doc.id] = name;
        }
      }
    } catch (_) {}

    // Fallback standard stores if none found
    if (storeMap.isEmpty) {
      storeMap['tram_chanh'] = 'TRẠM CHANH';
      storeMap['tram_sua'] = 'TRẠM SỮA';
    }
    return storeMap;
  }

  // Get staff with automatic deduplication (1 row per employee, combined store tags)
  Future<List<StaffWithStore>> getAllStaffMembers({String? storeIdFilter}) async {
    try {
      final storeMap = await getAvailableStores();
      final targetStoreIds = (storeIdFilter != null && storeIdFilter != 'all')
          ? [storeIdFilter]
          : storeMap.keys.toList();

      // Deduplication map: key = normalized user name or uid -> StaffWithStore
      final staffMap = <String, StaffWithStore>{};

      for (final storeId in targetStoreIds) {
        final storeName = storeMap[storeId] ?? storeId;
        try {
          final membersSnapshot = await _firestore
              .collection('stores')
              .doc(storeId)
              .collection('members')
              .where('status', isEqualTo: 'active')
              .get();

          for (final doc in membersSnapshot.docs) {
            final data = doc.data();
            final cctRole = data['role'] as String? ?? 'employee';
            if (cctRole == 'owner') continue;

            final uid = doc.id;
            final name = (data['name'] as String? ?? '').trim();
            final phone = data['phone'] as String?;
            final avatarUrl = data['avatarUrl'] as String?;

            // Unique key by UID or normalized Name + Phone
            final dedupeKey = uid.isNotEmpty ? uid : '${name.toLowerCase()}_${phone ?? ''}';

            if (staffMap.containsKey(dedupeKey)) {
              // Employee exists in both stores -> Merge store names into 1 record!
              final existing = staffMap[dedupeKey]!;
              final updatedStores = List<String>.from(existing.storeNames);
              if (!updatedStores.contains(storeName)) {
                updatedStores.add(storeName);
              }
              // Keep manager role if higher
              final updatedRole = (existing.cctRole.contains('manager') || cctRole.contains('manager'))
                  ? 'manager'
                  : existing.cctRole;

              staffMap[dedupeKey] = existing.copyWith(
                storeNames: updatedStores,
                cctRole: updatedRole,
              );
            } else {
              // New employee record
              staffMap[dedupeKey] = StaffWithStore(
                user: AppUser(
                  uid: uid,
                  name: name,
                  email: '',
                  phone: phone,
                  avatarUrl: avatarUrl,
                  role: KmtRole.staff,
                  currentStoreId: storeId,
                ),
                storeId: storeId,
                storeNames: [storeName],
                cctRole: cctRole,
              );
            }
          }
        } catch (e) {
          debugPrint('Error fetching members for $storeId: $e');
        }
      }

      final list = staffMap.values.toList();
      list.sort((a, b) => a.user.name.compareTo(b.user.name));
      return list;
    } catch (e) {
      debugPrint('Error in getAllStaffMembers: $e');
      return [];
    }
  }

  static String parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'cancelled': return 'Đã hủy thao tác đăng nhập';
      case 'user-not-found': return 'Tài khoản không tồn tại';
      case 'wrong-password': return 'Mật khẩu không đúng';
      case 'invalid-credential': return 'Email hoặc mật khẩu không đúng';
      case 'email-already-in-use': return 'Email này đã được sử dụng';
      case 'weak-password': return 'Mật khẩu phải có ít nhất 6 ký tự';
      case 'invalid-email': return 'Địa chỉ email không hợp lệ';
      case 'network-request-failed': return 'Lỗi kết nối mạng';
      case 'too-many-requests': return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      default: return 'Có lỗi xảy ra: ${e.message}';
    }
  }
}
