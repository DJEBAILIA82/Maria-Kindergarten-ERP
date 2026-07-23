import 'package:flutter/material.dart';

import '../app_theme.dart';

/// شبكة عرض متجاوبة تعتمد على [Wrap]، بحيث كل عنصر له عرض محسوب
/// من المساحة المتاحة، لكن ارتفاعه حر تمامًا حسب محتواه الفعلي.
/// هذا يمنع أي Overflow بنيويًا، بدل الاعتماد على نسبة ارتفاع ثابتة.
class DashboardGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int wideColumns;
  final double wideBreakpoint;

  const DashboardGrid({
    super.key,
    required this.children,
    required this.mobileColumns,
    required this.wideColumns,
    this.wideBreakpoint = 600,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= wideBreakpoint;
        final columns = isWideScreen ? wideColumns : mobileColumns;

        final totalSpacing = AppTheme.spaceMd * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: AppTheme.spaceMd,
          runSpacing: AppTheme.spaceMd,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}