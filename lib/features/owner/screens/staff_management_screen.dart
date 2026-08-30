import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});
  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  List<StaffWithStore> _staffList = [];
  Map<String, String> _stores = {'all': 'Tất cả các Trạm'};
  String _selectedStore = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoresAndStaff();
  }

  Future<void> _loadStoresAndStaff() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final availableStores = await authService.getAvailableStores();
      
      setState(() {
        _stores = {'all': 'Tất cả các Trạm', ...availableStores};
      });

      final staff = await authService.getAllStaffMembers(
        storeIdFilter: _selectedStore == 'all' ? null : _selectedStore,
      );

      if (mounted) {
        setState(() {
          _staffList = staff;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải nhân viên: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _onStoreSelected(String storeId) async {
    setState(() {
      _selectedStore = storeId;
      _isLoading = true;
    });
    final authService = ref.read(authServiceProvider);
    final staff = await authService.getAllStaffMembers(
      storeIdFilter: storeId == 'all' ? null : storeId,
    );
    if (mounted) {
      setState(() {
        _staffList = staff;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staffList.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final inStores = item.storeNames.any((s) => s.toLowerCase().contains(q));
      return item.user.name.toLowerCase().contains(q) ||
          (item.user.phone?.contains(q) ?? false) ||
          inStores;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Danh sách nhân viên', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Tự động gộp nhân sự giữa Trạm Chanh và Trạm Sữa', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                  onPressed: _loadStoresAndStaff,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Store Filter Chips & Search Box
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _stores.entries.map((entry) {
                        final isSelected = _selectedStore == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            onSelected: (_) => _onStoreSelected(entry.key),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 280,
                  height: 44,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Tìm nhân viên...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Staff List with Deduplication
            Expanded(
              child: _isLoading
                  ? const ShimmerListCard()
                  : filteredStaff.isEmpty
                      ? const EmptyState(
                          icon: Icons.group_outlined,
                          message: 'Không tìm thấy nhân viên nào',
                          subtitle: 'Nhân viên sử dụng tài khoản Chấm Công Trạm để đăng nhập vào app',
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredStaff.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (_, index) {
                              final item = filteredStaff[index];
                              final isManager = item.cctRole.contains('manager');

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isManager
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : AppColors.info.withValues(alpha: 0.12),
                                  child: Text(
                                    item.user.name.isNotEmpty ? item.user.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: isManager ? AppColors.primary : AppColors.info,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.user.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                subtitle: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    // Store tags (Combined if working at both stores)
                                    ...item.storeNames.map((storeName) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: storeName.toLowerCase().contains('chanh')
                                            ? AppColors.accent.withValues(alpha: 0.15)
                                            : AppColors.info.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: storeName.toLowerCase().contains('chanh')
                                              ? AppColors.accent
                                              : AppColors.info,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        storeName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: storeName.toLowerCase().contains('chanh')
                                              ? const Color(0xFFB8860B)
                                              : AppColors.info,
                                        ),
                                      ),
                                    )),
                                    const SizedBox(width: 4),
                                    Text(
                                      isManager ? 'Quản lý' : 'Nhân viên',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (item.user.phone != null && item.user.phone!.isNotEmpty)
                                      Text('• ${item.user.phone}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Hoạt động',
                                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
