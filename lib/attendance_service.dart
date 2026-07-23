import 'package:sqflite/sqflite.dart';
import 'database/database_helper.dart';

class AttendanceService {
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

Future<void> saveAttendance({
required String childId,
required String attendanceDate,
required String status,
String notes = '',
}) async {
final db = await _dbHelper.database;

await db.insert(
  'attendance',
  {
    'childId': childId,
    'attendanceDate': attendanceDate,
    'status': status,
    'notes': notes,
  },
  conflictAlgorithm: ConflictAlgorithm.replace,
);

}

Future<Map<String, String>> getAttendanceForDate(
String attendanceDate,
) async {
final db = await _dbHelper.database;

final rows = await db.query(
  'attendance',
  where: 'attendanceDate = ?',
  whereArgs: [attendanceDate],
);

final result = <String, String>{};

for (final row in rows) {
  final childId = row['childId'] as String? ?? '';
  final status = row['status'] as String? ?? 'حاضر';

  if (childId.isNotEmpty) {
    result[childId] = status;
  }
}

return result;

}

Future<Map<String, int>> getAttendanceSummary(
String attendanceDate,
) async {
final db = await _dbHelper.database;

final rows = await db.rawQuery(
  '''
  SELECT status, COUNT(*) AS total
  FROM attendance
  WHERE attendanceDate = ?
  GROUP BY status
  ''',
  [attendanceDate],
);

int present = 0;
int absent = 0;

for (final row in rows) {
  final status = row['status'] as String? ?? '';
  final total = row['total'] as int? ?? 0;

  if (status == 'حاضر') {
    present = total;
  } else if (status == 'غائب') {
    absent = total;
  }
}

return {
  'حاضر': present,
  'غائب': absent,
};

}

Future<int> getPresentCount(String attendanceDate) async {
final summary = await getAttendanceSummary(attendanceDate);
return summary['حاضر'] ?? 0;
}

Future<int> getAbsentCount(String attendanceDate) async {
final summary = await getAttendanceSummary(attendanceDate);
return summary['غائب'] ?? 0;
}
}
