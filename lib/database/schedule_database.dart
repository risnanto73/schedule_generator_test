import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ScheduleDatabase {
  static final ScheduleDatabase instance = ScheduleDatabase._init();
  static Database? _database;

  ScheduleDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('schedules.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        priority TEXT,
        duration TEXT,
        fromDate TEXT,
        untilDate TEXT,
        result TEXT
      )
    ''');
  }

  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule);
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final db = await database;
    return await db.query('schedules', orderBy: 'id DESC');
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }
}
