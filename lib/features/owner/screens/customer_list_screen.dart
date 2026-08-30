import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../providers/customer_provider.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});
  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(customerListProvider.notifier).loadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(customerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Khách hàng', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: () => ref.read(customerListProvider.notifier).loadCustomers(refresh: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search
            SizedBox(
              width: 400,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm khách hàng theo tên, SĐT...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Table / Error / Empty
            Expanded(
              child: listState.isLoading && listState.customers.isEmpty
                  ? const ShimmerListCard()
                  : listState.error != null && listState.customers.isEmpty
                      ? _buildPermissionOrErrorState(listState.error!)
                      : listState.customers.isEmpty
                          ? EmptyState.customers(
                              onImport: () => context.go('/owner/import/tram_chanh'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(AppColors.surface),
                                    columns: const [
                                      DataColumn(label: Text('Mã KH', style: TextStyle(fontWeight: FontWeight.w700))),
                                      DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.w700))),
                                      DataColumn(label: Text('SĐT', style: TextStyle(fontWeight: FontWeight.w700))),
                                      DataColumn(label: Text('Điểm', style: TextStyle(fontWeight: FontWeight.w700)), numeric: true),
                                      DataColumn(label: Text('Giới tính', style: TextStyle(fontWeight: FontWeight.w700))),
                                    ],
                                    rows: listState.customers.map((c) => DataRow(
                                      onSelectChanged: (_) => context.go('/owner/customer/${c.maKhachHang}'),
                                      cells: [
                                        DataCell(Text(c.maKhachHang)),
                                        DataCell(Text(c.hoTen, style: const TextStyle(fontWeight: FontWeight.w500))),
                                        DataCell(Text(c.soDienThoai)),
                                        DataCell(Text('${c.diemHienTai}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success))),
                                        DataCell(Text(c.gioiTinh ?? '')),
                                      ],
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionOrErrorState(String error) {
    final isPermissionError = error.contains('permission-denied');
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPermissionError ? AppColors.accent : AppColors.danger),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPermissionError ? Icons.lock_clock_rounded : Icons.error_outline_rounded,
              size: 48,
              color: isPermissionError ? AppColors.accent : AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              isPermissionError ? 'Cần cập nhật Firestore Security Rules' : 'Có lỗi xảy ra',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPermissionError
                  ? 'Firebase Project của bạn cần thêm quyền đọc/ghi cho các collection Khuyến Mãi (kmt_customers, kmt_point_history, kmt_stores).'
                  : error,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(customerListProvider.notifier).loadCustomers(refresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
