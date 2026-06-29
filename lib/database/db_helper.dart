import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String tableName = 'jurnal';

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'breezebuddy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE jurnal(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          aktivitas TEXT, 
          detail TEXT, 
          kategori TEXT, 
          tanggal TEXT, 
          cuaca TEXT
        )
      ''');
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await initDB(); // Pastikan selalu ambil instance baru
    return await db.insert(tableName, data);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await initDB();
    return await db.query(tableName, orderBy: "id DESC");
  }

  static Future<int> update(Map<String, dynamic> data) async {
    final db = await initDB();
    return await db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  static Future<int> delete(int id) async {
    final db = await initDB();
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
