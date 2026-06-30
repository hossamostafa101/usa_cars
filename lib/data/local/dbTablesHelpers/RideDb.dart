import 'package:sqflite/sqflite.dart';

import '../AppDatabaseHelper.dart';
import 'dbModels/db_models.dart';

class RideDb {
  final _dbHelper = AppDatabaseHelper();

  Future<void> insertItem(RideItem item) async {
    final db = await _dbHelper.database;
    await db.insert('ride', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RideItem>> getItems() async {
    final db = await _dbHelper.database;
    final result = await db.query('ride');
    return result.map((e) => RideItem.fromMap(e)).toList();
  }

  Future<void> removeItem(int id) async {
    final db = await _dbHelper.database;
    await db.delete('ride', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _dbHelper.database;
    await db.delete('ride');
  }

  Future<List<RideItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final data = await db.query('ride');
    return data.map((e) => RideItem.fromMap(e)).toList();
  }

  // Future<void> updateQuantity(int id, int quantity) async {
  //   final db = await _dbHelper.database;
  //   await db.update('notify', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  // }
}
