import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';
import '../app_theme.dart';

/// بطاقة "الأطفال الذين يحتاجون متابعة" — تعرض فقط 3 معايير:
/// كثيرو الغياب، بلا صور، لم يشاركوا في نشاط.
/// (لا تعرض "غير المقيَّمين" لأن نظام التقييم غير موجود حاليًا.)
class FollowUpCard extends StatelessWidget {
  final List<FollowUpChild> children;

  const FollowUpCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppTheme.alertUrgent, size: 20),
              SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  'أطفال يحتاجون متابعة',
                  style: AppTheme.headingMedium,
                ),
              ),
              if (children.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.alertUrgent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    '${children.length}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.alertUrgent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spaceSm),
          if (children.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              child: Text(
                'لا يوجد حاليًا أي طفل يحتاج متابعة خاصة 🌟',
                style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary),
              ),
            )
          else
            ...children.take(6).map(
                  (child) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.alertUrgent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppTheme.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${child.fullName} — ${child.section}',
                                style: AppTheme.bodyText.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                child.reason,
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (children.length > 6)
            Padding(
              padding: EdgeInsets.only(top: AppTheme.spaceXs),
              child: Text(
                'و ${children.length - 6} طفلاً آخر...',
                style: AppTheme.caption,
              ),
            ),
        ],
      ),
    );
  }
}
