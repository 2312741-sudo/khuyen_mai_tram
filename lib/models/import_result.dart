class ImportResult {
  final int totalRows;
  final int newCustomers;
  final int pointsIncreased;
  final int pointsDecreased;
  final int unchanged;
  final int errors;
  final List<ImportError> errorDetails;
  final String storeName;
  final String storeId;
  final DateTime importedAt;

  const ImportResult({
    required this.totalRows,
    required this.newCustomers,
    required this.pointsIncreased,
    required this.pointsDecreased,
    required this.unchanged,
    required this.errors,
    required this.errorDetails,
    required this.storeName,
    required this.storeId,
    required this.importedAt,
  });

  bool get hasErrors => errors > 0;
  bool get isSuccess => errors == 0;
  int get processed => totalRows - errors;
}

class ImportError {
  final int rowNumber;
  final String message;
  final String? rawData;

  const ImportError({
    required this.rowNumber,
    required this.message,
    this.rawData,
  });

  @override
  String toString() => 'Dòng $rowNumber: $message';
}

class ImportFormatException implements Exception {
  final String message;
  final List<String>? missingColumns;

  const ImportFormatException(this.message, {this.missingColumns});

  @override
  String toString() => 'ImportFormatException: $message';
}
