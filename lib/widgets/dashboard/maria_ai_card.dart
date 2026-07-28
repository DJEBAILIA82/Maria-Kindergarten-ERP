import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';
import '../app_theme.dart';

/// بطاقة "Maria" — ملخص إداري ذكي مبني بالكامل من [DashboardData]
/// المُحسوبة في DashboardService. لا تحتوي هذه البطاقة على أي منطق
/// استعلام أو حساب بنفسها؛ فقط تعرض ما وصلها.
class MariaAiCard extends StatelessWidget {
  final DashboardData data;

  const MariaAiCard({super.key, required this.data});

  Widget _insightRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textOnPrimary.withValues(alpha: 0.9)),
          SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insights = <Widget>[
      _insightRow(
        Icons.photo_library_rounded,
        'الصور المعلقة: ${data.pendingPhotosCount}',
      ),
      _insightRow(
        Icons.account_balance_wallet_rounded,
        'الاشتراكات المتأخرة: ${data.lateSubscriptionsCount}',
      ),
      _insightRow(
        Icons.favorite_rounded,
        'أطفال يحتاجون متابعة: ${data.childrenNeedingFollowUp.length}',
      ),
      if (data.mostActiveSection != null)
        _insightRow(
          Icons.trending_up_rounded,
          'أكثر قسم نشاطًا: ${data.mostActiveSection} (${data.mostActiveSectionCount})',
        ),
      if (data.leastActiveSection != null)
        _insightRow(
          Icons.trending_down_rounded,
          'أقل قسم نشاطًا: ${data.leastActiveSection} (${data.leastActiveSectionCount})',
        ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryPurple, AppTheme.darkPurple],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowLifted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.goldAccent.withValues(alpha: 0.22),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.goldAccent,
                ),
              ),
              SizedBox(width: AppTheme.spaceSm),
              Text(
                'Maria — ملخصك الذكي لليوم',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textOnPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spaceSm),
          ...insights,
          SizedBox(height: AppTheme.spaceSm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.goldAccent.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.goldAccent,
                  size: 20,
                ),
                SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    data.topSuggestion,
                    style: AppTheme.bodyText.copyWith(
                      color: AppTheme.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
