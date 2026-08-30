import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({super.key, this.height = 80, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECE8E2),
      highlightColor: const Color(0xFFF8F4EE),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: borderRadius ?? BorderRadius.circular(16)),
      ),
    );
  }
}

class ShimmerListCard extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const ShimmerListCard({super.key, this.itemCount = 5, this.itemHeight = 80, this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}
