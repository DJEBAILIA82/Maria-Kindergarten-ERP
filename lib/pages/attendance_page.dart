import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../attendance_service.dart';
import '../child_service.dart';
import '../models/child.dart';
import '../models/user.dart';

class AttendancePage extends StatefulWidget {
  final AppUser user;

  const AttendancePage({
    super.key,
    required this.user,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final ChildService _childService = ChildService();
  final AttendanceService _attendanceService = AttendanceService();

  List<Child> _children = [];
  final Map<String, String> _attendance = {};

  bool _isLoading = true;
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();
  String _selectedSection = 'الكل';

  bool get _isDirector => widget.user.isDirector;

  String get _teacherSection => widget.user.section.trim();

  String get _dateText {
    final year = _selectedDate.year.toString();
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final day = _selectedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _normalizeSection(String value) {
    return value
        .trim()
        .replaceAll('قسم', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll('ـ', '')
        .replaceAll(' ', '')
        .toLowerCase();
  }

  bool _isChildInTeacherSection(Child child) {
    return _normalizeSection(child.section) ==
        _normalizeSection(_teacherSection);
  }

  @override
  void initState() {
    super.initState();

    if (!_isDirector && _teacherSection.isNotEmpty) {
      _selectedSection = _teacherSection;
    }

    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final children = await _childService.getAllChildren();

      final savedAttendance = await _attendanceService.getAttendanceForDate(
        _dateText,
      );

      if (!mounted) return;

      setState(() {
        _children = children;
        _attendance.clear();

        for (final child in children) {
          _attendance[child.id] = savedAttendance[child.id] ?? 'حاضر';
        }

        if (!_isDirector && _teacherSection.isNotEmpty) {
          _selectedSection = _teacherSection;
        }

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _children = [];
        _attendance.clear();
        _isLoading = false;
      });

      _showMessage('تعذر تحميل قائمة الحضور');
    }
  }

  List<String> get _sections {
    final values = _children
        .map((child) => child.section.trim())
        .where((section) => section.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return ['الكل', ...values];
  }

  List<Child> get _filteredChildren {
    if (!_isDirector) {
      return _children.where(_isChildInTeacherSection).toList();
    }

    if (_selectedSection == 'الكل') {
      return _children;
    }

    return _children.where((child) {
      return _normalizeSection(child.section) ==
          _normalizeSection(_selectedSection);
    }).toList();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (selected == null) return;

    setState(() {
      _selectedDate = selected;
    });

    await _loadAttendance();
  }

  void _markAll(String status) {
    setState(() {
      for (final child in _filteredChildren) {
        _attendance[child.id] = status;
      }
    });
  }

  String _cleanPhone(String phone) {
    var value = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (value.startsWith('+')) {
      value = value.substring(1);
    }

    if (value.startsWith('0')) {
      value = '213${value.substring(1)}';
    }

    return value;
  }

  Future<void> _sendAbsenceWhatsApp(Child child) async {
    final originalPhone = child.phone1.trim().isNotEmpty
        ? child.phone1.trim()
        : child.phone2.trim();

    if (originalPhone.isEmpty) {
      _showMessage('لا يوجد رقم هاتف مسجل للطفل ${child.fullName}');
      return;
    }

    final phone = _cleanPhone(originalPhone);

    if (phone.length < 10) {
      _showMessage('رقم الهاتف غير صحيح: $originalPhone');
      return;
    }

    final message = '''
السلام عليكم ورحمة الله وبركاته 🌸

وليّ أمر الطفل/ة: ${child.fullName} المحترم/ة،

نود إعلامكم بأن الطفل/ة ${child.fullName} غائب/ة اليوم عن الروضة.

نرجو منكم الاطمئنان على صحته وإفادتنا بسبب الغياب.

إدارة روضة مملكة ماريا

تاريخ الغياب: $_dateText
''';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage('تعذر فتح واتساب. تأكد من تثبيت التطبيق.');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('تعذر فتح واتساب');
    }
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (final child in _filteredChildren) {
        await _attendanceService.saveAttendance(
          childId: child.id,
          attendanceDate: _dateText,
          status: _attendance[child.id] ?? 'حاضر',
          notes: '',
        );
      }

      if (!mounted) return;

      final sectionName = _isDirector
          ? (_selectedSection == 'الكل' ? 'كل الأقسام' : _selectedSection)
          : _teacherSection;

      _showMessage('تم حفظ الحضور والغياب لقسم $sectionName بنجاح');
    } catch (_) {
      if (!mounted) return;
      _showMessage('حدث خطأ أثناء حفظ الحضور');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _childAttendanceCard(Child child) {
    final status = _attendance[child.id] ?? 'حاضر';
    final isAbsent = status == 'غائب';
    final isPresent = !isAbsent;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isPresent
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    color: isPresent ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'القسم: ${child.section.isEmpty ? 'غير محدد' : child.section}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: status,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'حاضر',
                      child: Text(
                        'حاضر',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'غائب',
                      child: Text(
                        'غائب',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _attendance[child.id] = value;
                    });
                  },
                ),
              ],
            ),
            if (isAbsent) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _sendAbsenceWhatsApp(child),
                  icon: const Icon(Icons.send),
                  label: const Text('إرسال تنبيه غياب عبر واتساب'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = _filteredChildren;

    final presentCount = children
        .where((child) => (_attendance[child.id] ?? 'حاضر') == 'حاضر')
        .length;

    final absentCount = children.length - presentCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isDirector
                ? 'الحضور والغياب'
                : 'الحضور والغياب — $_teacherSection',
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadAttendance,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading || _isSaving ? null : _saveAttendance,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ الحضور'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : children.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _isDirector
                            ? 'لا يوجد أطفال مسجلون حاليًا'
                            : 'لا يوجد أطفال في قسم $_teacherSection.\n\nتأكد أن القسم المختار عند إضافة الطفل هو: $_teacherSection',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _selectDate,
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text('التاريخ: $_dateText'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_isDirector)
                                DropdownButtonFormField<String>(
                                  value: _selectedSection,
                                  decoration: const InputDecoration(
                                    labelText: 'القسم',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _sections.map((section) {
                                    return DropdownMenuItem(
                                      value: section,
                                      child: Text(section),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;

                                    setState(() {
                                      _selectedSection = value;
                                    });
                                  },
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'القسم الخاص بك: $_teacherSection',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _markAll('حاضر'),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('تسجيل الكل حاضر'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _markAll('غائب'),
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('تسجيل الكل غائب'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _summaryCard(
                            title: 'إجمالي الأطفال',
                            value: children.length.toString(),
                            color: Colors.blue,
                            icon: Icons.child_care,
                          ),
                          const SizedBox(width: 8),
                          _summaryCard(
                            title: 'الحاضرون',
                            value: presentCount.toString(),
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                          const SizedBox(width: 8),
                          _summaryCard(
                            title: 'الغائبون',
                            value: absentCount.toString(),
                            color: Colors.red,
                            icon: Icons.cancel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...children.map(_childAttendanceCard),
                      const SizedBox(height: 90),
                    ],
                  ),
      ),
    );
  }
}