import 'database/database_helper.dart';
import 'section_service.dart';

/// نتيجة تحليل نشاط الأقسام: أكثر وأقل قسم نشاطًا، مبنية على جدول
/// activities الذي تملكه ActivityService، بالإضافة لقائمة الأقسام
/// الحقيقية من SectionService (حتى يظهر قسم بلا أي نشاط كـ "الأقل
/// نشاطًا" بشكل صحيح، بدل أن يُستبعد لعدم وجود صف له في activities).
class SectionActivityInsight {
  final String? mostActiveSection;
  final int mostActiveSectionCount;
  final String? leastActiveSection;
  final int leastActiveSectionCount;
  final Map<String, int> countBySection;

  SectionActivityInsight({
    required this.mostActiveSection,
    required this.mostActiveSectionCount,
    required this.leastActiveSection,
    required this.leastActiveSectionCount,
    required this.countBySection,
  });
}

class ActivityService {
  final dbHelper = DatabaseHelper.instance;
  final SectionService _sectionService = SectionService();

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

  /// عدد الأنشطة لكل قسم — تُستخدم في لوحة القيادة لتحديد
  /// أكثر/أقل الأقسام نشاطًا ولرسم توزيع الأنشطة.
  /// استعلام تجميعي بسيط على جدول activities الموجود، بدون أي تعديل
  /// على مخطط قاعدة البيانات.
  Future<Map<String, int>> getActivityCountBySection() async {
    final db = await dbHelper.database;

    final rows = await db.rawQuery('''
      SELECT section, COUNT(*) AS total
      FROM activities
      WHERE section IS NOT NULL AND section != ''
      GROUP BY section
    ''');

    final result = <String, int>{};

    for (final row in rows) {
      final section = row['section'] as String? ?? '';
      final total = (row['total'] as num?)?.toInt() ?? 0;

      if (section.isNotEmpty) {
        result[section] = total;
      }
    }

    return result;
  }

  /// معرّفات الأطفال الذين لديهم صورة واحدة على الأقل موسومة باسمهم في
  /// جدول activity_photos (الذي تملكه هذه الخدمة). تُستخدم في لوحة
  /// القيادة لتحديد الأطفال الذين لا توجد لهم صور.
  Future<Set<String>> getPhotographedChildIds() async {
    final db = await dbHelper.database;

    final rows = await db.rawQuery('''
      SELECT DISTINCT childId FROM activity_photos
      WHERE childId IS NOT NULL
    ''');

    return rows
        .map((row) => row['childId'] as String?)
        .whereType<String>()
        .toSet();
  }

  /// أكثر وأقل قسم نشاطًا، مبنية فوق getActivityCountBySection مع تضمين
  /// كل الأقسام الحقيقية (حتى الأقسام بلا أي نشاط مسجَّل تظهر بشكل صحيح).
  Future<SectionActivityInsight> getMostAndLeastActiveSections() async {
    final countBySection = await getActivityCountBySection();
    final sections = await _sectionService.getAllSections();

    String? mostActiveSection;
    var mostActiveSectionCount = -1;
    String? leastActiveSection;
    var leastActiveSectionCount = 1 << 30;

    for (final section in sections) {
      final count = countBySection[section.name] ?? 0;

      if (count > mostActiveSectionCount) {
        mostActiveSectionCount = count;
        mostActiveSection = section.name;
      }
      if (count < leastActiveSectionCount) {
        leastActiveSectionCount = count;
        leastActiveSection = section.name;
      }
    }

    return SectionActivityInsight(
      mostActiveSection: mostActiveSection,
      mostActiveSectionCount: mostActiveSection == null ? 0 : mostActiveSectionCount,
      leastActiveSection: leastActiveSection,
      leastActiveSectionCount: leastActiveSection == null ? 0 : leastActiveSectionCount,
      countBySection: countBySection,
    );
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