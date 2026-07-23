import 'package:flutter/material.dart';

import '../models/user.dart';
import '../pages/activities_page.dart';
import '../pages/attendance_report_page.dart';
import '../pages/expenses_page.dart';
import '../pages/gallery_page.dart';
import '../pages/late_subscriptions_page.dart';
import '../pages/messages_page.dart';
import '../pages/sections_page.dart';
import '../pages/settings_page.dart';
import 'app_theme.dart';

/// القائمة الجانبية الموحدة. تُستعمل داخل MainPage فقط.
class AppDrawer extends StatelessWidget {
  final AppUser user;

  const AppDrawer({
    super.key,
    required this.user,
  });

  void _comingSoon(BuildContext context, String title) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('صفحة $title ستكون جاهزة قريبًا')),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.darkPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.castle,
                      size: 54,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'مملكة ماريا',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.celebration,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('الأنشطة'),
                      onTap: () => _openPage(
                        context,
                        const ActivitiesPage(),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('معرض الصور'),
                      onTap: () => _openPage(
                        context,
                        GalleryPage(user: user),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.message,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('الرسائل'),
                      onTap: () => _openPage(
                        context,
                        const MessagesPage(),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.bar_chart,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('التقارير'),
                      onTap: () => _openPage(
                        context,
                        AttendanceReportPage(user: user),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.badge,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('الموظفون'),
                      onTap: () => _comingSoon(context, 'الموظفون'),
                    ),
                    if (user.isDirector)
                      ListTile(
                        leading: const Icon(
                          Icons.receipt_long,
                          color: AppTheme.primaryPurple,
                        ),
                        title: const Text('المصروفات'),
                        onTap: () => _openPage(
                          context,
                          const ExpensesPage(),
                        ),
                      ),
                    if (user.isDirector)
                      ListTile(
                        leading: const Icon(
                          Icons.groups_2,
                          color: AppTheme.primaryPurple,
                        ),
                        title: const Text('الأقسام'),
                        onTap: () => _openPage(
                          context,
                          const SectionsPage(),
                        ),
                      ),
                    if (user.isDirector)
                      ListTile(
                        leading: const Icon(
                          Icons.payments_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        title: const Text('المتأخرون في الدفع'),
                        onTap: () => _openPage(
                          context,
                          const LateSubscriptionsPage(),
                        ),
                      ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('الإعدادات'),
                      onTap: () => _openPage(
                        context,
                        const SettingsPage(),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.backup,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('النسخ الاحتياطي'),
                      onTap: () => _comingSoon(context, 'النسخ الاحتياطي'),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryPurple,
                      ),
                      title: const Text('حول التطبيق'),
                      onTap: () => _comingSoon(context, 'حول التطبيق'),
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