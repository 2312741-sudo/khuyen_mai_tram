import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/store_provider.dart';
import '../../../providers/import_provider.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerCount = ref.watch(customerCountProvider);
    final stores = ref.watch(storeListProvider);
    final importState = ref.watch(importProvider);
    final authUser = ref.watch(authProvider).user;
    final fbUser = FirebaseAuth.instance.currentUser;

    final ownerName = authUser?.name.isNotEmpty == true
        ? authUser!.name
        : (fbUser?.displayName?.isNotEmpty == true
            ? fbUser!.displayName!
            : (fbUser?.email?.isNotEmpty == true
                ? fbUser!.email!.split('@').first
                : 'Chủ quán'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào, $ownerName 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Tổng quan hệ thống Khuyến Mãi Trạm', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_rounded,
                    label: 'Tổng khách hàng',
                    value: customerCount.when(
                      data: (count) => '$count',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.store_rounded,
                    label: 'Cửa hàng',
                    value: stores.when(
                      data: (s) => '${s.length}',
                      loading: () => '...',
                      error: (_, __) => '2',
                    ),
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Hôm nay',
                    value: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Import section
            Text('Import dữ liệu KiotViet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Chọn cửa hàng tương ứng để tải lên file Excel điểm từ KiotViet:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            stores.when(
              loading: () => const ShimmerCard(height: 60),
              error: (e, _) => Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildUploadButton(context, 'tram_chanh', 'Trạm Chanh'),
                  _buildUploadButton(context, 'tram_sua', 'Trạm Sữa'),
                ],
              ),
              data: (storeList) => Wrap(
                spacing: 16,
                runSpacing: 12,
                children: storeList.map((store) => _buildUploadButton(context, store.id, store.name)).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Export section
            Text('Xuất dữ liệu', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Xuất toàn bộ danh sách khách hàng và điểm tích lũy ra file Excel (.xlsx):', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              width: 240,
              child: OutlinedButton.icon(
                onPressed: importState.isExporting
                    ? null
                    : () async {
                        final bytes = await ref.read(importProvider.notifier).exportCustomers();
                        if (bytes != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Đã tải xuống file Excel thành công!'),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (context.mounted) {
                          final err = ref.read(importProvider).error;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi xuất file: $err'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                icon: importState.isExporting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Icon(Icons.download_rounded),
                label: Text(importState.isExporting ? 'Đang tạo file...' : 'Xuất file Excel (.xlsx)'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(240, 52)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, String storeId, String storeName) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/owner/import/$storeId'),
        icon: const Icon(Icons.upload_file_rounded),
        label: Text('Upload $storeName'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(220, 52)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
