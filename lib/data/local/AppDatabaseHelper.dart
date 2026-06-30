import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabaseHelper {
  static final AppDatabaseHelper _instance = AppDatabaseHelper._internal();
  factory AppDatabaseHelper() => _instance;
  AppDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();

    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'koshy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE wishlist ADD COLUMN quantity INTEGER DEFAULT 1');
    }
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notify(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        action TEXT,
        topic TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ride(
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        carId INTEGER,
        departureDate TEXT,
        departureTime TEXT,
        startLat TEXT,
        startLng TEXT,
        startName TEXT,
        destLat TEXT,
        destLng TEXT,
        destName TEXT,
        seats INTEGER,
        price INTEGER,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT,
        timestamp TEXT,
        isRead INTEGER
      )
    ''');
  }
}
