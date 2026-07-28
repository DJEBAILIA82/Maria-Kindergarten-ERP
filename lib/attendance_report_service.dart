import 'database/database_helper.dart';

class ChildAttendanceReport {
  final String childId;
  final String childName;
  final String section;
  final int presentDays;
  final int absentDays;

  ChildAttendanceReport({
    required this.childId,
    required this.childName,
    required this.section,
    required this.presentDays,
    required this.absentDays,
  });

  int get totalRecordedDays => presentDays + absentDays;

  double get attendanceRate {
    if (totalRecordedDays == 0) return 0;
    return (presentDays / totalRecordedDays) * 100;
  }
}

class AttendanceReportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ChildAttendanceReport>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final db = await _dbHelper.database;

    final monthText = month.toString().padLeft(2, '0');
    final datePrefix = '$year-$monthText-';

    final rows = await db.rawQuery(
      '''
      SELECT
        children.id AS childId,
        children.firstName AS firstName,
        children.lastName AS lastName,
        children.section AS section,
        SUM(
          CASE
            WHEN attendance.status = 'حاضر' THEN 1
            ELSE 0
          END
        ) AS presentDays,
        SUM(
          CASE
            WHEN attendance.status = 'غائب' THEN 1
            ELSE 0
          END
        ) AS absentDays
      FROM children
      LEFT JOIN attendance
        ON children.id = attendance.childId
        AND attendance.attendanceDate LIKE ?
      GROUP BY children.id
      ORDER BY absentDays DESC, firstName ASC
      ''',
      ['$datePrefix%'],
    );

    return rows.map((row) {
      final firstName = row['firstName'] as String? ?? '';
      final lastName = row['lastName'] as String? ?? '';

      return ChildAttendanceReport(
        childId: row['childId'] as String? ?? '',
        childName: '$firstName $lastName'.trim(),
        section: row['section'] as String? ?? '',
        presentDays: (row['presentDays'] as num?)?.toInt() ?? 0,
        absentDays: (row['absentDays'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  /// قاعدة العمل: "غياب متكرر" = عدد أيام الغياب المسجّلة خلال الشهر
  /// أكبر من أو يساوي [minAbsentDays] (افتراضيًا 3). تعيش هذه القاعدة هنا
  /// لأن AttendanceReportService هو المالك المنطقي لبيانات الحضور/الغياب،
  /// وتُبنى فوق getMonthlyReport الموجودة أصلاً دون أي استعلام SQL جديد.
  Future<List<ChildAttendanceReport>> getFrequentAbsentees({
    required int year,
    required int month,
    int minAbsentDays = 3,
  }) async {
    final report = await getMonthlyReport(year: year, month: month);

    return report
        .where((entry) => entry.absentDays >= minAbsentDays)
        .toList();
  }
}