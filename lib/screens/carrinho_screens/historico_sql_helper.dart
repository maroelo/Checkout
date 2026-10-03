import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoricoSQLHelper {
  static Database? _db;

  // Método para inicializar o banco de dados
  static Future<void> _initDB() async {
    if (_db != null) return;

    try {
      final path = join(await getDatabasesPath(), 'historico_compras.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE historico (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              data TEXT,
              itens TEXT,
              valor_total REAL
            )
          ''');
        },
      );
    } catch (e) {
      print('Erro ao inicializar o banco de dados: $e');
    }
  }

  // Método para obter o banco de dados
  static Future<Database> getDatabase() async {
    if (_db == null) await _initDB();
    return _db!;
  }

  // Método para salvar uma compra no histórico
  static Future<void> salvarCompra({
    required String data,
    required String itens,
    required double valorTotal,
  }) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'historico',
        {
          'data': data,
          'itens': itens,
          'valor_total': valorTotal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Erro ao salvar compra: $e');
    }
  }

  // Método para obter todas as compras do histórico
  static Future<List<Map<String, dynamic>>> obterCompras() async {
    try {
      final db = await getDatabase();
      return await db.query('historico', orderBy: 'id DESC');
    } catch (e) {
      print('Erro ao obter compras: $e');
      return [];
    }
  }

  // Método para deletar uma compra específica
  static Future<void> deletarCompra(int id) async {
    try {
      final db = await getDatabase();
      await db.delete(
        'historico',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar compra: $e');
    }
  }

  // Método para limpar todo o histórico de compras
  static Future<void> limparHistorico() async {
    try {
      final db = await getDatabase();
      await db.delete('historico');
    } catch (e) {
      print('Erro ao limpar histórico: $e');
    }
  }
}
