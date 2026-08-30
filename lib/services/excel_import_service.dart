import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../core/config/excel_column_config.dart';
import '../models/customer.dart';
import '../models/import_result.dart';
import '../models/point_history.dart';
import '../services/customer_service.dart';

class ExcelImportService {
  final CustomerService _customerService = CustomerService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Import an Excel file for a specific store
  /// [fileBytes] - the raw bytes of the .xlsx file
  /// [storeId] - the store ID (e.g., 'tram_chanh')
  /// [storeName] - display name (e.g., 'Trạm Chanh')
  Future<ImportResult> importExcel({
    required Uint8List fileBytes,
    required String storeId,
    required String storeName,
  }) async {
    // 1. Decode Excel file
    final Excel excel;
    try {
      excel = Excel.decodeBytes(fileBytes);
    } catch (e) {
      throw ImportFormatException('File không đúng định dạng Excel (.xlsx): $e');
    }

    // 2. Get first sheet
    if (excel.tables.isEmpty) {
      throw const ImportFormatException('File Excel không có sheet nào');
    }
    final sheet = excel.tables[excel.tables.keys.first]!;
    if (sheet.maxRows < ExcelColumnConfig.dataStartRowIndex + 1) {
      throw const ImportFormatException('File Excel không có dữ liệu');
    }

    // 3. Parse header row & build column index map
    final headerRow = sheet.row(ExcelColumnConfig.headerRowIndex);
    final columnMap = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value?.toString().trim();
      if (cellValue != null && cellValue.isNotEmpty) {
        columnMap[cellValue] = i;
      }
    }

    // 4. Validate required columns
    final missingColumns = <String>[];
    for (final col in ExcelColumnConfig.requiredColumns) {
      if (!columnMap.containsKey(col)) {
        missingColumns.add(col);
      }
    }
    if (missingColumns.isNotEmpty) {
      throw ImportFormatException(
        'Thiếu cột bắt buộc: ${missingColumns.join(', ')}',
        missingColumns: missingColumns,
      );
    }

    // 5. Process data rows
    int newCustomers = 0;
    int pointsIncreased = 0;
    int pointsDecreased = 0;
    int unchanged = 0;
    int errors = 0;
    final errorDetails = <ImportError>[];
    int totalRows = 0;

    // Collect batch operations
    final batchOps = <_BatchOperation>[];

    for (int rowIndex = ExcelColumnConfig.dataStartRowIndex; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);

      // Skip empty rows
      if (row.every((cell) => cell?.value == null || cell!.value.toString().trim().isEmpty)) {
        continue;
      }

      totalRows++;

      try {
        // Parse fields from row
        final maKH = _getCellValue(row, columnMap, ExcelColumnConfig.colMaKhachHang);
        final hoTen = _getCellValue(row, columnMap, ExcelColumnConfig.colHoTen);
        final dienThoai = _normalizePhone(_getCellValue(row, columnMap, ExcelColumnConfig.colDienThoai));
        final gioiTinh = _getCellValue(row, columnMap, ExcelColumnConfig.colGioiTinh);
        final ngaySinhStr = _getCellValue(row, columnMap, ExcelColumnConfig.colNgaySinh);
        final diemStr = _getCellValue(row, columnMap, ExcelColumnConfig.colDiemHienTai);

        // Validate required fields
        if ((hoTen == null || hoTen.isEmpty)) {
          errors++;
          errorDetails.add(ImportError(rowNumber: rowIndex + 1, message: 'Thiếu tên khách hàng'));
          continue;
        }

        // Parse points
        final fileDiem = _parsePoints(diemStr);
        if (fileDiem == null) {
          errors++;
          errorDetails.add(ImportError(rowNumber: rowIndex + 1, message: 'Điểm không hợp lệ: "$diemStr"', rawData: hoTen));
          continue;
        }

        // Parse date
        DateTime? ngaySinh;
        if (ngaySinhStr != null && ngaySinhStr.isNotEmpty) {
          ngaySinh = _parseDate(ngaySinhStr);
        }

        // Find existing customer
        final existingCustomer = await _customerService.findByPhoneOrCode(dienThoai, maKH);

        if (existingCustomer != null) {
          // EXISTING customer - compare points
          final oldPoints = existingCustomer.diemHienTai;
          final delta = fileDiem - oldPoints;

          if (delta != 0) {
            // Points changed
            final newPoints = oldPoints + delta;
            batchOps.add(_BatchOperation(
              type: _OpType.updateCustomer,
              customerId: existingCustomer.maKhachHang,
              customerData: {
                'diem_hien_tai': newPoints,
                'ho_ten': hoTen,
                if (dienThoai != null && dienThoai.isNotEmpty) 'so_dien_thoai': dienThoai,
                if (gioiTinh != null && gioiTinh.isNotEmpty) 'gioi_tinh': gioiTinh,
                if (ngaySinh != null) 'ngay_sinh': Timestamp.fromDate(ngaySinh),
                'ho_ten_upper': hoTen.toUpperCase(),
                'ngay_cap_nhat': FieldValue.serverTimestamp(),
              },
              historyData: PointHistory(
                id: '',
                maKhachHang: existingCustomer.maKhachHang,
                ngayTich: DateTime.now(),
                cuaHang: storeId,
                tenCuaHang: storeName,
                diemTruoc: oldPoints,
                diemThayDoi: delta,
                diemSau: newPoints,
              ).toFirestore(),
            ));

            if (delta > 0) {
              pointsIncreased++;
            } else {
              pointsDecreased++;
            }
          } else {
            // Points unchanged - still update info if needed
            batchOps.add(_BatchOperation(
              type: _OpType.updateCustomerInfo,
              customerId: existingCustomer.maKhachHang,
              customerData: {
                'ho_ten': hoTen,
                if (dienThoai != null && dienThoai.isNotEmpty) 'so_dien_thoai': dienThoai,
                if (gioiTinh != null && gioiTinh.isNotEmpty) 'gioi_tinh': gioiTinh,
                if (ngaySinh != null) 'ngay_sinh': Timestamp.fromDate(ngaySinh),
                'ho_ten_upper': hoTen.toUpperCase(),
                'ngay_cap_nhat': FieldValue.serverTimestamp(),
              },
            ));
            unchanged++;
          }
        } else {
          // NEW customer
          final customerId = maKH ?? _generateCustomerId();
          final customer = Customer(
            maKhachHang: customerId,
            hoTen: hoTen,
            ngaySinh: ngaySinh,
            gioiTinh: gioiTinh,
            soDienThoai: dienThoai ?? '',
            diemHienTai: fileDiem,
            ngayTao: DateTime.now(),
          );

          final customerData = customer.toFirestore();
          customerData['ho_ten_upper'] = hoTen.toUpperCase();

          batchOps.add(_BatchOperation(
            type: _OpType.createCustomer,
            customerId: customerId,
            customerData: customerData,
            historyData: PointHistory(
              id: '',
              maKhachHang: customerId,
              ngayTich: DateTime.now(),
              cuaHang: storeId,
              tenCuaHang: storeName,
              diemTruoc: 0,
              diemThayDoi: fileDiem,
              diemSau: fileDiem,
              nguon: 'import_excel',
            ).toFirestore(),
          ));

          newCustomers++;
        }
      } catch (e) {
        errors++;
        errorDetails.add(ImportError(rowNumber: rowIndex + 1, message: 'Lỗi xử lý: $e'));
      }
    }

    // 6. Execute batch writes (max 500 per batch)
    await _executeBatchOps(batchOps);

    return ImportResult(
      totalRows: totalRows,
      newCustomers: newCustomers,
      pointsIncreased: pointsIncreased,
      pointsDecreased: pointsDecreased,
      unchanged: unchanged,
      errors: errors,
      errorDetails: errorDetails,
      storeName: storeName,
      storeId: storeId,
      importedAt: DateTime.now(),
    );
  }

  /// Execute batch operations in groups of 500 (Firestore limit)
  Future<void> _executeBatchOps(List<_BatchOperation> ops) async {
    const batchSize = 450; // Leave margin below 500 limit
    for (int i = 0; i < ops.length; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize > ops.length) ? ops.length : i + batchSize;

      for (int j = i; j < end; j++) {
        final op = ops[j];
        final customerRef = _firestore.collection('kmt_customers').doc(op.customerId);

        switch (op.type) {
          case _OpType.createCustomer:
            batch.set(customerRef, op.customerData);
            if (op.historyData != null) {
              batch.set(_firestore.collection('kmt_point_history').doc(), op.historyData!);
            }
            break;
          case _OpType.updateCustomer:
            batch.update(customerRef, op.customerData);
            if (op.historyData != null) {
              batch.set(_firestore.collection('kmt_point_history').doc(), op.historyData!);
            }
            break;
          case _OpType.updateCustomerInfo:
            batch.update(customerRef, op.customerData);
            break;
        }
      }

      await batch.commit();
    }
  }

  // Helper methods
  String? _getCellValue(List<Data?> row, Map<String, int> columnMap, String columnName) {
    final index = columnMap[columnName];
    if (index == null || index >= row.length) return null;
    final cell = row[index];
    if (cell?.value == null) return null;
    return cell!.value.toString().trim();
  }

  String? _normalizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    // Remove non-digit characters except +
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  int? _parsePoints(String? value) {
    if (value == null || value.isEmpty) return 0;
    // Remove commas and spaces
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    return int.tryParse(cleaned);
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat(ExcelColumnConfig.dateFormat).parse(dateStr);
    } catch (_) {
      // Try other common formats
      for (final fmt in ['yyyy-MM-dd', 'MM/dd/yyyy', 'd/M/yyyy']) {
        try {
          return DateFormat(fmt).parse(dateStr);
        } catch (_) {}
      }
      return null;
    }
  }

  String _generateCustomerId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'KMT${timestamp.toString().substring(5)}';
  }
}

enum _OpType { createCustomer, updateCustomer, updateCustomerInfo }

class _BatchOperation {
  final _OpType type;
  final String customerId;
  final Map<String, dynamic> customerData;
  final Map<String, dynamic>? historyData;

  const _BatchOperation({
    required this.type,
    required this.customerId,
    required this.customerData,
    this.historyData,
  });
}
