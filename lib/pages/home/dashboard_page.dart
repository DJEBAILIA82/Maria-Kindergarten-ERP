import 'package:flutter/material.dart';

import '../../attendance_service.dart';
import '../../child_service.dart';
import '../../models/user.dart';
import '../../subscription_service.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/dashboard/dashboard_grid.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/quick_action_card.dart';
import '../../widgets/dashboard/section_title.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../attendance_page.dart';
import '../children_page.dart';
import '../messages_page.dart';
import '../settings_page.dart';
import '../subscriptions_page.dart';

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
  final ChildService _childService = ChildService();
  final AttendanceService _attendanceService = AttendanceService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  int _totalChildren = 0;
  int _presentChildren = 0;
  int _absentChildren = 0;
  int _lateSubscriptions = 0;

  bool _isLoading = true;

  bool get _isDirector => widget.user.isDirector;

  String get _todayText {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String get _currentMonth {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');

    return '$year-$month';
  }

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
      final children = _isDirector
          ? await _childService.getAllChildren()
          : await _childService.getChildrenBySection(widget.user.section);

      final attendance =
          await _attendanceService.getAttendanceForDate(_todayText);

      int present = 0;
      int absent = 0;

      for (final child in children) {
        final status = attendance[child.id];

        if (status == 'حاضر') {
          present++;
        } else if (status == 'غائب') {
          absent++;
        }
      }

      int lateSubscriptions = 0;

      if (_isDirector) {
        final subscriptions = await _subscriptionService
            .getSubscriptionsForMonth(_currentMonth);

        for (final subscription in subscriptions.values) {
          final remaining = subscription['remainingAmount'];

          if (remaining is num && remaining > 0) {
            lateSubscriptions++;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _totalChildren = children.length;
        _presentChildren = present;
        _absentChildren = absent;
        _lateSubscriptions = lateSubscriptions;
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

  List<Widget> _buildStatCards() {
    return [
      StatCard(
        icon: Icons.child_care_rounded,
        value: _totalChildren,
        label: 'إجمالي الأطفال',
        color: AppTheme.statTotal,
      ),
      StatCard(
        icon: Icons.check_circle_rounded,
        value: _presentChildren,
        label: 'الحاضرون اليوم',
        color: AppTheme.statPresent,
      ),
      StatCard(
        icon: Icons.cancel_rounded,
        value: _absentChildren,
        label: 'الغائبون اليوم',
        color: AppTheme.statAbsent,
      ),
      StatCard(
        icon: Icons.account_balance_wallet_rounded,
        value: _lateSubscriptions,
        label: 'اشتراكات متأخرة',
        color: AppTheme.statLate,
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
        color: AppTheme.statPresent,
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
        color: AppTheme.statLate,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: _isLoading
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
                    const SectionTitle(title: 'نظرة سريعة'),
                    SizedBox(height: AppTheme.spaceMd),
                    DashboardGrid(
                      mobileColumns: 2,
                      wideColumns: 4,
                      children: _buildStatCards(),
                    ),
                    SizedBox(height: AppTheme.spaceLg),
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