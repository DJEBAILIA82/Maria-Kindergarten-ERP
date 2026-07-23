import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../child_service.dart';
import '../models/child.dart';
import '../subscription_service.dart';

class LateSubscriptionsPage extends StatefulWidget {
  const LateSubscriptionsPage({super.key});

  @override
  State<LateSubscriptionsPage> createState() => _LateSubscriptionsPageState();
}

class _LateSubscriptionsPageState extends State<LateSubscriptionsPage> {
  final ChildService _childService = ChildService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<Child> _children = [];
  Map<String, Map<String, dynamic>> _subscriptions = {};

  bool _isLoading = true;

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
      final children = await _childService.getAllChildren();
      final subscriptions =
          await _subscriptionService.getSubscriptionsForMonth(
        _currentMonth,
      );

      if (!mounted) return;

      setState(() {
        _children = children;
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل بيانات الاشتراكات: $error'),
        ),
      );
    }
  }

  double? _remainingFor(Child child) {
    final subscription = _subscriptions[child.id];

    if (subscription == null) return null;

    final remaining = subscription['remainingAmount'];

    if (remaining is num) return remaining.toDouble();

    return double.tryParse(remaining?.toString() ?? '') ?? 0;
  }

  List<Child> get _lateChildren {
    final result = _children.where((child) {
      final remaining = _remainingFor(child);

      return remaining != null && remaining > 0;
    }).toList();

    result.sort((a, b) {
      final remainingA = _remainingFor(a) ?? 0;
      final remainingB = _remainingFor(b) ?? 0;

      return remainingB.compareTo(remainingA);
    });

    return result;
  }

  List<Child> get _unregisteredChildren {
    return _children.where((child) {
      return _remainingFor(child) == null;
    }).toList();
  }

  String _childName(Child child) {
    return '${child.firstName} ${child.lastName}'.trim();
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0)} دج';
  }

  String _phoneForChild(Child child) {
    final phone1 = child.phone1.trim();

    if (phone1.isNotEmpty) return phone1;

    return child.phone2.trim();
  }

  String _cleanPhone(String phone) {
    var result = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (result.startsWith('+213')) {
      result = '213${result.substring(4)}';
    } else if (result.startsWith('00213')) {
      result = '213${result.substring(5)}';
    } else if (result.startsWith('0')) {
      result = '213${result.substring(1)}';
    }

    return result.replaceAll('+', '');
  }

  String _reminderMessage(Child child) {
    final remaining = _remainingFor(child);

    if (remaining == null) {
      return '''
السلام عليكم،

نلاحظ عدم تسجيل اشتراك الطفل/ة: ${_childName(child)}
عن شهر $_currentMonth.

يرجى التقرب من إدارة روضة مملكة ماريا لتسوية الوضعية في أقرب وقت.

شكرًا لتفهمكم.
''';
    }

    return '''
السلام عليكم،

تذكير بخصوص تسديد رسوم اشتراك الطفل/ة: ${_childName(child)}
عن شهر $_currentMonth.

المبلغ المتبقي: ${_formatMoney(remaining)}

يرجى التقرب من إدارة روضة مملكة ماريا لتسوية الوضعية في أقرب وقت.

شكرًا لتفهمكم.
''';
  }

  Future<void> _openWhatsAppForChild(Child child) async {
    final phone = _phoneForChild(child);

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد رقم هاتف مسجل للطفل ${_childName(child)}',
          ),
        ),
      );
      return;
    }

    final cleanPhone = _cleanPhone(phone);

    if (cleanPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'رقم الهاتف غير صحيح للطفل ${_childName(child)}',
          ),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(_reminderMessage(child))}',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح واتساب. تأكد من تثبيت تطبيق واتساب على الهاتف.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح واتساب. تأكد من تثبيت تطبيق واتساب على الهاتف.',
          ),
        ),
      );
    }
  }

  Widget _lateChildTile(Child child) {
    final remaining = _remainingFor(child);
    final isUnregistered = remaining == null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: (isUnregistered ? Colors.grey : Colors.red)
              .withValues(alpha: 0.12),
          child: Icon(
            isUnregistered ? Icons.help_outline : Icons.person,
            color: isUnregistered ? Colors.grey.shade700 : Colors.red,
          ),
        ),
        title: Text(
          _childName(child),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          isUnregistered
              ? 'القسم: ${child.section}\nلم يُسجَّل اشتراك لهذا الشهر'
              : 'القسم: ${child.section}\nالمتبقي: ${_formatMoney(remaining)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: () => _openWhatsAppForChild(child),
          icon: const Icon(
            Icons.chat,
            color: Color(0xFF25D366),
            size: 30,
          ),
          tooltip: 'إرسال تذكير عبر واتساب',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lateChildren = _lateChildren;
    final unregisteredChildren = _unregisteredChildren;
    final totalCount = lateChildren.length + unregisteredChildren.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المتأخرون بالدفع'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : totalCount == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.celebration,
                            size: 60,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا يوجد متأخرون عن الدفع لشهر $_currentMonth 🎉',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'إجمالي الحالات التي تحتاج متابعة لشهر $_currentMonth: $totalCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (lateChildren.isNotEmpty) ...[
                        const Text(
                          'متأخرون بمبلغ متبقٍ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...lateChildren.map(_lateChildTile),
                        const SizedBox(height: 10),
                      ],
                      if (unregisteredChildren.isNotEmpty) ...[
                        const Text(
                          'لم يُسجَّل اشتراكهم لهذا الشهر',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...unregisteredChildren.map(_lateChildTile),
                      ],
                    ],
                  ),
      ),
    );
  }
}