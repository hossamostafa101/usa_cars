import 'package:sqflite/sqflite.dart';

import '../AppDatabaseHelper.dart';
import 'dbModels/db_models.dart';

class NotificationDb {
  final _dbHelper = AppDatabaseHelper();

  Future<void> insertItem(NotificationItem item) async {
    final db = await _dbHelper.database;
    await db.insert('notify', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationItem>> getItems() async {
    final db = await _dbHelper.database;
    final result = await db.query('notify');
    return result.map((e) => NotificationItem.fromMap(e)).toList();
  }

  Future<void> removeItem(int id) async {
    final db = await _dbHelper.database;
    await db.delete('notify', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _dbHelper.database;
    await db.delete('notify');
  }

  Future<List<NotificationItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final data = await db.query('notify');
    return data.map((e) => NotificationItem.fromMap(e)).toList();
  }

  // Future<void> updateQuantity(int id, int quantity) async {
  //   final db = await _dbHelper.database;
  //   await db.update('notify', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  // }
}
