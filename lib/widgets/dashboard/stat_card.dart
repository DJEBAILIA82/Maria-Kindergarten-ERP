import 'package:flutter/material.dart';

import '../app_theme.dart';

/// بطاقة إحصائية واحدة، قابلة لإعادة الاستخدام في أي صفحة.
/// لا تفترض أي ارتفاع أو عرض ثابت — تأخذ بالضبط المساحة التي تحتاجها.
class StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, fade, child) {
        return Opacity(
          opacity: fade,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.92, end: 1.0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.spaceMd,
          horizontal: AppTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.12),
          ),
          boxShadow: AppTheme.shadowSoft,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spaceSm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: AppTheme.spaceSm),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return Text(
                    animatedValue.toString(),
                    style: AppTheme.statNumber.copyWith(color: color),
                  );
                },
              ),
            ),
            SizedBox(height: AppTheme.spaceXs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.statLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      ),
    );
  }
}