import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/widgets/point_history_tile.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/point_history_provider.dart';
import '../../../models/customer.dart';

class OwnerCustomerDetailScreen extends ConsumerWidget {
  final String customerId;
  const OwnerCustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final historyAsync = ref.watch(customerHistoryProvider(customerId));
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: customerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (customer) {
          if (customer == null) return const Center(child: Text('Không tìm thấy'));
          if (isWide) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: _buildInfoPanel(context, customer)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildHistoryPanel(context, historyAsync)),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoPanel(context, customer),
                const SizedBox(height: 16),
                _buildHistoryPanel(context, historyAsync),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, Customer customer) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Thông tin khách hàng', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppColors.successGradient, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text('${customer.diemHienTai}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.white)),
                const Text('điểm hiện tại', style: TextStyle(color: AppColors.white, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Mã KH', value: customer.maKhachHang),
          _DetailRow(label: 'Họ tên', value: customer.hoTen),
          _DetailRow(label: 'SĐT', value: customer.soDienThoai.isEmpty ? 'Chưa có' : customer.soDienThoai),
          if (customer.gioiTinh != null) _DetailRow(label: 'Giới tính', value: customer.gioiTinh!),
          if (customer.ngaySinh != null) _DetailRow(label: 'Ngày sinh', value: dateFormat.format(customer.ngaySinh!)),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(BuildContext context, AsyncValue<List<dynamic>> historyAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lịch sử tích điểm', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          historyAsync.when(
            loading: () => const ShimmerListCard(itemCount: 3),
            error: (e, _) => Text('Lỗi: $e'),
            data: (history) {
              if (history.isEmpty) return EmptyState.pointHistory();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (_, i) => PointHistoryTile(history: history[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
