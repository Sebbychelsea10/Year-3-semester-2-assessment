import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static Database? _database;

  static const String dbName = "finance_app.db";

  static const String userTable = "users";
  static const String transactionTable = "transactions";

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await initDatabase();

    return _database!;
  }

  Future<Database> initDatabase() async {

    String path = join(await getDatabasesPath(), dbName);

    return await openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {

        await db.execute('''
        CREATE TABLE users(
        username TEXT PRIMARY KEY,
        password TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        title TEXT,
        amount REAL,
        category TEXT,
        isIncome INTEGER,
        date TEXT
        )
        ''');
      },
    );
  }

  Future<void> insertUser(String username, String password) async {

    final db = await database;

    await db.insert(
      userTable,
      {
        "username": username,
        "password": password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> validateUser(String username, String password) async {

    final db = await database;

    final result = await db.query(
      userTable,
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  Future<void> insertTransaction(Map<String, dynamic> data) async {

    final db = await database;

    await db.insert(
      transactionTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions(String username) async {

    final db = await database;

    return await db.query(
      transactionTable,
      where: "username = ?",
      whereArgs: [username],
      orderBy: "id DESC",
    );
  }
}