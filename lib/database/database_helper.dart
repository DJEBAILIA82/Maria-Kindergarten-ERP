import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('kingdom_maria.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _ensureTables,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS children(
id TEXT PRIMARY KEY,
firstName TEXT,
lastName TEXT,
gender TEXT,
birthDate TEXT,
section TEXT,
guardian TEXT,
fatherName TEXT,
motherName TEXT,
phone1 TEXT,
phone2 TEXT,
address TEXT,
transport TEXT,
allergies TEXT,
medicalFile TEXT,
notes TEXT,
username TEXT,
password TEXT,
status TEXT,
imagePath TEXT
)
''');

    await _createSectionsTable(db);
    await _createAttendanceTable(db);
    await _createSubscriptionsTable(db);
    await _createExpensesTable(db);
    await _createActivitiesTable(db);
    await _createActivityPhotosTable(db);
    await _createPhotosTable(db);
    await _createUsersTable(db);
    await _insertDefaultSections(db);
  }

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE children ADD COLUMN imagePath TEXT',
        );
      } catch (_) {}
    }

    if (oldVersion < 6) {
      try {
        await db.execute(
          'ALTER TABLE subscriptions ADD COLUMN otherFee REAL NOT NULL DEFAULT 0',
        );
      } catch (_) {}

      try {
        await db.execute(
          'ALTER TABLE subscriptions ADD COLUMN otherFeeName TEXT',
        );
      } catch (_) {}
    }

    await _createSectionsTable(db);
    await _createAttendanceTable(db);
    await _createSubscriptionsTable(db);
    await _createExpensesTable(db);
    await _createActivitiesTable(db);
    await _createActivityPhotosTable(db);
    await _createPhotosTable(db);
    await _createUsersTable(db);
    await _insertDefaultSections(db);
  }

  Future<void> _ensureTables(Database db) async {
    await _createSectionsTable(db);
    await _createAttendanceTable(db);
    await _createSubscriptionsTable(db);
    await _createExpensesTable(db);
    await _createActivitiesTable(db);
    await _createActivityPhotosTable(db);
    await _createPhotosTable(db);
    await _createUsersTable(db);

    try {
      await db.execute(
        'ALTER TABLE subscriptions ADD COLUMN otherFee REAL NOT NULL DEFAULT 0',
      );
    } catch (_) {}

    try {
      await db.execute(
        'ALTER TABLE subscriptions ADD COLUMN otherFeeName TEXT',
      );
    } catch (_) {}

    await _insertDefaultSections(db);
  }

  Future<void> _createSectionsTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS sections(
id TEXT PRIMARY KEY,
name TEXT NOT NULL,
teacherName TEXT,
ageGroup TEXT,
capacity INTEGER,
status TEXT
)
''');
  }

  Future<void> _createAttendanceTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS attendance(
id INTEGER PRIMARY KEY AUTOINCREMENT,
childId TEXT NOT NULL,
attendanceDate TEXT NOT NULL,
status TEXT NOT NULL,
notes TEXT,
UNIQUE(childId, attendanceDate)
)
''');
  }

  Future<void> _createSubscriptionsTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS subscriptions(
id INTEGER PRIMARY KEY AUTOINCREMENT,
childId TEXT NOT NULL,
subscriptionMonth TEXT NOT NULL,
monthlyFee REAL NOT NULL DEFAULT 8000,
transportFee REAL NOT NULL DEFAULT 2000,
otherFee REAL NOT NULL DEFAULT 0,
otherFeeName TEXT,
paidAmount REAL NOT NULL DEFAULT 0,
remainingAmount REAL NOT NULL DEFAULT 0,
notes TEXT,
UNIQUE(childId, subscriptionMonth)
)
''');
  }

  Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS expenses(
id INTEGER PRIMARY KEY AUTOINCREMENT,
category TEXT NOT NULL,
title TEXT NOT NULL,
amount REAL NOT NULL DEFAULT 0,
expenseDate TEXT NOT NULL,
notes TEXT
)
''');
  }
    Future<void> _createActivitiesTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS activities(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
description TEXT,
activityDate TEXT NOT NULL,
section TEXT,
createdBy TEXT
)
''');
  }

  Future<void> _createActivityPhotosTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS activity_photos(
id INTEGER PRIMARY KEY AUTOINCREMENT,
activityId INTEGER NOT NULL,
childId TEXT,
imagePath TEXT NOT NULL,
faceDetected INTEGER DEFAULT 0,
createdAt TEXT
)
''');
  }

  Future<void> _createPhotosTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS photos(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT,
description TEXT,
localImagePath TEXT NOT NULL,
section TEXT,
uploadedBy TEXT,
uploaderName TEXT,
createdAt TEXT,
status TEXT NOT NULL DEFAULT 'pending',
approvedBy TEXT,
approvedAt TEXT
)
''');
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS users(
id TEXT PRIMARY KEY,
fullName TEXT NOT NULL,
username TEXT NOT NULL UNIQUE,
passwordHash TEXT NOT NULL,
role TEXT NOT NULL,
section TEXT DEFAULT '',
isActive INTEGER NOT NULL DEFAULT 1,
isDeleted INTEGER NOT NULL DEFAULT 0,
lastLogin TEXT,
createdAt TEXT NOT NULL,
updatedAt TEXT NOT NULL
)
''');
  }

  Future<void> _insertDefaultSections(Database db) async {
  final sections = [
    {
      'id': 'SEC-0001',
      'name': 'قسم الرضع',
      'teacherName': '',
      'ageGroup': 'من 3 أشهر إلى سنتين',
      'capacity': 20,
      'status': 'نشط',
    },
    {
      'id': 'SEC-0002',
      'name': 'قسم ما قبل التمهيدي',
      'teacherName': '',
      'ageGroup': 'من سنتين إلى 3 سنوات',
      'capacity': 25,
      'status': 'نشط',
    },
    {
      'id': 'SEC-0003',
      'name': 'قسم تمهيدي',
      'teacherName': '',
      'ageGroup': 'من 3 إلى 4 سنوات',
      'capacity': 25,
      'status': 'نشط',
    },
    {
      'id': 'SEC-0004',
      'name': 'قسم تحضيري',
      'teacherName': '',
      'ageGroup': 'من 4 إلى 5 سنوات',
      'capacity': 25,
      'status': 'نشط',
    },
  ];

  for (final section in sections) {
    await db.insert(
      'sections',
      section,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}

 Future<void> close() async {
  final db = await instance.database;
  await db.close();
}
}