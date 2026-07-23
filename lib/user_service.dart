import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';

import 'database/database_helper.dart';
import 'models/user.dart';

/// UserService
/// -----------
/// المصدر الوحيد للحقيقة (Source of Truth) هو SQLite.
///
/// `_cache` هو مجرد نسخة مؤقتة في الذاكرة تُستعمل *فقط* لأن `getAllUsers()`
/// دالة متزامنة (sync) في الشاشات الحالية (main.dart, settings_page.dart)
/// ولا يمكن تغيير توقيعها إلى Future دون تعديل تلك الشاشات.
///
/// كل عملية كتابة (add/update/reset/setActive) تُنفَّذ أولاً على SQLite،
/// ثم يُحدَّث الـ Cache بنفس النتيجة القادمة من قاعدة البيانات — لا العكس.
/// أي قراءة يُفترض أن تعكس ما هو مخزّن فعلياً في SQLite بعد أي عملية كتابة.
class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  static const Uuid _uuid = Uuid();

  /// Cache متزامن للقراءة السريعة عبر getAllUsers().
  /// لا يُعتبر مصدر حقيقة: يُعاد بناؤه دائماً من SQLite.
  final List<AppUser> _cache = [];
  bool _isLoaded = false;

  String _now() => DateTime.now().toIso8601String();

  /// يضمن تحميل الـ Cache من SQLite مرة واحدة على الأقل.
  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    await _loadFromDatabase();
  }

  /// إعادة تحميل الـ Cache بالكامل من SQLite (المصدر الوحيد للحقيقة).
  Future<void> _loadFromDatabase() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('users', where: 'isDeleted = 0');

    _cache
      ..clear()
      ..addAll(rows.map((row) => AppUser.fromMap(row)));

    _isLoaded = true;
  }

  /// دالة إضافية (لا تكسر أي شيء): تسمح لأي كود جديد بإجبار إعادة
  /// المزامنة مع SQLite عند الحاجة (مثلاً بعد تعديل خارجي لقاعدة البيانات).
  /// غير مستعملة إلزامياً من قبل الشاشات الحالية.
  Future<void> refreshFromDatabase() => _loadFromDatabase();

  /// يحدّث عنصراً واحداً في الـ Cache بعد أن يكون قد كُتب في SQLite بالفعل.
  void _upsertCache(AppUser user) {
    final index = _cache.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      _cache.add(user);
    } else {
      _cache[index] = user;
    }
  }

  Future<void> createDefaultDirector() async {
    await _ensureLoaded();

    await _addUserIfNotExists(
      AppUser(
        id: '',
        fullName: 'مريم جبايلية',
        username: 'mariam',
        password: '1234',
        role: UserRole.director,
        isActive: true,
      ),
    );

    await _addUserIfNotExists(
      AppUser(
        id: '',
        fullName: 'قسم الرضع',
        username: 'الرضع',
        password: '1234',
        role: UserRole.teacher,
        section: 'الرضع',
        isActive: true,
      ),
    );

    await _addUserIfNotExists(
      AppUser(
        id: '',
        fullName: 'قسم قبل التمهيدي',
        username: 'قبل التمهيدي',
        password: '1234',
        role: UserRole.teacher,
        section: 'قبل التمهيدي',
        isActive: true,
      ),
    );

    await _addUserIfNotExists(
      AppUser(
        id: '',
        fullName: 'قسم التمهيدي',
        username: 'التمهيدي',
        password: '1234',
        role: UserRole.teacher,
        section: 'التمهيدي',
        isActive: true,
      ),
    );

    await _addUserIfNotExists(
      AppUser(
        id: '',
        fullName: 'قسم التحضيري',
        username: 'التحضيري',
        password: '1234',
        role: UserRole.teacher,
        section: 'التحضيري',
        isActive: true,
      ),
    );
  }

  Future<void> _addUserIfNotExists(AppUser user) async {
    final exists = _cache.any(
      (item) => item.username.toLowerCase() == user.username.toLowerCase(),
    );

    if (!exists) {
      await addUser(user);
    }
  }

  Future<AppUser?> login({
    required String username,
    required String password,
  }) async {
    await _ensureLoaded();

    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    for (final user in _cache) {
      if (user.username.toLowerCase() == cleanUsername &&
          user.isActive &&
          BCrypt.checkpw(cleanPassword, user.passwordHash)) {
        final now = _now();

        final db = await DatabaseHelper.instance.database;
        await db.update(
          'users',
          {'lastLogin': now, 'updatedAt': now},
          where: 'id = ?',
          whereArgs: [user.id],
        );

        final updatedUser = user.copyWith(lastLogin: now, updatedAt: now);
        _upsertCache(updatedUser);

        return updatedUser;
      }
    }

    return null;
  }

  /// ⚠️ لا تغيّر هذا التوقيع: تعتمد عليه شاشات حالية (main.dart, settings_page.dart).
  /// تبقى متزامنة (sync) عمداً وتقرأ من الـ Cache الداخلي فقط،
  /// بينما SQLite يبقى مصدر الحقيقة الفعلي الذي يُحدَّث منه هذا الـ Cache.
  List<AppUser> getAllUsers() {
    return List<AppUser>.from(_cache);
  }

  Future<void> addUser(AppUser user) async {
    await _ensureLoaded();

    final usernameExists = _cache.any(
      (item) => item.username.toLowerCase() == user.username.toLowerCase(),
    );

    if (usernameExists) {
      throw Exception('اسم المستخدم مستعمل بالفعل');
    }

    final db = await DatabaseHelper.instance.database;
    final now = _now();

    final newUser = AppUser(
      id: _uuid.v4(),
      fullName: user.fullName,
      username: user.username,
      password: '',
      // ignore: deprecated_member_use_from_same_package
      passwordHash: BCrypt.hashpw(user.password, BCrypt.gensalt()),
      role: user.role,
      isActive: user.isActive,
      isDeleted: false,
      section: user.section,
      lastLogin: null,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('users', newUser.toMap());
    _upsertCache(newUser);
  }

  Future<void> updateUser(AppUser updatedUser) async {
    await _ensureLoaded();

    final index = _cache.indexWhere((user) => user.id == updatedUser.id);

    if (index == -1) {
      throw Exception('لم يتم العثور على المستخدم');
    }

    final usernameExists = _cache.any(
      (item) =>
          item.id != updatedUser.id &&
          item.username.toLowerCase() == updatedUser.username.toLowerCase(),
    );

    if (usernameExists) {
      throw Exception('اسم المستخدم مستعمل بالفعل');
    }

    final existing = _cache[index];
    final db = await DatabaseHelper.instance.database;
    final now = _now();

    // ignore: deprecated_member_use_from_same_package
    final newPasswordHash = updatedUser.password.isNotEmpty
        // ignore: deprecated_member_use_from_same_package
        ? BCrypt.hashpw(updatedUser.password, BCrypt.gensalt())
        : existing.passwordHash;

    final savedUser = existing.copyWith(
      fullName: updatedUser.fullName,
      username: updatedUser.username,
      password: '',
      passwordHash: newPasswordHash,
      role: updatedUser.role,
      isActive: updatedUser.isActive,
      section: updatedUser.section,
      updatedAt: now,
    );

    await db.update(
      'users',
      savedUser.toMap(),
      where: 'id = ?',
      whereArgs: [existing.id],
    );

    _upsertCache(savedUser);
  }

  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    await _ensureLoaded();

    final index = _cache.indexWhere((user) => user.id == userId);

    if (index == -1) {
      throw Exception('لم يتم العثور على المستخدم');
    }

    final user = _cache[index];
    final db = await DatabaseHelper.instance.database;
    final now = _now();
    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    await db.update(
      'users',
      {'passwordHash': newHash, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [userId],
    );

    _upsertCache(user.copyWith(passwordHash: newHash, updatedAt: now));
  }

  Future<void> setUserActive({
    required String userId,
    required bool isActive,
  }) async {
    await _ensureLoaded();

    final index = _cache.indexWhere((user) => user.id == userId);

    if (index == -1) {
      throw Exception('لم يتم العثور على المستخدم');
    }

    final user = _cache[index];
    final db = await DatabaseHelper.instance.database;
    final now = _now();

    await db.update(
      'users',
      {'isActive': isActive ? 1 : 0, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [userId],
    );

    _upsertCache(user.copyWith(isActive: isActive, updatedAt: now));
  }
}