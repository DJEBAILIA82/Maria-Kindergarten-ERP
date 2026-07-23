import 'package:flutter/material.dart';

import '../attendance_service.dart';
import '../child_service.dart';
import '../expense_service.dart';
import '../models/user.dart';
import '../subscription_service.dart';
import 'attendance_page.dart';
import 'attendance_report_page.dart';
import 'children_page.dart';
import 'expenses_page.dart';
import 'late_subscriptions_page.dart';
import 'messages_page.dart';
import 'sections_page.dart';
import 'subscriptions_page.dart';
import '../main.dart';
import 'settings_page.dart';
import 'activities_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChildService _childService = ChildService();
  final AttendanceService _attendanceService = AttendanceService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final ExpenseService _expenseService = ExpenseService();

  int _totalChildren = 0;
  int _presentChildren = 0;
  int _absentChildren = 0;

  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;

  Map<String, int> _attendanceBySection = {};
  int _lateSubscriptions = 0;
  int _unregisteredChildren = 0;

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

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0)} دج';
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final children = _isDirector
          ? await _childService.getAllChildren()
          : await _childService.getChildrenBySection(
              widget.user.section,
            );

      final attendance =
          await _attendanceService.getAttendanceForDate(_todayText);

      int present = 0;
      int absent = 0;

      final Map<String, int> attendanceBySection = {};
      int unregisteredChildren = 0;

      for (final child in children) {
        final status = attendance[child.id];

        if (status == 'حاضر') {
          present++;
        } else if (status == 'غائب') {
          absent++;
        } else {
          unregisteredChildren++;
        }

        final section = child.section.trim();

        if (status == 'حاضر') {
          attendanceBySection[section] =
              (attendanceBySection[section] ?? 0) + 1;
        }
      }

      double income = 0;
      double expenses = 0;
      int lateSubscriptions = 0;

      if (_isDirector) {
        final subscriptions =
            await _subscriptionService.getSubscriptionsForMonth(
          _currentMonth,
        );

        expenses = await _expenseService.getTotalExpensesForMonth(
          _currentMonth,
        );

        for (final subscription in subscriptions.values) {
          final paidAmount = subscription['paidAmount'];

          if (paidAmount is num) {
            income += paidAmount.toDouble();
          }

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
        _monthlyIncome = income;
        _monthlyExpenses = expenses;
        _attendanceBySection = attendanceBySection;
        _lateSubscriptions = lateSubscriptions;
        _unregisteredChildren = unregisteredChildren;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _totalChildren = 0;
        _presentChildren = 0;
        _absentChildren = 0;
        _monthlyIncome = 0;
        _monthlyExpenses = 0;
        _attendanceBySection = {};
        _lateSubscriptions = 0;
        _unregisteredChildren = 0;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? page,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          page == null ? Icons.lock_outline : Icons.arrow_back_ios_new,
          color: page == null ? Colors.grey : color,
          size: 20,
        ),
        onTap: page == null
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('صفحة $title ستكون جاهزة قريباً'),
                  ),
                );
              }
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => page,
                  ),
                );

                if (mounted) {
                  _loadDashboardData();
                }
              },
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _financeCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 10,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlyBalance = _monthlyIncome - _monthlyExpenses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مملكة ماريا'),
          centerTitle: true,
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadDashboardData,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث الملخص',
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                key: const PageStorageKey('homePageScroll'),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 70,
                          color: Colors.pink,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🌸 مملكة ماريا 🌸',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'مرحبًا ${widget.user.fullName}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isDirector
                              ? 'صلاحية: مديرة الروضة'
                              : 'صلاحية: معلمة — قسم ${widget.user.section}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'ملخص اليوم',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(
                        Icons.child_care,
                        'إجمالي الأطفال',
                        _totalChildren.toString(),
                        Colors.pink,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        Icons.check_circle,
                        'الحاضرون',
                        _presentChildren.toString(),
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        Icons.cancel,
                        'الغائبون',
                        _absentChildren.toString(),
                        Colors.red,
                      ),
                    ],
                  ),
                  if (_isDirector) ...[
                    const SizedBox(height: 20),
                    Text(
                      'الملخص المالي لشهر $_currentMonth',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _financeCard(
                          icon: Icons.account_balance_wallet,
                          title: 'المداخيل',
                          value: _formatMoney(_monthlyIncome),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _financeCard(
                          icon: Icons.money_off,
                          title: 'المصروفات',
                          value: _formatMoney(_monthlyExpenses),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          monthlyBalance >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: monthlyBalance >= 0
                              ? Colors.blue
                              : Colors.red,
                          size: 32,
                        ),
                        title: const Text(
                          'صافي الشهر',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          monthlyBalance >= 0
                              ? 'المداخيل أكبر من المصروفات'
                              : 'المصروفات أكبر من المداخيل',
                        ),
                        trailing: Text(
                          _formatMoney(monthlyBalance),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: monthlyBalance >= 0
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'إدارة الروضة',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _menuCard(
                    context: context,
                    icon: Icons.child_care,
                    title: 'الأطفال',
                    subtitle: 'إضافة وتعديل بيانات الأطفال وصورهم',
                    color: Colors.pink,
                    page: ChildrenPage(user: widget.user),
                  ),
                  if (_isDirector)
                    _menuCard(
                      context: context,
                      icon: Icons.groups,
                      title: 'الأقسام',
                      subtitle: 'إدارة الأقسام والمعلمات والطاقة الاستيعابية',
                      color: Colors.deepPurple,
                      page: const SectionsPage(),
                    ),
                  _menuCard(
                    context: context,
                    icon: Icons.fact_check,
                    title: 'الحضور والغياب',
                    subtitle: 'تسجيل حضور وغياب الأطفال يومياً بسهولة',
                    color: Colors.green,
                    page: AttendancePage(user: widget.user),
                  ),
                  _menuCard(
                    context: context,
                    icon: Icons.bar_chart,
                    title: 'التقارير',
                    subtitle: 'تقارير شهرية وتحليل حضور وغياب الأطفال',
                    color: Colors.indigo,
                    page: AttendanceReportPage(
                      user: widget.user,
                    ),
                  ),
                  if (_isDirector)
                    _menuCard(
                      context: context,
                      icon: Icons.payments,
                      title: 'الاشتراكات',
                      subtitle: 'متابعة رسوم الاشتراك والنقل',
                      color: Colors.orange,
                      page: const SubscriptionsPage(),
                    ),
                  if (_isDirector)
                    _menuCard(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      title: 'المتأخرون بالدفع',
                      subtitle: 'تذكير أولياء الأمور المتأخرين عبر واتساب',
                      color: Colors.deepOrange,
                      page: const LateSubscriptionsPage(),
                    ),
                  if (_isDirector)
                    _menuCard(
                      context: context,
                      icon: Icons.receipt_long,
                      title: 'المصروفات',
                      subtitle: 'الكراء والعمال والمشتريات والصيانة وغيرها',
                      color: Colors.redAccent,
                      page: ExpensesPage(),
                    ),
                    
                  _menuCard(
                    context: context,
                    icon: Icons.message,
                    title: 'الرسائل',
                    subtitle: 'إرسال تنبيهات ومراسلات للأولياء',
                    color: Colors.blue,
                    page: const MessagesPage(),
                  ),
                  
                  _menuCard(
  context: context,
  icon: Icons.photo_library,
  title: 'معرض الأنشطة',
  subtitle: 'رفع صور الأنشطة وإدارة الألبومات',
  color: Colors.deepOrange,
  page: const ActivitiesPage(),
),

                  const SizedBox(height: 20),

                  const Text(
                    'الموجز اليومي',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.groups,
                                      color: Colors.pink,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _totalChildren.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("إجمالي الأطفال"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _presentChildren.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("الحاضرون"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _absentChildren.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("الغائبون"),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          LinearProgressIndicator(
                            value: _totalChildren == 0
                                ? 0
                                : _presentChildren / _totalChildren,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green,
                            backgroundColor: Colors.red.shade100,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            _totalChildren == 0
                                ? "لا توجد بيانات اليوم"
                                : "نسبة الحضور ${(100 * _presentChildren / _totalChildren).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}