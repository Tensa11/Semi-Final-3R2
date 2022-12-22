import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Sqflite {
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'flutterjunction.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<int> createItem(String? title, String? descrption) async {
    final db = await Sqflite.db();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  // Read
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await Sqflite.db();
    return db.query('items', orderBy: "id");
  }
  // Get
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await Sqflite.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }
  // Update
  static Future<int> updateItem(
      int id, String title, String? descrption) async {
    final db = await Sqflite.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };
    final result =
    await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await Sqflite.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}