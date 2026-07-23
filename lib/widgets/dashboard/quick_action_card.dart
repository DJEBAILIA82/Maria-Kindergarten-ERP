import 'package:flutter/material.dart';

import '../app_theme.dart';

/// بطاقة عملية سريعة واحدة، قابلة لإعادة الاستخدام في أي صفحة.
/// لا تحتوي على أي منطق تنقّل بنفسها؛ فقط تستقبل [onTap] وتنفّذه.
class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    setState(() {
      _pressed = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, fade, child) {
        return Opacity(
          opacity: fade,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.92, end: 1.0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, entranceScale, child) {
          return Transform.scale(
            scale: entranceScale,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Material(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.spaceMd,
                  horizontal: AppTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.12),
                  ),
                  boxShadow: AppTheme.shadowSoft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spaceSm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withValues(alpha: 0.22),
                            widget.color.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 26,
                      ),
                    ),
                    SizedBox(height: AppTheme.spaceSm),
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: AppTheme.quickActionLabel,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}