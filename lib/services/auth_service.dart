import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class StaffWithStore {
  final AppUser user;
  final String storeId;
  final String storeName;
  final String cctRole;

  const StaffWithStore({
    required this.user,
    required this.storeId,
    required this.storeName,
    required this.cctRole,
  });
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
      // 1. Get user document from CCT users collection
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

    // 2. Check if user is owner of any store in CCT stores collection
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

    // 3. If not confirmed owner, check member role in stores/{currentStoreId}/members/{uid}
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

  // Get all staff members across ALL stores or filtered by a specific store
  Future<List<StaffWithStore>> getAllStaffMembers({String? storeIdFilter}) async {
    try {
      // 1. Fetch all store documents from CCT /stores collection
      final storesSnapshot = await _firestore.collection('stores').get();
      final storeMap = <String, String>{}; // storeId -> storeName

      for (final doc in storesSnapshot.docs) {
        final data = doc.data();
        storeMap[doc.id] = data['name'] as String? ?? doc.id;
      }

      // If CCT /stores query was empty or offline, fallback to standard Trạm stores
      if (storeMap.isEmpty) {
        storeMap['tram_chanh'] = 'Trạm Chanh';
        storeMap['tram_sua'] = 'Trạm Sữa';
      }

      final results = <StaffWithStore>[];
      final targetStoreIds = (storeIdFilter != null && storeIdFilter != 'all')
          ? [storeIdFilter]
          : storeMap.keys.toList();

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

            results.add(StaffWithStore(
              user: AppUser(
                uid: doc.id,
                name: data['name'] as String? ?? '',
                email: '',
                phone: data['phone'] as String?,
                avatarUrl: data['avatarUrl'] as String?,
                role: KmtRole.staff,
                currentStoreId: storeId,
              ),
              storeId: storeId,
              storeName: storeName,
              cctRole: cctRole,
            ));
          }
        } catch (e) {
          debugPrint('Error getting members for store $storeId: $e');
        }
      }

      // Sort alphabetically by staff name
      results.sort((a, b) => a.user.name.compareTo(b.user.name));
      return results;
    } catch (e) {
      debugPrint('Error getAllStaffMembers: $e');
      return [];
    }
  }

  // Get list of available CCT stores
  Future<Map<String, String>> getAvailableStores() async {
    try {
      final storesSnapshot = await _firestore.collection('stores').get();
      final storeMap = <String, String>{};
      for (final doc in storesSnapshot.docs) {
        final data = doc.data();
        storeMap[doc.id] = data['name'] as String? ?? doc.id;
      }
      if (storeMap.isNotEmpty) return storeMap;
    } catch (_) {}
    return {
      'tram_chanh': 'Trạm Chanh',
      'tram_sua': 'Trạm Sữa',
    };
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
