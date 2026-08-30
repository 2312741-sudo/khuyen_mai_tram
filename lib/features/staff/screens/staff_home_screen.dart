import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/widgets/customer_info_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';

class StaffHomeScreen extends ConsumerStatefulWidget {
  const StaffHomeScreen({super.key});
  @override
  ConsumerState<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends ConsumerState<StaffHomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(customerSearchProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(customerSearchProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khuyến Mãi Trạm'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: Text(user.name, style: const TextStyle(fontSize: 13))),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo số điện thoại hoặc mã KH...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerSearchProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Results
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(CustomerSearchState searchState) {
    if (searchState.isLoading) {
      return const ShimmerListCard(itemCount: 3);
    }
    if (searchState.error != null) {
      return Center(child: Text(searchState.error!, style: const TextStyle(color: AppColors.danger)));
    }
    if (!searchState.hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: AppColors.textDisabled.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Nhập số điện thoại hoặc mã KH\nđể tra cứu thông tin khách hàng',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (searchState.results.isEmpty) {
      return EmptyState.search();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final customer = searchState.results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomerInfoCard(
            customer: customer,
            onTap: () => context.push('/staff/customer/${customer.maKhachHang}'),
          ),
        );
      },
    );
  }
}
