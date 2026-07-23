enum UserRole {
  director,
  teacher,
  parent,
}

class AppUser {
  final String id;
  final String fullName;
  final String username;

  /// ⚠️ مُهمَل (Deprecated): كلمة المرور الصريحة لم تعد تُستعمل كمصدر حقيقة.
  /// SQLite (عبر passwordHash) هو المصدر الوحيد للحقيقة لبيانات تسجيل الدخول.
  /// أُبقي على هذا الحقل وجعلته اختيارياً (لم يعد required) فقط للحفاظ على
  /// التوافق مع الشاشات الحالية (main.dart, settings_page.dart) التي قد
  /// تبني AppUser بتمرير password. لا تعتمد عليه في أي منطق جديد.
  @Deprecated(
    'استعمل passwordHash. هذا الحقل موجود فقط للتوافق الخلفي أثناء مرحلة الترحيل.',
  )
  final String password;

  final String passwordHash;
  final UserRole role;
  final bool isActive;
  final bool isDeleted;
  final String section;
  final String? lastLogin;
  final String createdAt;
  final String updatedAt;

  AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    // لم يعد required: أي كود قديم يمرره سيستمر بالعمل،
    // وأي كود جديد يمكنه تجاهله بأمان.
    this.password = '',
    this.passwordHash = '',
    required this.role,
    this.isActive = true,
    this.isDeleted = false,
    this.section = '',
    this.lastLogin,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get isDirector => role == UserRole.director;

  bool get isTeacher => role == UserRole.teacher;

  bool get isParent => role == UserRole.parent;

  String get roleTitle {
    switch (role) {
      case UserRole.director:
        return 'المديرة';
      case UserRole.teacher:
        return 'المعلمة';
      case UserRole.parent:
        return 'ولي الأمر';
    }
  }

  /// نسخ الكائن مع تعديل حقول محددة فقط.
  /// أُضيفت لتقليل تكرار "إعادة بناء AppUser يدوياً" داخل UserService،
  /// ولا تمس أي توقيع موجود سابقاً (إضافة بحتة).
  AppUser copyWith({
    String? id,
    String? fullName,
    String? username,
    String? password,
    String? passwordHash,
    UserRole? role,
    bool? isActive,
    bool? isDeleted,
    String? section,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      // ignore: deprecated_member_use_from_same_package
      password: password ?? this.password,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      section: section ?? this.section,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'passwordHash': passwordHash,
      'role': role.name,
      'section': section,
      'isActive': isActive ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: '',
      passwordHash: map['passwordHash'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.teacher,
      ),
      isActive: (map['isActive'] as int? ?? 1) == 1,
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
      section: map['section'] as String? ?? '',
      lastLogin: map['lastLogin'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }
}