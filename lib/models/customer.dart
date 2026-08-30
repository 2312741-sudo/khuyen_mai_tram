import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String maKhachHang;
  final String hoTen;
  final DateTime? ngaySinh;
  final String? gioiTinh; // 'Nam', 'Nữ', 'Khác'
  final String soDienThoai;
  final int diemHienTai;
  final DateTime ngayTao;
  final DateTime? ngayCapNhat;

  const Customer({
    required this.maKhachHang,
    required this.hoTen,
    this.ngaySinh,
    this.gioiTinh,
    required this.soDienThoai,
    required this.diemHienTai,
    required this.ngayTao,
    this.ngayCapNhat,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      maKhachHang: doc.id,
      hoTen: data['ho_ten'] as String? ?? '',
      ngaySinh: data['ngay_sinh'] != null ? (data['ngay_sinh'] as Timestamp).toDate() : null,
      gioiTinh: data['gioi_tinh'] as String?,
      soDienThoai: data['so_dien_thoai'] as String? ?? '',
      diemHienTai: (data['diem_hien_tai'] as num?)?.toInt() ?? 0,
      ngayTao: data['ngay_tao'] != null ? (data['ngay_tao'] as Timestamp).toDate() : DateTime.now(),
      ngayCapNhat: data['ngay_cap_nhat'] != null ? (data['ngay_cap_nhat'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ho_ten': hoTen,
      'ngay_sinh': ngaySinh != null ? Timestamp.fromDate(ngaySinh!) : null,
      'gioi_tinh': gioiTinh,
      'so_dien_thoai': soDienThoai,
      'diem_hien_tai': diemHienTai,
      'ngay_tao': Timestamp.fromDate(ngayTao),
      'ngay_cap_nhat': ngayCapNhat != null ? Timestamp.fromDate(ngayCapNhat!) : null,
    };
  }

  Customer copyWith({
    String? maKhachHang,
    String? hoTen,
    DateTime? ngaySinh,
    String? gioiTinh,
    String? soDienThoai,
    int? diemHienTai,
    DateTime? ngayTao,
    DateTime? ngayCapNhat,
    bool clearNgaySinh = false,
    bool clearGioiTinh = false,
  }) {
    return Customer(
      maKhachHang: maKhachHang ?? this.maKhachHang,
      hoTen: hoTen ?? this.hoTen,
      ngaySinh: clearNgaySinh ? null : (ngaySinh ?? this.ngaySinh),
      gioiTinh: clearGioiTinh ? null : (gioiTinh ?? this.gioiTinh),
      soDienThoai: soDienThoai ?? this.soDienThoai,
      diemHienTai: diemHienTai ?? this.diemHienTai,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
    );
  }

  @override
  List<Object?> get props => [maKhachHang, hoTen, ngaySinh, gioiTinh, soDienThoai, diemHienTai, ngayTao, ngayCapNhat];

  @override
  String toString() => 'Customer(maKH: $maKhachHang, hoTen: $hoTen, diem: $diemHienTai)';
}
