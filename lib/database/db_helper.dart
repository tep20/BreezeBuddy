import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const String tableName = 'jurnal';

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
  String path = join(await databaseFactory.getDatabasesPath(), 'breezebuddy.db');
  return await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
    version: 1,
    onCreate: (db, version) {
      db.execute('CREATE TABLE jurnal(id INTEGER PRIMARY KEY AUTOINCREMENT, aktivitas TEXT, tanggal TEXT, cuaca TEXT)');
    },
  ));
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    Database dbClient = await db;
    return await dbClient.insert(tableName, data);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    Database dbClient = await db;
    return await dbClient.query(tableName, orderBy: "id DESC");
  }

  static Future<int> update(Map<String, dynamic> data) async {
    Database dbClient = await db;
    return await dbClient.update(tableName, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  static Future<int> delete(int id) async {
    Database dbClient = await db;
    return await dbClient.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}