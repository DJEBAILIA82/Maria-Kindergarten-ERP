import 'package:flutter/material.dart';

import '../expense_service.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final ExpenseService _expenseService = ExpenseService();

  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = _monthText(DateTime.now());
    _loadExpenses();
  }

  String _monthText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatMonth(String month) {
    final parts = month.split('-');

    if (parts.length != 2) return month;

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

    final monthNumber = int.tryParse(parts[1]) ?? 1;
    return '${months[monthNumber - 1]} ${parts[0]}';
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(double value) {
    return '${value.toStringAsFixed(2)} دج';
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await _expenseService.getExpensesForMonth(
        _selectedMonth,
      );

      if (!mounted) return;

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _expenses = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل المصروفات: $error'),
        ),
      );
    }
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
        int.parse(_selectedMonth.split('-')[0]),
        int.parse(_selectedMonth.split('-')[1]),
      ),
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 5),
      helpText: 'اختر أي يوم من الشهر المطلوب',
    );

    if (selected == null) return;

    setState(() {
      _selectedMonth = _monthText(selected);
    });

    await _loadExpenses();
  }

  Future<void> _showExpenseDialog({
    Map<String, dynamic>? expense,
  }) async {
    final isEditing = expense != null;

    final titleController = TextEditingController(
      text: expense?['title']?.toString() ?? '',
    );

    final amountController = TextEditingController(
      text: isEditing
          ? _toDouble(expense['amount']).toStringAsFixed(2)
          : '',
    );

    final notesController = TextEditingController(
      text: expense?['notes']?.toString() ?? '',
    );

    String category = expense?['category']?.toString() ?? 'كراء';
    DateTime selectedDate = isEditing
        ? DateTime.tryParse(expense['expenseDate']?.toString() ?? '') ??
            DateTime.now()
        : DateTime.now();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                  isEditing ? 'تعديل مصروف' : 'إضافة مصروف جديد',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'نوع المصروف',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'كراء',
                              child: Text('كراء الروضة'),
                            ),
                            DropdownMenuItem(
                              value: 'أجور',
                              child: Text('أجور ومستحقات العمال'),
                            ),
                            DropdownMenuItem(
                              value: 'مشتريات',
                              child: Text('مشتريات ولوازم'),
                            ),
                            DropdownMenuItem(
                              value: 'كهرباء وماء',
                              child: Text('كهرباء وماء وغاز'),
                            ),
                            DropdownMenuItem(
                              value: 'صيانة',
                              child: Text('صيانة وإصلاحات'),
                            ),
                            DropdownMenuItem(
                              value: 'أخرى',
                              child: Text('مصروف آخر'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              category = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'عنوان المصروف',
                            hintText: 'مثال: كراء شهر جوان',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'اكتب عنوان المصروف';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'المبلغ بالدينار',
                            hintText: 'مثال: 25000',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(
                              value?.replaceAll(',', '.') ?? '',
                            );

                            if (amount == null || amount <= 0) {
                              return 'اكتب مبلغًا صحيحًا';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_month),
                          title: const Text('تاريخ المصروف'),
                          subtitle: Text(_dateText(selectedDate)),
                          trailing: const Icon(Icons.edit_calendar),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2035),
                            );

                            if (picked == null) return;

                            setDialogState(() {
                              selectedDate = picked;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات اختيارية',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final amount = double.parse(
                        amountController.text.replaceAll(',', '.'),
                      );

                      try {
                        if (isEditing) {
                          await _expenseService.updateExpense(
                            id: expense['id'] as int,
                            category: category,
                            title: titleController.text.trim(),
                            amount: amount,
                            expenseDate: _dateText(selectedDate),
                            notes: notesController.text.trim(),
                          );
                        } else {
                          await _expenseService.addExpense(
                            category: category,
                            title: titleController.text.trim(),
                            amount: amount,
                            expenseDate: _dateText(selectedDate),
                            notes: notesController.text.trim(),
                          );
                        }

                        if (!mounted) return;

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'تم تعديل المصروف بنجاح'
                                  : 'تم حفظ المصروف بنجاح',
                            ),
                          ),
                        );

                        await _loadExpenses();
                      } catch (error) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ أثناء الحفظ: $error'),
                          ),
                        );
                      }
                    },
                    child: Text(isEditing ? 'حفظ التعديل' : 'حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
  }

  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف المصروف'),
            content: Text(
              'هل تريد حذف مصروف "${expense['title']}"؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _expenseService.deleteExpense(expense['id'] as int);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المصروف'),
        ),
      );

      await _loadExpenses();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف المصروف: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _expenses.fold<double>(
      0,
      (sum, expense) => sum + _toDouble(expense['amount']),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصروفات'),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadExpenses,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة مصروف'),
          onPressed: () {
            _showExpenseDialog();
          },
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.redAccent,
                        ),
                      ),
                      title: const Text(
                        'الشهر المعروض',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(_formatMonth(_selectedMonth)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _selectMonth,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.money_off,
                            color: Colors.redAccent,
                            size: 35,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'إجمالي مصروفات الشهر',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _money(total),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'قائمة المصروفات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'لا توجد مصروفات مسجلة لهذا الشهر',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ..._expenses.map(
                      (expense) {
                        final amount = _toDouble(expense['amount']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(
                                Icons.money_off,
                                color: Colors.redAccent,
                              ),
                            ),
                            title: Text(
                              expense['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${expense['category'] ?? 'أخرى'} • ${expense['expenseDate'] ?? ''}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _money(amount),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showExpenseDialog(expense: expense);
                                    } else if (value == 'delete') {
                                      _deleteExpense(expense);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('تعديل'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('حذف'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 90),
                ],
              ),
      ),
    );
  }
}

