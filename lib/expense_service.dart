import 'database/database_helper.dart';

class ExpenseService {
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

Future<List<Map<String, dynamic>>> getExpensesForMonth(
String month,
) async {
final db = await _dbHelper.database;


return db.query(
  'expenses',
  where: 'expenseDate LIKE ?',
  whereArgs: ['$month%'],
  orderBy: 'expenseDate DESC, id DESC',
);


}

Future<void> addExpense({
required String category,
required String title,
required double amount,
required String expenseDate,
String notes = '',
}) async {
final db = await _dbHelper.database;


await db.insert(
  'expenses',
  {
    'category': category,
    'title': title,
    'amount': amount,
    'expenseDate': expenseDate,
    'notes': notes,
  },
);


}

Future<void> updateExpense({
required int id,
required String category,
required String title,
required double amount,
required String expenseDate,
String notes = '',
}) async {
final db = await _dbHelper.database;


await db.update(
  'expenses',
  {
    'category': category,
    'title': title,
    'amount': amount,
    'expenseDate': expenseDate,
    'notes': notes,
  },
  where: 'id = ?',
  whereArgs: [id],
);


}

Future<void> deleteExpense(int id) async {
final db = await _dbHelper.database;


await db.delete(
  'expenses',
  where: 'id = ?',
  whereArgs: [id],
);


}

Future<double> getTotalExpensesForMonth(String month) async {
final db = await _dbHelper.database;


final result = await db.rawQuery(
  '''
  SELECT COALESCE(SUM(amount), 0) AS total
  FROM expenses
  WHERE expenseDate LIKE ?
  ''',
  ['$month%'],
);

final value = result.first['total'];

if (value is int) return value.toDouble();
if (value is double) return value;

return 0;


}

Future<Map<String, double>> getExpensesByCategoryForMonth(
String month,
) async {
final db = await _dbHelper.database;


final rows = await db.rawQuery(
  '''
  SELECT category, COALESCE(SUM(amount), 0) AS total
  FROM expenses
  WHERE expenseDate LIKE ?
  GROUP BY category
  ORDER BY total DESC
  ''',
  ['$month%'],
);

final result = <String, double>{};

for (final row in rows) {
  final category = row['category'] as String? ?? 'أخرى';
  final value = row['total'];

  if (value is int) {
    result[category] = value.toDouble();
  } else if (value is double) {
    result[category] = value;
  } else {
    result[category] = 0;
  }
}

return result;


}
}
