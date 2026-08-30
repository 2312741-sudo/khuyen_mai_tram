import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PointHistory extends Equatable {
  final String id;
  final String maKhachHang;
  final DateTime ngayTich;
  final String cuaHang; // Store ID (e.g., 'tram_chanh', 'tram_sua')
  final String? tenCuaHang; // Display name (e.g., 'Trạm Chanh')
  final int diemTruoc;
  final int diemThayDoi; // Positive = earned, Negative = redeemed
  final int diemSau;
  final String nguon; // 'import_excel'

  const PointHistory({
    required this.id,
    required this.maKhachHang,
    required this.ngayTich,
    required this.cuaHang,
    this.tenCuaHang,
    required this.diemTruoc,
    required this.diemThayDoi,
    required this.diemSau,
    this.nguon = 'import_excel',
  });

  bool get isIncrease => diemThayDoi > 0;
  bool get isDecrease => diemThayDoi < 0;
  bool get isUnchanged => diemThayDoi == 0;

  factory PointHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PointHistory(
      id: doc.id,
      maKhachHang: data['ma_khach_hang'] as String? ?? '',
      ngayTich: data['ngay_tich'] != null ? (data['ngay_tich'] as Timestamp).toDate() : DateTime.now(),
      cuaHang: data['cua_hang'] as String? ?? '',
      tenCuaHang: data['ten_cua_hang'] as String?,
      diemTruoc: (data['diem_truoc'] as num?)?.toInt() ?? 0,
      diemThayDoi: (data['diem_thay_doi'] as num?)?.toInt() ?? 0,
      diemSau: (data['diem_sau'] as num?)?.toInt() ?? 0,
      nguon: data['nguon'] as String? ?? 'import_excel',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ma_khach_hang': maKhachHang,
      'ngay_tich': Timestamp.fromDate(ngayTich),
      'cua_hang': cuaHang,
      'ten_cua_hang': tenCuaHang,
      'diem_truoc': diemTruoc,
      'diem_thay_doi': diemThayDoi,
      'diem_sau': diemSau,
      'nguon': nguon,
    };
  }

  @override
  List<Object?> get props => [id, maKhachHang, ngayTich, cuaHang, diemTruoc, diemThayDoi, diemSau, nguon];
}
