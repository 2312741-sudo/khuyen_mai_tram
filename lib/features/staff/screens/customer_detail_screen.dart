import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/widgets/point_history_tile.dart';
import '../../../models/customer.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/point_history_provider.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final historyAsync = ref.watch(customerHistoryProvider(customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin khách hàng')),
      body: customerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (customer) {
          if (customer == null) return const Center(child: Text('Không tìm thấy khách hàng'));
          return CustomScrollView(
            slivers: [
              // Customer info header
              SliverToBoxAdapter(child: _buildCustomerHeader(context, customer)),
              // History header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Lịch sử tích điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              // History list
              historyAsync.when(
                loading: () => const SliverToBoxAdapter(child: ShimmerListCard(itemCount: 3)),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Lỗi: $e'))),
                data: (history) {
                  if (history.isEmpty) {
                    return SliverToBoxAdapter(child: EmptyState.pointHistory());
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => PointHistoryTile(history: history[index]),
                      childCount: history.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerHeader(BuildContext context, Customer customer) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Points display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.white, size: 28),
                const SizedBox(width: 8),
                Text('${customer.diemHienTai}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.white)),
                const SizedBox(width: 8),
                const Text('điểm', style: TextStyle(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info rows
          _InfoRow(icon: Icons.person_outlined, label: 'Họ tên', value: customer.hoTen),
          _InfoRow(icon: Icons.phone_outlined, label: 'SĐT', value: customer.soDienThoai.isEmpty ? 'Chưa có' : customer.soDienThoai),
          _InfoRow(icon: Icons.badge_outlined, label: 'Mã KH', value: customer.maKhachHang),
          if (customer.ngaySinh != null)
            _InfoRow(icon: Icons.cake_outlined, label: 'Ngày sinh', value: dateFormat.format(customer.ngaySinh!)),
          if (customer.gioiTinh != null && customer.gioiTinh!.isNotEmpty)
            _InfoRow(icon: Icons.wc_outlined, label: 'Giới tính', value: customer.gioiTinh!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
