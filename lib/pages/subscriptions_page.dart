import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../child_service.dart';
import '../models/child.dart';
import '../subscription_service.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final ChildService _childService = ChildService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<Child> _children = [];
  Map<String, Map<String, dynamic>> _subscriptions = {};

  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  String get _monthKey {
    final year = _selectedMonth.year.toString();
    final month = _selectedMonth.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  String get _monthTitle {
    const months = [
      'جانفي',
      'فيفري',
      'مارس',
      'أفريل',
      'ماي',
      'جوان',
      'جويلية',
      'أوت',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  double _readAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  String _money(double amount) {
    return '${amount.toStringAsFixed(2)} دج';
  }

  bool _hasTransport(Child child) {
    final transport = child.transport.trim().toLowerCase();

    return transport == 'نعم' ||
        transport == 'yes' ||
        transport == 'oui' ||
        transport == '1' ||
        transport == 'true' ||
        transport.contains('نقل') ||
        transport.contains('transport');
  }

  double _defaultMonthlyFee(Child child) {
    return _hasTransport(child) ? 10000.00 : 8000.00;
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

  String _phoneForChild(Child child) {
    if (child.phone1.trim().isNotEmpty) return child.phone1.trim();
    return child.phone2.trim();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final children = await _childService.getAllChildren();
      final subscriptions = await _subscriptionService.getSubscriptionsForMonth(
        _monthKey,
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
        _children = [];
        _subscriptions = {};
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل الاشتراكات: $error'),
        ),
      );
    }
  }

  Future<void> _selectMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      helpText: 'اختر أي يوم من الشهر المطلوب',
    );

    if (selected == null) return;

    setState(() {
      _selectedMonth = DateTime(selected.year, selected.month);
    });

    await _loadData();
  }

  Future<void> _showWhatsAppReminderDialog(
    Child child,
    double remainingAmount,
  ) async {
    final phone = _phoneForChild(child);

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد رقم هاتف مسجل لولي الطفل ${child.firstName} ${child.lastName}',
          ),
        ),
      );
      return;
    }

    final amountController = TextEditingController(
      text: remainingAmount.toStringAsFixed(2),
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final amount = _readAmount(amountController.text);

              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('تذكير بالاشتراك عبر واتساب'),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${child.firstName} ${child.lastName}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('شهر: $_monthTitle'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) {
                              setDialogState(() {});
                            },
                            decoration: const InputDecoration(
                              labelText: 'المبلغ المطلوب',
                              suffixText: 'دج',
                              prefixIcon: Icon(Icons.payments),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'يمكنك تعديل المبلغ قبل فتح واتساب.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'المبلغ الذي سيظهر في الرسالة: ${_money(amount)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (amount <= 0) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('أدخل مبلغًا صحيحًا أكبر من صفر'),
                            ),
                          );
                          return;
                        }

                        final cleanPhone = _cleanPhone(phone);

                        if (cleanPhone.length < 10) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('رقم هاتف ولي الأمر غير صحيح'),
                            ),
                          );
                          return;
                        }

                        final message = '''
السلام عليكم ورحمة الله وبركاته 🌟

نذكّركم بلطف بأن اشتراك الطفل(ة): ${child.firstName} ${child.lastName} بالنسبة لشهر $_monthTitle لم يُسدَّد بعد للروضة، والمبلغ المستحق هو: ${amount.toStringAsFixed(2)} دج. 📋

يرجى التقرب من إدارة روضة مملكة ماريا لتسوية الوضعية عند الإمكان. 📑

شكرًا لتعاونكم الدائم وتفهمكم. 🙏✨

إدارة روضة مملكة ماريا 🌸
''';

                        final uri = Uri.parse(
                          'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
                        );

                        try {
                          final opened = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );

                          if (!opened && dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تعذر فتح واتساب. تأكد من تثبيت التطبيق.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (_) {
                          if (!dialogContext.mounted) return;

                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تعذر فتح واتساب. تأكد من تثبيت التطبيق.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('فتح واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      amountController.dispose();
    }
  }

  Future<void> _openSubscriptionDialog(Child child) async {
    final saved = _subscriptions[child.id];
    final defaultTotal = _defaultMonthlyFee(child);

    final monthlyFeeController = TextEditingController(
      text: _readAmount(saved?['monthlyFee'] ?? defaultTotal).toStringAsFixed(2),
    );

    final transportFeeController = TextEditingController(
      text: _readAmount(saved?['transportFee'] ?? 0).toStringAsFixed(2),
    );

    final otherFeeNameController = TextEditingController(
      text: saved?['otherFeeName']?.toString() ?? '',
    );

    final otherFeeController = TextEditingController(
      text: _readAmount(saved?['otherFee'] ?? 0).toStringAsFixed(2),
    );

    final paidAmountController = TextEditingController(
      text: _readAmount(saved?['paidAmount'] ?? 0).toStringAsFixed(2),
    );

    final notesController = TextEditingController(
      text: saved?['notes']?.toString() ?? '',
    );

    bool isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isSaving,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              double currentAmount(TextEditingController controller) {
                return double.tryParse(
                      controller.text.trim().replaceAll(',', '.'),
                    ) ??
                    0;
              }

              final monthlyFee = currentAmount(monthlyFeeController);
              final transportFee = currentAmount(transportFeeController);
              final otherFee = currentAmount(otherFeeController);
              final paidAmount = currentAmount(paidAmountController);

              final totalAmount = monthlyFee + transportFee + otherFee;
              final remainingAmount = totalAmount - paidAmount;

              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text(saved == null ? 'تسجيل اشتراك' : 'تعديل اشتراك'),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 420,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${child.firstName} ${child.lastName}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('شهر: $_monthTitle'),
                                const SizedBox(height: 4),
                                Text(
                                  _hasTransport(child)
                                      ? 'مسجل في النقل — المبلغ الافتراضي 10000.00 دج'
                                      : 'غير مسجل في النقل — المبلغ الافتراضي 8000.00 دج',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: monthlyFeeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'إجمالي اشتراك الطفل',
                              suffixText: 'دج',
                              prefixIcon: Icon(Icons.school),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: transportFeeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'رسوم إضافية للنقل (اختياري)',
                              suffixText: 'دج',
                              prefixIcon: Icon(Icons.directions_bus),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: otherFeeNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم الرسوم الأخرى',
                              hintText: 'مثال: رحلة، كتب، تأمين...',
                              prefixIcon: Icon(Icons.add_card),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: otherFeeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'قيمة الرسوم الأخرى',
                              suffixText: 'دج',
                              prefixIcon: Icon(Icons.payments_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: paidAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'المبلغ المدفوع',
                              suffixText: 'دج',
                              prefixIcon: Icon(Icons.account_balance_wallet),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'ملاحظات',
                              prefixIcon: Icon(Icons.notes),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _amountLine(
                                  'إجمالي الرسوم',
                                  _money(totalAmount),
                                  Colors.blue,
                                ),
                                const SizedBox(height: 6),
                                _amountLine(
                                  'المدفوع',
                                  _money(paidAmount),
                                  Colors.green,
                                ),
                                const Divider(),
                                _amountLine(
                                  'المتبقي',
                                  _money(
                                    remainingAmount > 0 ? remainingAmount : 0,
                                  ),
                                  remainingAmount > 0
                                      ? Colors.red
                                      : Colors.green,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSaving
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final monthlyFee = currentAmount(
                                monthlyFeeController,
                              );
                              final transportFee = currentAmount(
                                transportFeeController,
                              );
                              final otherFee = currentAmount(
                                otherFeeController,
                              );
                              final paidAmount = currentAmount(
                                paidAmountController,
                              );

                              if (monthlyFee < 0 ||
                                  transportFee < 0 ||
                                  otherFee < 0 ||
                                  paidAmount < 0) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'لا يمكن إدخال مبلغ سالب',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setDialogState(() {
                                isSaving = true;
                              });

                              try {
                                await _subscriptionService.saveSubscription(
                                  childId: child.id,
                                  subscriptionMonth: _monthKey,
                                  monthlyFee: monthlyFee,
                                  transportFee: transportFee,
                                  otherFee: otherFee,
                                  otherFeeName: otherFeeNameController.text
                                      .trim(),
                                  paidAmount: paidAmount,
                                  notes: notesController.text.trim(),
                                );

                                if (!dialogContext.mounted) return;
                                Navigator.of(dialogContext).pop();
                              } catch (error) {
                                if (!dialogContext.mounted) return;

                                setDialogState(() {
                                  isSaving = false;
                                });

                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'حدث خطأ أثناء الحفظ: $error',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      if (!mounted) return;
      await _loadData();
    } finally {
      monthlyFeeController.dispose();
      transportFeeController.dispose();
      otherFeeNameController.dispose();
      otherFeeController.dispose();
      paidAmountController.dispose();
      notesController.dispose();
    }
  }

  Widget _amountLine(
    String title,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _childCard(Child child) {
    final subscription = _subscriptions[child.id];

    final defaultAmount = _defaultMonthlyFee(child);
    final monthlyFee = _readAmount(subscription?['monthlyFee'] ?? defaultAmount);
    final transportFee = _readAmount(subscription?['transportFee'] ?? 0);
    final otherFee = _readAmount(subscription?['otherFee'] ?? 0);
    final paidAmount = _readAmount(subscription?['paidAmount'] ?? 0);

    final totalAmount = monthlyFee + transportFee + otherFee;
    final remainingAmount = _readAmount(
      subscription?['remainingAmount'] ?? totalAmount,
    );

    final isSaved = subscription != null;
    final isPaid = isSaved && remainingAmount <= 0;
    final canSendReminder = isSaved && remainingAmount > 0;

    final statusColor = !isSaved
        ? Colors.grey
        : isPaid
            ? Colors.green
            : Colors.red;

    final statusText = !isSaved
        ? 'غير مسجل'
        : isPaid
            ? 'مكتمل'
            : 'متبقي';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openSubscriptionDialog(child),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.payments,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${child.firstName} ${child.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.section.isEmpty
                              ? 'القسم: غير محدد'
                              : 'القسم: ${child.section}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isSaved
                              ? 'المدفوع: ${_money(paidAmount)} • المتبقي: ${_money(remainingAmount)}'
                              : 'اضغط لتسجيل اشتراك هذا الشهر',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSaved ? statusColor : Colors.black54,
                            fontWeight: isSaved
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Chip(
                        label: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        side: BorderSide.none,
                      ),
                      const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ],
              ),
              if (canSendReminder) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showWhatsAppReminderDialog(child, remainingAmount);
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال تذكير واتساب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedSubscriptions = _subscriptions.length;

    double totalRequired = 0;
    double totalPaid = 0;
    double totalRemaining = 0;

    for (final subscription in _subscriptions.values) {
      totalRequired += _readAmount(subscription['monthlyFee']) +
          _readAmount(subscription['transportFee']) +
          _readAmount(subscription['otherFee']);

      totalPaid += _readAmount(subscription['paidAmount']);
      totalRemaining += _readAmount(subscription['remainingAmount']);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الاشتراكات'),
          backgroundColor: Colors.orange,
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
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF3E0),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.orange,
                        ),
                      ),
                      title: const Text(
                        'شهر الاشتراكات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_monthTitle),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _selectMonth,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _summaryCard(
                        icon: Icons.people,
                        title: 'المسجلون',
                        value: '$savedSubscriptions/${_children.length}',
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      _summaryCard(
                        icon: Icons.account_balance_wallet,
                        title: 'المدفوع',
                        value: _money(totalPaid),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _summaryCard(
                        icon: Icons.warning_amber,
                        title: 'المتبقي',
                        value: _money(totalRemaining),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'المبلغ الافتراضي: 8000.00 دج لغير المسجلين في النقل، و10000.00 دج للمسجلين في النقل. يمكن تعديل أي مبلغ لكل طفل.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'قائمة الأطفال',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_children.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'لا يوجد أطفال مسجلون حالياً',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ..._children.map(_childCard),
                  const SizedBox(height: 20),
                  if (savedSubscriptions > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'إجمالي الرسوم المسجلة: ${_money(totalRequired)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}