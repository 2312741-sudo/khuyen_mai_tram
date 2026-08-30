import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/import_summary_dialog.dart';
import '../../../providers/import_provider.dart';
import '../../../providers/store_provider.dart';

class ImportExcelScreen extends ConsumerStatefulWidget {
  final String storeId;
  const ImportExcelScreen({super.key, required this.storeId});
  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _handleImport() async {
    if (_selectedFile?.bytes == null) return;

    final stores = ref.read(storeListProvider).valueOrNull ?? [];
    final store = stores.firstWhere((s) => s.id == widget.storeId, orElse: () => stores.first);

    final result = await ref.read(importProvider.notifier).importFile(
      fileBytes: _selectedFile!.bytes!,
      storeId: widget.storeId,
      storeName: store.name,
    );

    if (result != null && mounted) {
      await ImportSummaryDialog.show(context, result);
      setState(() => _selectedFile = null);
    } else if (mounted) {
      final error = ref.read(importProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importProvider);
    final stores = ref.watch(storeListProvider);
    final storeName = stores.whenOrNull(data: (s) => s.firstWhere((st) => st.id == widget.storeId, orElse: () => s.first).name) ?? widget.storeId;

    return LoadingOverlay(
      isLoading: importState.isImporting,
      message: 'Đang import dữ liệu...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Import dữ liệu', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Cửa hàng: $storeName', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              // Drop zone
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null ? Icons.description_rounded : Icons.upload_file_rounded,
                        size: 56,
                        color: _selectedFile != null ? AppColors.success : AppColors.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFile != null ? _selectedFile!.name : 'Chọn file Excel (.xlsx)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedFile != null ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _pickFile, child: const Text('Chọn file khác')),
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text('Hoặc kéo thả file vào đây', style: TextStyle(fontSize: 13, color: AppColors.textDisabled)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Import button
              SizedBox(
                width: 280,
                child: ElevatedButton.icon(
                  onPressed: _selectedFile != null && !importState.isImporting ? _handleImport : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Bắt đầu Import'),
                ),
              ),
              if (importState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(importState.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
