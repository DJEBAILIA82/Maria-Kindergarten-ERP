import '../database/database_helper.dart';

class ActivityService {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getActivities() async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'activities',
      orderBy: 'id DESC',
    );

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<int> createActivity({
    required String title,
    required String description,
    required String section,
    required DateTime date,
  }) async {
    final db = await dbHelper.database;

    return db.insert('activities', {
      'title': title,
      'description': description,
      'activityDate': date.toIso8601String(),
      'section': section,
    });
  }

  Future<void> deleteActivity(dynamic id) async {
    final db = await dbHelper.database;

    // نحذف صور النشاط أولًا لتفادي بقاء صور يتيمة بدون نشاط
    await db.delete(
      'activity_photos',
      where: 'activityId = ?',
      whereArgs: [id],
    );

    await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPhotos(dynamic activityId) async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'activity_photos',
      where: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'id DESC',
    );

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<int> addPhoto({
    required dynamic activityId,
    required String imagePath,
    String? childId,
  }) async {
    final db = await dbHelper.database;

    return db.insert('activity_photos', {
      'activityId': activityId,
      'childId': childId,
      'imagePath': imagePath,
      'faceDetected': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deletePhoto(dynamic id) async {
    final db = await dbHelper.database;

    await db.delete(
      'activity_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}