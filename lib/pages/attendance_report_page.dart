import 'package:flutter/material.dart';
import '../models/user.dart';
import '../attendance_report_service.dart';

class AttendanceReportPage extends StatefulWidget {
  final AppUser user;

  const AttendanceReportPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceReportPage> createState() =>
      _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  final AttendanceReportService _reportService = AttendanceReportService();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<ChildAttendanceReport> _reports = [];
  bool _isLoading = true;
  String _selectedSection = 'الكل';

  String get _monthText {
    final month = _selectedMonth.month.toString().padLeft(2, '0');
    return '${_selectedMonth.year}-$month';
  }

  List<String> get _sections {
    final sections = <String>{};

    for (final report in _reports) {
      if (report.section.trim().isNotEmpty) {
        sections.add(report.section.trim());
      }
    }

    final result = sections.toList();
    result.sort();

    return ['الكل', ...result];
  }

  List<ChildAttendanceReport> get _filteredReports {
    if (_selectedSection == 'الكل') {
      return _reports;
    }

    return _reports.where((report) {
      return report.section.trim() == _selectedSection;
    }).toList();
  }

  int get _totalPresentDays {
    return _filteredReports.fold(
      0,
      (total, report) => total + report.presentDays,
    );
  }

  int get _totalAbsentDays {
    return _filteredReports.fold(
      0,
      (total, report) => total + report.absentDays,
    );
  }

  double get _overallAttendanceRate {
    final totalDays = _totalPresentDays + _totalAbsentDays;

    if (totalDays == 0) return 0;

    return (_totalPresentDays / totalDays) * 100;
  }

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _reportService.getMonthlyReport(
  year: _selectedMonth.year,
  month: _selectedMonth.month,
);

final visibleReports = widget.user.isDirector
    ? reports
    : reports
        .where((r) => r.section.trim() == widget.user.section.trim())
        .toList();

      if (!mounted) return;

      setState(() {
        _reports = visibleReports;

        if (!_sections.contains(_selectedSection)) {
          _selectedSection = 'الكل';
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل التقرير: $error'),
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

    await _loadReport();
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
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 6,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 5),
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

  Color _rateColor(double rate) {
    if (rate >= 85) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _reportCard(ChildAttendanceReport report) {
    final rate = report.attendanceRate;
    final color = _rateColor(rate);

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
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.child_care,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.childName.isEmpty
                            ? 'طفل بدون اسم'
                            : report.childName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'القسم: ${report.section.isEmpty ? 'غير محدد' : report.section}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: rate / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _smallInfo(
                    icon: Icons.check_circle,
                    label: 'حاضر',
                    value: report.presentDays.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _smallInfo(
                    icon: Icons.cancel,
                    label: 'غائب',
                    value: report.absentDays.toString(),
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _smallInfo(
                    icon: Icons.calendar_today,
                    label: 'مسجل',
                    value: report.totalRecordedDays.toString(),
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السجل الشهري والتحليل'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadReport,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث التقرير',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadReport,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
                          ),
                        ),
                        title: const Text(
                          'الشهر المحدد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_monthText),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: _selectMonth,
                      ),
                    ),
                    const SizedBox(height: 10),
                   if (widget.user.isDirector)
  DropdownButtonFormField<String>(
    value: _selectedSection,
    decoration: const InputDecoration(
      labelText: 'فلترة حسب القسم',
      prefixIcon: Icon(Icons.groups),
      border: OutlineInputBorder(),
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
  ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _summaryCard(
                          icon: Icons.groups,
                          title: 'الأطفال',
                          value: _filteredReports.length.toString(),
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        _summaryCard(
                          icon: Icons.check_circle,
                          title: 'إجمالي الحضور',
                          value: _totalPresentDays.toString(),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _summaryCard(
                          icon: Icons.cancel,
                          title: 'إجمالي الغياب',
                          value: _totalAbsentDays.toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _rateColor(
                            _overallAttendanceRate,
                          ).withValues(alpha: 0.15),
                          child: Icon(
                            Icons.insights,
                            color: _rateColor(_overallAttendanceRate),
                          ),
                        ),
                        title: const Text(
                          'نسبة الحضور العامة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${_overallAttendanceRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _rateColor(_overallAttendanceRate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تحليل الأطفال',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_filteredReports.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'لا يوجد أطفال أو بيانات حضور في هذا الشهر',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ..._filteredReports.map(_reportCard),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}