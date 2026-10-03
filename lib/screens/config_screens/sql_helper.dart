import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static Database? _db;

  static Future<void> _initDB() async {
    if (_db != null) return;

    try {
      final path = join(await getDatabasesPath(), 'payments.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE payments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              nickname TEXT,
              number TEXT,
              expiryDate TEXT,
              cvv TEXT
            )
          ''');
        },
      );
    } catch (e) {
      print('Erro ao inicializar o banco de dados: $e');
    }
  }

  static Future<Database> getDatabase() async {
    if (_db == null) await _initDB();
    return _db!;
  }

  static Future<void> savePayment({
    required String name,
    required String nickname,
    required String number,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'payments',
        {
          'name': name,
          'nickname': nickname,
          'number': number,
          'expiryDate': expiryDate,
          'cvv': cvv,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Erro ao salvar pagamento: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final db = await getDatabase();
      return await db.query('payments');
    } catch (e) {
      print('Erro ao buscar pagamentos: $e');
      return [];
    }
  }

  static Future<void> deletePayment(int id) async {
    try {
      final db = await getDatabase();
      await db.delete(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Pagamento com ID $id deletado com sucesso!');
    } catch (e) {
      print('Erro ao deletar pagamento: $e');
    }
  }
}