import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/customer.dart';

class CustomerInfoCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const CustomerInfoCard({super.key, required this.customer, this.onTap, this.showFullDetails = false});

  String get _initials {
    final parts = customer.hoTen.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(_initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.hoTen, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    if (customer.soDienThoai.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(customer.soDienThoai, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    if (showFullDetails) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(customer.maKhachHang, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${customer.diemHienTai}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success),
                    ),
                    const Text('điểm', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
