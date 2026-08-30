import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.message, this.subtitle, this.actionLabel, this.onAction});

  factory EmptyState.search() => const EmptyState(icon: Icons.search_off_rounded, message: 'Không tìm thấy kết quả', subtitle: 'Thử tìm kiếm với từ khóa khác');

  factory EmptyState.customers({VoidCallback? onImport}) => EmptyState(
    icon: Icons.people_outline_rounded, message: 'Chưa có khách hàng nào',
    subtitle: 'Import file Excel từ KiotViet để thêm khách hàng',
    actionLabel: onImport != null ? 'Import Excel' : null, onAction: onImport,
  );

  factory EmptyState.pointHistory() => const EmptyState(icon: Icons.history_rounded, message: 'Chưa có lịch sử tích điểm', subtitle: 'Lịch sử sẽ được tạo khi import dữ liệu');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: AppColors.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
            if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center)],
            if (actionLabel != null && onAction != null) ...[const SizedBox(height: 24), ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)), child: Text(actionLabel!))],
          ],
        ),
      ),
    );
  }
}
