import 'package:flutter/material.dart';

import '../app_theme.dart';

/// عنوان قسم موحّد، يُستعمل فوق أي مجموعة عناصر في أي صفحة
/// (مثلاً: "الإحصائيات"، "العمليات السريعة").
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTheme.headingMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppTheme.spaceMd),
        const Expanded(
          child: Divider(
            color: AppTheme.textSecondary,
            thickness: 0.6,
          ),
        ),
      ],
    );
  }
}