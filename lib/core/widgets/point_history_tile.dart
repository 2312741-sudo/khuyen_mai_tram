import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../../models/point_history.dart';

class PointHistoryTile extends StatelessWidget {
  final PointHistory history;
  const PointHistoryTile({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final isIncrease = history.diemThayDoi > 0;
    final color = isIncrease ? AppColors.pointIncrease : (history.diemThayDoi < 0 ? AppColors.pointDecrease : AppColors.pointNeutral);
    final icon = isIncrease ? Icons.arrow_upward_rounded : (history.diemThayDoi < 0 ? Icons.arrow_downward_rounded : Icons.remove_rounded);
    final prefix = isIncrease ? '+' : '';
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(history.ngayTich);
    final storeName = history.tenCuaHang ?? history.cuaHang;

    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text('$prefix${history.diemThayDoi} điểm', style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      subtitle: Text('$storeName · $dateStr', style: const TextStyle(fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Điểm sau', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text('${history.diemSau}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
