import '../database/database_helper.dart';
import '../models/child.dart';

class ChildService {
  final dbHelper = DatabaseHelper.instance;

  Future<void> addChild(Child child) async {
    final db = await dbHelper.database;

    await db.insert(
      'children',
      {
        'id': child.id,
        'firstName': child.firstName,
        'lastName': child.lastName,
        'gender': child.gender,
        'birthDate': child.birthDate,
        'section': child.section,
        'guardian': child.guardian,
        'fatherName': child.fatherName,
        'motherName': child.motherName,
        'phone1': child.phone1,
        'phone2': child.phone2,
        'address': child.address,
        'transport': child.transport,
        'allergies': child.allergies,
        'medicalFile': child.medicalFile,
        'notes': child.notes,
        'username': child.username,
        'password': child.password,
        'status': child.status,
        'imagePath': child.imagePath,
      },
    );
  }

 Future<List<Child>> getAllChildren() async {
  final db = await dbHelper.database;

  final rows = await db.query(
    'children',
    orderBy: 'id ASC',
  );

  return rows.map((row) {
    return Child(
      id: row['id'] as String,
      firstName: row['firstName'] as String? ?? '',
      lastName: row['lastName'] as String? ?? '',
      gender: row['gender'] as String? ?? '',
      birthDate: row['birthDate'] as String? ?? '',
      section: row['section'] as String? ?? '',
      guardian: row['guardian'] as String? ?? '',
      fatherName: row['fatherName'] as String? ?? '',
      motherName: row['motherName'] as String? ?? '',
      phone1: row['phone1'] as String? ?? '',
      phone2: row['phone2'] as String? ?? '',
      address: row['address'] as String? ?? '',
      transport: row['transport'] as String? ?? '',
      allergies: row['allergies'] as String? ?? '',
      medicalFile: row['medicalFile'] as String? ?? '',
      notes: row['notes'] as String? ?? '',
      username: row['username'] as String? ?? '',
      password: row['password'] as String? ?? '1234',
      status: row['status'] as String? ?? 'نشط',
      imagePath: row['imagePath'] as String? ?? '',
    );
  }).toList();
}
Future<List<Child>> getChildrenBySection(String section) async {
  final db = await dbHelper.database;

  final rows = await db.query(
    'children',
    where: 'section = ?',
    whereArgs: [section],
    orderBy: 'id ASC',
  );

  return rows.map((row) {
    return Child(
      id: row['id'] as String,
      firstName: row['firstName'] as String? ?? '',
      lastName: row['lastName'] as String? ?? '',
      gender: row['gender'] as String? ?? '',
      birthDate: row['birthDate'] as String? ?? '',
      section: row['section'] as String? ?? '',
      guardian: row['guardian'] as String? ?? '',
      fatherName: row['fatherName'] as String? ?? '',
      motherName: row['motherName'] as String? ?? '',
      phone1: row['phone1'] as String? ?? '',
      phone2: row['phone2'] as String? ?? '',
      address: row['address'] as String? ?? '',
      transport: row['transport'] as String? ?? '',
      allergies: row['allergies'] as String? ?? '',
      medicalFile: row['medicalFile'] as String? ?? '',
      notes: row['notes'] as String? ?? '',
      username: row['username'] as String? ?? '',
      password: row['password'] as String? ?? '1234',
      status: row['status'] as String? ?? 'نشط',
      imagePath: row['imagePath'] as String? ?? '',
    );
  }).toList();
}

  Future<void> updateChild(Child child) async {
    final db = await dbHelper.database;

    await db.update(
      'children',
      {
        'firstName': child.firstName,
        'lastName': child.lastName,
        'gender': child.gender,
        'birthDate': child.birthDate,
        'section': child.section,
        'guardian': child.guardian,
        'fatherName': child.fatherName,
        'motherName': child.motherName,
        'phone1': child.phone1,
        'phone2': child.phone2,
        'address': child.address,
        'transport': child.transport,
        'allergies': child.allergies,
        'medicalFile': child.medicalFile,
        'notes': child.notes,
        'username': child.username,
        'password': child.password,
        'status': child.status,
        'imagePath': child.imagePath,
      },
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }

  Future<void> deleteChild(String id) async {
    final db = await dbHelper.database;

    await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}