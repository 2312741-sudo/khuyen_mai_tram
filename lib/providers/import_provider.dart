import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/import_result.dart';
import '../services/excel_import_service.dart';
import '../services/excel_export_service.dart';

final excelImportServiceProvider = Provider<ExcelImportService>((ref) => ExcelImportService());
final excelExportServiceProvider = Provider<ExcelExportService>((ref) => ExcelExportService());

class ImportState {
  final bool isImporting;
  final bool isExporting;
  final ImportResult? result;
  final String? error;

  const ImportState({this.isImporting = false, this.isExporting = false, this.result, this.error});
}

class ImportNotifier extends StateNotifier<ImportState> {
  final ExcelImportService _importService;
  final ExcelExportService _exportService;

  ImportNotifier(this._importService, this._exportService) : super(const ImportState());

  Future<ImportResult?> importFile({
    required Uint8List fileBytes,
    required String storeId,
    required String storeName,
  }) async {
    state = const ImportState(isImporting: true);
    try {
      final result = await _importService.importExcel(
        fileBytes: fileBytes,
        storeId: storeId,
        storeName: storeName,
      );
      state = ImportState(result: result);
      return result;
    } on ImportFormatException catch (e) {
      state = ImportState(error: e.message);
      return null;
    } catch (e) {
      state = ImportState(error: 'Lỗi import: $e');
      return null;
    }
  }

  Future<Uint8List?> exportCustomers() async {
    state = const ImportState(isExporting: true);
    try {
      final bytes = await _exportService.exportCustomers();
      state = const ImportState();
      return bytes;
    } catch (e) {
      state = ImportState(error: 'Lỗi xuất file: $e');
      return null;
    }
  }

  void clearState() {
    state = const ImportState();
  }
}

final importProvider = StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  return ImportNotifier(
    ref.read(excelImportServiceProvider),
    ref.read(excelExportServiceProvider),
  );
});
