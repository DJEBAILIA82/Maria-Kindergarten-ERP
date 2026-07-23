import 'package:flutter/material.dart';

import '../../attendance_service.dart';
import '../../child_service.dart';
import '../../models/user.dart';
import '../../subscription_service.dart';
import '../../widgets/app_theme.dart';
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

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientBackground,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              AppTheme.primaryPurple.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.primaryPurple,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحبًا بك',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                widget.user.fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _isDirector
                                    ? 'مديرة الروضة'
                                    : 'معلمة — قسم ${widget.user.section}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _statCard(
                        icon: Icons.child_care,
                        value: _totalChildren.toString(),
                        label: 'إجمالي الأطفال',
                        color: Colors.pink,
                      ),
                      _statCard(
                        icon: Icons.check_circle,
                        value: _presentChildren.toString(),
                        label: 'الحاضرون اليوم',
                        color: Colors.green,
                      ),
                      _statCard(
                        icon: Icons.cancel,
                        value: _absentChildren.toString(),
                        label: 'الغائبون اليوم',
                        color: Colors.deepOrange,
                      ),
                      _statCard(
                        icon: Icons.account_balance_wallet,
                        value: _lateSubscriptions.toString(),
                        label: 'الاشتراكات المتأخرة',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'العمليات السريعة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.95,
                          children: [
                            _quickAction(
                              icon: Icons.person_add,
                              label: 'إضافة طفل',
                              color: AppTheme.primaryPurple,
                              onTap: () => _openPage(
                                ChildrenPage(user: widget.user),
                              ),
                            ),
                            _quickAction(
                              icon: Icons.fact_check,
                              label: 'تسجيل الحضور',
                              color: Colors.green,
                              onTap: () => _openPage(
                                AttendancePage(user: widget.user),
                              ),
                            ),
                            _quickAction(
                              icon: Icons.payments,
                              label: 'تسجيل دفعة',
                              color: Colors.amber.shade700,
                              onTap: () => _openPage(
                                const SubscriptionsPage(),
                              ),
                            ),
                            _quickAction(
                              icon: Icons.send,
                              label: 'إرسال رسالة',
                              color: Colors.teal,
                              onTap: () => _openPage(
                                const MessagesPage(),
                              ),
                            ),
                            _quickAction(
                              icon: Icons.bar_chart,
                              label: 'التقارير',
                              color: Colors.indigo,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'افتح التقارير من القائمة الجانبية',
                                    ),
                                  ),
                                );
                              },
                            ),
                            _quickAction(
                              icon: Icons.settings,
                              label: 'الإعدادات',
                              color: Colors.grey.shade700,
                              onTap: () => _openPage(
                                const SettingsPage(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}