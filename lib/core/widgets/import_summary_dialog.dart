import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/import_result.dart';

class ImportSummaryDialog extends StatelessWidget {
  final ImportResult result;
  const ImportSummaryDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, ImportResult result) {
    return showDialog(context: context, builder: (_) => ImportSummaryDialog(result: result));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.hasErrors ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: result.hasErrors ? AppColors.accent : AppColors.success,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(result.hasErrors ? 'Import có cảnh báo' : 'Import thành công'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cửa hàng: ${result.storeName}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            _StatRow(icon: Icons.description_outlined, label: 'Tổng dòng', value: '${result.totalRows}', color: AppColors.info),
            _StatRow(icon: Icons.person_add_rounded, label: 'Khách mới', value: '${result.newCustomers}', color: AppColors.info),
            _StatRow(icon: Icons.arrow_upward_rounded, label: 'Cộng điểm', value: '${result.pointsIncreased}', color: AppColors.success),
            _StatRow(icon: Icons.arrow_downward_rounded, label: 'Trừ điểm', value: '${result.pointsDecreased}', color: AppColors.primary),
            _StatRow(icon: Icons.remove_rounded, label: 'Không đổi', value: '${result.unchanged}', color: AppColors.pointNeutral),
            if (result.errors > 0) ...[
              _StatRow(icon: Icons.error_outline_rounded, label: 'Lỗi', value: '${result.errors}', color: AppColors.danger),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Chi tiết lỗi:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...result.errorDetails.take(10).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('\u2022 ${e.toString()}', style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              )),
              if (result.errorDetails.length > 10)
                Text('... và ${result.errorDetails.length - 10} lỗi khác', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Xong')),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
