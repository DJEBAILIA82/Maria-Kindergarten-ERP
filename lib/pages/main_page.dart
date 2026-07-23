import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_navigation.dart';
import 'attendance_page.dart';
import 'attendance_report_page.dart';
import 'children_page.dart';
import 'home/dashboard_page.dart';
import 'subscriptions_page.dart';

/// الصفحة الرئيسية: Scaffold واحد فقط يحتوي على
/// Drawer + BottomNavigationBar، والمحتوى يتغيّر عبر IndexedStack.
///
/// ملاحظة معمارية: تبويب "لوحة التحكم" (index 0) لا يستعمل AppBar تقليدي،
/// لأن DashboardHeader نفسه يقوم بهذا الدور (هو الهوية البصرية الرسمية
/// لتلك الصفحة، وفيه زر قائمة (☰) يفتح نفس الـ Drawer). باقي التبويبات
/// (الأطفال، الحضور...) لسا تستعمل AppBar القديم مؤقتًا، لأنها لم تنتقل
/// بعد للهوية الجديدة (مرحلة قادمة).
class MainPage extends StatefulWidget {
  final AppUser user;

  const MainPage({
    super.key,
    required this.user,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'الرئيسية',
    'الأطفال',
    'الحضور والغياب',
    'الاشتراكات',
    'المدفوعات',
  ];

  late final List<Widget> _pages = [
    DashboardPage(user: widget.user),
    ChildrenPage(user: widget.user),
    AttendancePage(user: widget.user),
    const SubscriptionsPage(),
    // مؤقتًا: "المدفوعات" تستعمل نفس صفحة الاشتراكات لحين إنشاء
    // صفحة مدفوعات مستقلة في مرحلة قادمة.
    const SubscriptionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDashboardTab = _currentIndex == 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: isDashboardTab
            ? null
            : AppBar(
                title: Text(_titles[_currentIndex]),
              ),
        drawer: AppDrawer(user: widget.user),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}