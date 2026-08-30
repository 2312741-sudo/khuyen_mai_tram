import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});
  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  List<AppUser> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user?.currentStoreId != null) {
        final authService = ref.read(authServiceProvider);
        _staff = await authService.getStaffMembers(user!.currentStoreId!);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Nhân viên', style: Theme.of(context).textTheme.headlineMedium),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadStaff),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _staff.isEmpty
                      ? const EmptyState(icon: Icons.group_outlined, message: 'Chưa có nhân viên nào', subtitle: 'Nhân viên sử dụng tài khoản Chấm Công Trạm để đăng nhập')
                      : ListView.builder(
                          itemCount: _staff.length,
                          itemBuilder: (_, index) {
                            final member = _staff[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.info.withOpacity(0.1),
                                  child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700)),
                                ),
                                title: Text(member.name),
                                subtitle: Text(member.role.label),
                                trailing: const Chip(label: Text('Active'), backgroundColor: Color(0xFFE8F5E9)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
