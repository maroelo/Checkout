import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'shopping_list.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shopping_lists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            listId INTEGER NOT NULL,
            FOREIGN KEY (listId) REFERENCES shopping_lists (id) ON DELETE CASCADE
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertList(String name) async {
    final db = await database;
    return db.insert('shopping_lists', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getLists() async {
    final db = await database;
    return db.query('shopping_lists');
  }

  Future<int> deleteList(int id) async {
    final db = await database;
    return db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertProduct(String name, int quantity, int listId) async {
    final db = await database;
    return db.insert('products', {
      'name': name,
      'quantity': quantity,
      'listId': listId,
    });
  }

  Future<List<Map<String, dynamic>>> getProducts(int listId) async {
    final db = await database;
    return db.query('products', where: 'listId = ?', whereArgs: [listId]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
