import '../database/database_helper.dart';
import '../models/photo.dart';

/// واجهة مجرّدة لتخزين الصور. هذا هو المكان الوحيد اللي لازم يتغيّر
/// لو حبينا مستقبلاً نستبدل التخزين المحلي بـ Firestore أو أي مصدر آخر —
/// بدون ما نلمس أي صفحة (Gallery/Upload/Pending) ولا منطق الصلاحيات.
abstract class PhotoRepository {
  Future<void> addPhoto(Photo photo);
  Future<void> updatePhoto(Photo photo);
  Future<void> deletePhoto(String id);
  Future<List<Photo>> getApprovedPhotos();
  Future<List<Photo>> getPendingPhotos();
  Future<List<Photo>> getPhotosBySection(String section);
  Future<List<Photo>> getAllPhotos();
  Future<void> approvePhoto({
    required String id,
    required String approvedByUserId,
  });
  Future<void> rejectPhoto({
    required String id,
    required String approvedByUserId,
  });
}

/// التنفيذ المحلي الحالي: يخزّن بيانات الصور في جدول SQLite محلي
/// (نفس أسلوب activity_photos تمامًا)، ويحتفظ بمسار الصورة على الجهاز فقط.
class LocalPhotoRepository implements PhotoRepository {
  final _dbHelper = DatabaseHelper.instance;

  static const String _table = 'photos';

  List<Photo> _mapRows(List<Map<String, Object?>> rows) {
    return rows.map((row) {
      return Photo.fromMap(
        row['id'].toString(),
        Map<String, dynamic>.from(row),
      );
    }).toList();
  }

  @override
  Future<void> addPhoto(Photo photo) async {
    final db = await _dbHelper.database;
    await db.insert(_table, photo.toMap());
  }

  @override
  Future<void> updatePhoto(Photo photo) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [int.tryParse(photo.id)],
    );
  }

  @override
  Future<void> deletePhoto(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  @override
  Future<List<Photo>> getApprovedPhotos() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'status = ?',
      whereArgs: ['approved'],
      orderBy: 'createdAt DESC',
    );
    return _mapRows(rows);
  }

  @override
  Future<List<Photo>> getPendingPhotos() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'createdAt DESC',
    );
    return _mapRows(rows);
  }

  @override
  Future<List<Photo>> getPhotosBySection(String section) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'section = ?',
      whereArgs: [section],
      orderBy: 'createdAt DESC',
    );
    return _mapRows(rows);
  }

  @override
  Future<List<Photo>> getAllPhotos() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return _mapRows(rows);
  }

  @override
  Future<void> approvePhoto({
    required String id,
    required String approvedByUserId,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {
        'status': 'approved',
        'approvedBy': approvedByUserId,
        'approvedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }

  @override
  Future<void> rejectPhoto({
    required String id,
    required String approvedByUserId,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      {
        'status': 'rejected',
        'approvedBy': approvedByUserId,
        'approvedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
  }
}

/// خدمة إدارة صور معرض الروضة.
/// نفس الواجهة العامة تمامًا كالنسخة السابقة (Firestore)، بحيث لا تحتاج
/// أي صفحة (GalleryPage / UploadPhotoPage / PendingPhotosPage) أي تعديل.
/// التخزين الفعلي محلي حاليًا (LocalPhotoRepository)؛ لاستبداله لاحقًا
/// بـ Firestore، يكفي تمرير repository آخر هنا فقط.
class PhotoService {
  final PhotoRepository _repository;

  PhotoService({PhotoRepository? repository})
      : _repository = repository ?? LocalPhotoRepository();

  Future<void> addPhoto(Photo photo) => _repository.addPhoto(photo);

  Future<void> updatePhoto(Photo photo) => _repository.updatePhoto(photo);

  Future<void> deletePhoto(String id) => _repository.deletePhoto(id);

  Future<List<Photo>> getApprovedPhotos() => _repository.getApprovedPhotos();

  Future<List<Photo>> getPendingPhotos() => _repository.getPendingPhotos();

  Future<List<Photo>> getPhotosBySection(String section) =>
      _repository.getPhotosBySection(section);

  Future<List<Photo>> getAllPhotos() => _repository.getAllPhotos();

  Future<void> approvePhoto({
    required String id,
    required String approvedByUserId,
  }) =>
      _repository.approvePhoto(id: id, approvedByUserId: approvedByUserId);

  Future<void> rejectPhoto({
    required String id,
    required String approvedByUserId,
  }) =>
      _repository.rejectPhoto(id: id, approvedByUserId: approvedByUserId);
}