import 'package:equatable/equatable.dart';

/// Role trong app Khuyến Mãi Trạm
/// Mapping từ Chấm Công Trạm:
/// - CCT 'owner' → KMT owner (chủ)
/// - CCT 'manager_1', 'manager_2', 'manager', 'employee' → KMT staff (nhân viên)
enum KmtRole {
  owner,
  staff;

  String get label {
    switch (this) {
      case KmtRole.owner:
        return 'Chủ';
      case KmtRole.staff:
        return 'Nhân viên';
    }
  }

  bool get isOwner => this == KmtRole.owner;
  bool get isStaff => this == KmtRole.staff;

  /// Map role string from CCT Firestore member document to KMT role
  static KmtRole fromCctRole(String? cctRole) {
    if (cctRole == 'owner') return KmtRole.owner;
    return KmtRole.staff; // All other roles (manager_1, manager_2, manager, employee) are staff
  }
}

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final KmtRole role;
  final String? currentStoreId; // The CCT store ID (used to look up member role)

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.currentStoreId,
  });

  bool get isOwner => role.isOwner;
  bool get isStaff => role.isStaff;

  @override
  List<Object?> get props => [uid, name, email, phone, avatarUrl, role, currentStoreId];

  @override
  String toString() => 'AppUser(uid: $uid, name: $name, role: ${role.label})';
}
