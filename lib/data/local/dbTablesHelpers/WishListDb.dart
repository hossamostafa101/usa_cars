/*
import 'package:sqflite/sqflite.dart';

import '../AppDatabaseHelper.dart';
import 'dbModels/db_models.dart';

class Wishlistdb {
  final _dbHelper = AppDatabaseHelper();

  Future<void> insertItem(CartItem item) async {
    final db = await _dbHelper.database;
    await db.insert('wishlist', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CartItem>> getItems() async {
    final db = await _dbHelper.database;
    final result = await db.query('wishlist');
    return result.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> removeItem(int id) async {
    final db = await _dbHelper.database;
    await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _dbHelper.database;
    await db.delete('wishlist');
  }

  Future<List<CartItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final data = await db.query('wishlist');
    return data.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final db = await _dbHelper.database;
    await db.update('wishlist', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  }
}
*/
