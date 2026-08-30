import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../models/customer.dart';
import '../services/customer_service.dart';

class ExcelExportService {
  final CustomerService _customerService = CustomerService();

  /// Export all customers to Excel bytes and trigger web download
  Future<Uint8List> exportCustomers({String? storeFilter}) async {
    // Fetch all customers from Firestore
    final customers = <Customer>[];
    DocumentSnapshot? lastDoc;
    
    try {
      while (true) {
        final batch = await _customerService.getAllCustomers(
          limit: 500,
          startAfter: lastDoc,
          orderBy: 'ho_ten',
        );
        if (batch.isEmpty) break;
        customers.addAll(batch);
        if (batch.length < 500) break;
      }
    } catch (e) {
      debugPrint('Export fetch error: $e');
      rethrow;
    }

    // Create Excel workbook
    final excel = Excel.createExcel();
    const sheetName = 'Khách hàng';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final sheet = excel[sheetName];

    // Header row
    final headers = [
      'Mã khách hàng',
      'Tên khách hàng',
      'Số điện thoại',
      'Giới tính',
      'Ngày sinh',
      'Điểm hiện tại',
      'Ngày cập nhật',
    ];

    // Style for header
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#CB2D2E'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (int r = 0; r < customers.length; r++) {
      final c = customers[r];
      final rowIndex = r + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue(c.maKhachHang);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(c.hoTen);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(c.soDienThoai);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(c.gioiTinh ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = TextCellValue(c.ngaySinh != null ? dateFormat.format(c.ngaySinh!) : '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = IntCellValue(c.diemHienTai);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = TextCellValue(c.ngayCapNhat != null ? dateTimeFormat.format(c.ngayCapNhat!) : '');
    }

    // Set column widths
    sheet.setColumnWidth(0, 18); // Mã KH
    sheet.setColumnWidth(1, 25); // Tên
    sheet.setColumnWidth(2, 15); // SĐT
    sheet.setColumnWidth(3, 10); // Giới tính
    sheet.setColumnWidth(4, 14); // Ngày sinh
    sheet.setColumnWidth(5, 14); // Điểm
    sheet.setColumnWidth(6, 20); // Ngày cập nhật

    // Encode to bytes
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Không thể tạo file Excel');
    final uint8list = Uint8List.fromList(bytes);

    // Trigger browser download on Web
    if (kIsWeb) {
      final fileName = 'Danh_sach_khach_hang_Tram_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.xlsx';
      final blob = html.Blob([uint8list], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }

    return uint8list;
  }
}
