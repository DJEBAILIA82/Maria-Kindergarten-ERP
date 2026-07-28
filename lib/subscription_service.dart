import 'package:sqflite/sqflite.dart';

import 'database/database_helper.dart';

class SubscriptionService {
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

Future<void> saveSubscription({
required String childId,
required String subscriptionMonth,
double monthlyFee = 8000,
double transportFee = 2000,
double otherFee = 0,
String otherFeeName = '',
double paidAmount = 0,
String notes = '',
}) async {
final db = await _dbHelper.database;


final totalAmount = monthlyFee + transportFee + otherFee;
final remainingAmount = totalAmount - paidAmount;

await db.insert(
  'subscriptions',
  {
    'childId': childId,
    'subscriptionMonth': subscriptionMonth,
    'monthlyFee': monthlyFee,
    'transportFee': transportFee,
    'otherFee': otherFee,
    'otherFeeName': otherFeeName,
    'paidAmount': paidAmount,
    'remainingAmount': remainingAmount < 0 ? 0 : remainingAmount,
    'notes': notes,
  },
  conflictAlgorithm: ConflictAlgorithm.replace,
);


}

Future<Map<String, dynamic>?> getSubscription({
required String childId,
required String subscriptionMonth,
}) async {
final db = await _dbHelper.database;


final rows = await db.query(
  'subscriptions',
  where: 'childId = ? AND subscriptionMonth = ?',
  whereArgs: [childId, subscriptionMonth],
  limit: 1,
);

if (rows.isEmpty) return null;

return Map<String, dynamic>.from(rows.first);


}

Future<Map<String, Map<String, dynamic>>> getSubscriptionsForMonth(
String subscriptionMonth,
) async {
final db = await _dbHelper.database;


final rows = await db.query(
  'subscriptions',
  where: 'subscriptionMonth = ?',
  whereArgs: [subscriptionMonth],
);

final result = <String, Map<String, dynamic>>{};

for (final row in rows) {
  final childId = row['childId']?.toString() ?? '';

  if (childId.isNotEmpty) {
    result[childId] = Map<String, dynamic>.from(row);
  }
}

return result;


}

Future<Map<String, double>> getMonthSummary(
String subscriptionMonth,
) async {
final db = await _dbHelper.database;


final rows = await db.rawQuery(
  '''
  SELECT
    COALESCE(SUM(monthlyFee + transportFee + otherFee), 0) AS requiredAmount,
    COALESCE(SUM(paidAmount), 0) AS paidAmount,
    COALESCE(SUM(remainingAmount), 0) AS remainingAmount
  FROM subscriptions
  WHERE subscriptionMonth = ?
  ''',
  [subscriptionMonth],
);

final row = rows.first;

double readAmount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

return {
  'requiredAmount': readAmount(row['requiredAmount']),
  'paidAmount': readAmount(row['paidAmount']),
  'remainingAmount': readAmount(row['remainingAmount']),
};


}

Future<int> getFullyPaidCount(String subscriptionMonth) async {
final db = await _dbHelper.database;


final result = await db.rawQuery(
  '''
  SELECT COUNT(*) AS total
  FROM subscriptions
  WHERE subscriptionMonth = ?
    AND remainingAmount <= 0
  ''',
  [subscriptionMonth],
);

final value = result.first['total'];

if (value is int) return value;
if (value is num) return value.toInt();

return int.tryParse(value?.toString() ?? '') ?? 0;


}

/// عدد الاشتراكات "المتأخرة" لشهر مُعيّن: اشتراك مسجَّل فعليًا
/// (له صف في الجدول) ومبلغه المتبقي أكبر من صفر — نفس التعريف
/// المستخدم في late_subscriptions_page.dart (لا يشمل الأطفال الذين
/// لا يوجد لهم اشتراك مسجَّل أصلاً لهذا الشهر؛ تلك فئة منفصلة).
Future<int> getLateSubscriptionsCount(String subscriptionMonth) async {
final db = await _dbHelper.database;

final result = await db.rawQuery(
  '''
  SELECT COUNT(*) AS total
  FROM subscriptions
  WHERE subscriptionMonth = ?
    AND remainingAmount > 0
  ''',
  [subscriptionMonth],
);

final value = result.first['total'];

if (value is int) return value;
if (value is num) return value.toInt();

return int.tryParse(value?.toString() ?? '') ?? 0;
}

Future<void> deleteSubscription({
required String childId,
required String subscriptionMonth,
}) async {
final db = await _dbHelper.database;


await db.delete(
  'subscriptions',
  where: 'childId = ? AND subscriptionMonth = ?',
  whereArgs: [childId, subscriptionMonth],
);


}
}
