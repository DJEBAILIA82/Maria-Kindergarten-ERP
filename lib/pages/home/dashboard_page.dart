import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/dashboard/dashboard_charts.dart';
import '../../widgets/dashboard/dashboard_grid.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/follow_up_card.dart';
import '../../widgets/dashboard/maria_ai_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/dashboard/section_title.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../attendance_page.dart';
import '../children_page.dart';
import '../messages_page.dart';
import '../settings_page.dart';
import '../subscriptions_page.dart';

/// لوحة القيادة الاحترافية للمديرة (ولوحة مبسّطة للمعلمة).
///
/// كل تجميع البيانات والحسابات يتم في [DashboardService]؛ هذا الملف
/// مسؤول فقط عن العرض (لا يوجد أي استعلام SQLite هنا، تماشيًا مع
/// القاعدة المعمارية للمشروع).
class DashboardPage extends StatefulWidget {
  final AppUser user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();

  DashboardData? _data;
  bool _isLoading = true;

  bool get _isDirector => widget.user.isDirector;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _dashboardService.loadDashboardData(widget.user);

      if (!mounted) return;

      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    _loadData();
  }

  List<Widget> _buildKindergartenStats(DashboardData data) {
    return [
      StatCard(
        icon: Icons.child_care_rounded,
        value: data.totalChildren,
        label: 'إجمالي الأطفال',
        color: AppTheme.statTotal,
      ),
      if (_isDirector) ...[
        StatCard(
          icon: Icons.badge_rounded,
          value: data.totalStaff,
          label: 'الموظفون',
          color: AppTheme.primaryPurple,
        ),
        StatCard(
          icon: Icons.grid_view_rounded,
          value: data.totalSections,
          label: 'الأقسام',
          color: AppTheme.secondaryTurquoise,
        ),
      ],
    ];
  }

  List<Widget> _buildTodayStats(DashboardData data) {
    return [
      StatCard(
        icon: Icons.check_circle_rounded,
        value: data.presentToday,
        label: 'الحاضرون اليوم',
        color: AppTheme.attendanceBlue,
      ),
      StatCard(
        icon: Icons.cancel_rounded,
        value: data.absentToday,
        label: 'الغائبون اليوم',
        color: AppTheme.attendanceBlue,
      ),
    ];
  }

  List<Widget> _buildFinanceStats(DashboardData data) {
    return [
      StatCard(
        icon: Icons.trending_up_rounded,
        value: data.revenueThisMonth.round(),
        label: 'الإيرادات هذا الشهر',
        color: AppTheme.financeRevenue,
      ),
      StatCard(
        icon: Icons.trending_down_rounded,
        value: data.expensesThisMonth.round(),
        label: 'المصروفات هذا الشهر',
        color: AppTheme.financeExpense,
      ),
      StatCard(
        icon: Icons.savings_rounded,
        value: data.profitThisMonth.round(),
        label: 'الأرباح هذا الشهر',
        color: AppTheme.financeProfit,
      ),
    ];
  }

  List<Widget> _buildAlertStats(DashboardData data) {
    return [
      StatCard(
        icon: Icons.photo_library_rounded,
        value: data.pendingPhotosCount,
        label: 'صور بانتظار المراجعة',
        color: AppTheme.alertPending,
      ),
      StatCard(
        icon: Icons.warning_amber_rounded,
        value: data.lateSubscriptionsCount,
        label: 'اشتراكات متأخرة',
        color: AppTheme.alertUrgent,
      ),
    ];
  }

  List<Widget> _buildQuickActions() {
    return [
      QuickActionCard(
        icon: Icons.person_add_alt_1_rounded,
        label: 'إضافة طفل',
        color: AppTheme.primaryPurple,
        onTap: () => _openPage(ChildrenPage(user: widget.user)),
      ),
      QuickActionCard(
        icon: Icons.fact_check_rounded,
        label: 'تسجيل الحضور',
        color: AppTheme.attendanceBlue,
        onTap: () => _openPage(AttendancePage(user: widget.user)),
      ),
      QuickActionCard(
        icon: Icons.payments_rounded,
        label: 'تسجيل دفعة',
        color: AppTheme.goldAccent,
        onTap: () => _openPage(const SubscriptionsPage()),
      ),
      QuickActionCard(
        icon: Icons.send_rounded,
        label: 'إرسال رسالة',
        color: AppTheme.secondaryTurquoise,
        onTap: () => _openPage(const MessagesPage()),
      ),
      QuickActionCard(
        icon: Icons.bar_chart_rounded,
        label: 'التقارير',
        color: AppTheme.financeExpense,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('افتح التقارير من القائمة الجانبية'),
            ),
          );
        },
      ),
      QuickActionCard(
        icon: Icons.settings_rounded,
        label: 'الإعدادات',
        color: AppTheme.textSecondary,
        onTap: () => _openPage(const SettingsPage()),
      ),
    ];
  }

  Widget _groupCard({required String title, required List<Widget> cards}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spaceLg),
      margin: EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          SizedBox(height: AppTheme.spaceMd),
          DashboardGrid(
            mobileColumns: 2,
            wideColumns: 4,
            children: cards,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Container(
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: _isLoading || data == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spaceLg,
                    AppTheme.spaceLg,
                    AppTheme.spaceLg,
                    AppTheme.spaceXl,
                  ),
                  children: [
                    DashboardHeader(user: widget.user),
                    SizedBox(height: AppTheme.spaceLg),

                    if (_isDirector) ...[
                      MariaAiCard(data: data),
                      SizedBox(height: AppTheme.spaceLg),
                    ],

                    _groupCard(
                      title: 'إحصائيات الروضة',
                      cards: _buildKindergartenStats(data),
                    ),
                    _groupCard(
                      title: 'إحصائيات اليوم',
                      cards: _buildTodayStats(data),
                    ),
                    if (_isDirector) ...[
                      _groupCard(
                        title: 'المالية',
                        cards: _buildFinanceStats(data),
                      ),
                      _groupCard(
                        title: 'التنبيهات المهمة',
                        cards: _buildAlertStats(data),
                      ),
                      SizedBox(height: AppTheme.spaceXs),
                      FollowUpCard(children: data.childrenNeedingFollowUp),
                      SizedBox(height: AppTheme.spaceLg),
                      DashboardCharts(data: data),
                    ],

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppTheme.spaceLg),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: 'العمليات السريعة'),
                          SizedBox(height: AppTheme.spaceMd),
                          DashboardGrid(
                            mobileColumns: 3,
                            wideColumns: 4,
                            children: _buildQuickActions(),
                          ),
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
