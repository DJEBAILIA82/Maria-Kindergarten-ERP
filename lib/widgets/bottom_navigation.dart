import 'package:flutter/material.dart';

import 'app_theme.dart';

/// شريط تنقل سفلي موحد يُستعمل داخل MainPage فقط.
/// لا يُنشئ أي Scaffold جديد بنفسه.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'لوحة التحكم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.child_care),
          label: 'الأطفال',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'الحضور',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments),
          label: 'الاشتراكات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'المدفوعات',
        ),
      ],
    );
  }
}