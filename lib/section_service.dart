import 'database/database_helper.dart';
import 'models/section.dart';

class SectionService {
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

Future<List<KindergartenSection>> getAllSections() async {
final db = await _dbHelper.database;

final rows = await db.query(
  'sections',
  orderBy: 'name ASC',
);

return rows
    .map((row) => KindergartenSection.fromMap(row))
    .toList();

}

Future<void> addSection(KindergartenSection section) async {
final db = await _dbHelper.database;

await db.insert(
  'sections',
  section.toMap(),
);

}

Future<void> updateSection(KindergartenSection section) async {
final db = await _dbHelper.database;

await db.update(
  'sections',
  section.toMap(),
  where: 'id = ?',
  whereArgs: [section.id],
);

}

Future<void> deleteSection(String id) async {
final db = await _dbHelper.database;

await db.delete(
  'sections',
  where: 'id = ?',
  whereArgs: [id],
);

}

Future<String> generateSectionId() async {
final sections = await getAllSections();
final number = sections.length + 1;

return 'SEC-${number.toString().padLeft(4, '0')}';

}
}
