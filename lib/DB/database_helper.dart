// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseHelperSessions {
// class DatabaseHelper {
  // static Database? _database;
  // static const _tableName = 'sessionsTable';

  // Future<Database> get database async {
  //   if (_database != null) return _database!;
  //   _database = await _initDatabase();
  //   return _database!;
  // }

  // Future<Database> _initDatabase() async {
  //   var databasesPath = await getDatabasesPath();

  //   String path = join(databasesPath, 'SaladOfAchievement.db');
  //   return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
  //     await db.execute("CREATE TABLE $_tableName (Id INTEGER PRIMARY KEY, duration TEXT, Time TEXT, Type TEXT)");
  //   });
  // }

  // Future<List<Map<String, dynamic>>> getData() async {
  //   final db = await database;
  //   return await db.rawQuery('SELECT * FROM $_tableName');
  // }

  // Future<void> addData(String duration, String time, String type) async {
  //   final db = await database;
  //   await db.rawInsert('INSERT INTO $_tableName(duration, Time, Type) VALUES(?, ?, ?)', [duration, time, type]);
  // }

  // Future<void> updateData(int id, String duration, String time, String type) async {
  //   final db = await database;
  //   await db.rawUpdate('UPDATE $_tableName SET duration = ?, Time = ?, Type = ? WHERE Id = ?', [duration, time, type, id]);
  // }

  // Future<void> deleteData(int id) async {
  //   final db = await database;
  //   await db.rawDelete('DELETE FROM $_tableName WHERE Id = ?', [id]);
  // }
// }
