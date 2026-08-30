import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../app/router.dart';

class OwnerShell extends ConsumerWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final fbUser = FirebaseAuth.instance.currentUser;
    final user = authState.user;

    final displayName = (user != null && user.name.isNotEmpty)
        ? user.name
        : (fbUser?.displayName?.isNotEmpty == true
            ? fbUser!.displayName!
            : (fbUser?.email?.isNotEmpty == true
                ? fbUser!.email!.split('@').first
                : 'Chủ quán'));

    final displayEmail = (user != null && user.email.isNotEmpty)
        ? user.email
        : (fbUser?.email ?? '');

    final currentPath = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.of(context).size.width > 800;

    final navItems = const [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: AppRoutes.ownerDashboard),
      _NavItem(icon: Icons.people_rounded, label: 'Khách hàng', path: AppRoutes.ownerCustomers),
      _NavItem(icon: Icons.group_rounded, label: 'Nhân viên', path: AppRoutes.ownerStaff),
      _NavItem(icon: Icons.history_rounded, label: 'Lịch sử', path: AppRoutes.ownerHistory),
    ];

    Future<void> handleSignOut() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      }
    }

    Widget sidebar = Container(
      width: 260,
      color: AppColors.neutral,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: AppColors.primary,
                      child: const Icon(Icons.card_giftcard_rounded, color: AppColors.white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khuyến Mãi Trạm',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        'Quản trị hệ thống',
                        style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF333333), height: 1),
          const SizedBox(height: 8),

          // Navigation items
          ...navItems.map((item) {
            final isActive = currentPath == item.path;
            return ListTile(
              leading: Icon(item.icon, color: isActive ? AppColors.primary : AppColors.textDisabled, size: 22),
              title: Text(
                item.label,
                style: TextStyle(
                  color: isActive ? AppColors.white : AppColors.textDisabled,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              selected: isActive,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              onTap: () => context.go(item.path),
            );
          }),

          const Spacer(),

          // User info and Logout Box (ALWAYS VISIBLE)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
              border: Border(top: BorderSide(color: Color(0xFF333333))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                        style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (displayEmail.isNotEmpty)
                            Text(
                              displayEmail,
                              style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: handleSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white70),
                  label: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF555555)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khuyến Mãi Trạm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: handleSignOut,
          ),
        ],
      ),
      drawer: Drawer(child: sidebar),
      body: child,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
