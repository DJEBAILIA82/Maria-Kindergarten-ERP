import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../app_theme.dart';

/// رأس لوحة التحكم — الهوية البصرية الرسمية لتبويب لوحة التحكم.
/// يحل محل AppBar التقليدي (فيه زر قائمة خاص به لفتح الـ Drawer).
/// Widget عرض فقط، بدون أي منطق بيانات.
class DashboardHeader extends StatelessWidget {
  final AppUser user;

  const DashboardHeader({
    super.key,
    required this.user,
  });

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 18) return 'مساء الخير';
    return 'مساء الخير';
  }

  String get _roleText {
    if (user.isDirector) return 'مديرة الروضة';
    return 'معلمة — قسم ${user.section}';
  }

  String get _initial {
    final name = user.fullName.trim();
    if (name.isEmpty) return '؟';
    return name.substring(0, 1).toUpperCase();
  }

  void _showNoNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لا توجد إشعارات حاليًا'),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceWhite.withValues(alpha: opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusLg),
        bottomRight: Radius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryPurple, AppTheme.darkPurple],
          ),
          boxShadow: AppTheme.shadowLifted,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: _decorCircle(110, 0.08),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: _decorCircle(140, 0.06),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spaceSm,
                  AppTheme.spaceSm,
                  AppTheme.spaceLg,
                  AppTheme.spaceXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            return IconButton(
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              icon: Icon(
                                Icons.menu_rounded,
                                color: AppTheme.textOnPrimary,
                              ),
                              tooltip: 'القائمة',
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () => _showNoNotifications(context),
                          icon: Icon(
                            Icons.notifications_rounded,
                            color: AppTheme.textOnPrimary,
                          ),
                          tooltip: 'الإشعارات',
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.goldAccent,
                                width: 2.4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  AppTheme.surfaceWhite.withValues(alpha: 0.18),
                              child: Text(
                                _initial,
                                style: AppTheme.headingLarge.copyWith(
                                  color: AppTheme.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _greetingIcon,
                                      size: 16,
                                      color: AppTheme.goldAccent,
                                    ),
                                    SizedBox(width: AppTheme.spaceXs),
                                    Flexible(
                                      child: Text(
                                        _greeting,
                                        style: AppTheme.bodyText.copyWith(
                                          color: AppTheme.textOnPrimary
                                              .withValues(alpha: 0.85),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  user.fullName,
                                  style: AppTheme.headingLarge.copyWith(
                                    color: AppTheme.textOnPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppTheme.spaceXs),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.spaceSm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldAccent
                                        .withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    _roleText,
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.goldAccent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}