import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static const String dbName = "finance_app.db";

  static const String userTable = "users";
  static const String transactionTable = "transactions";

  // get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  // initialize database
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

  // add new user
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

  // validate user credentials
  Future<bool> validateUser(String username, String password) async {
    final db = await database;

    final result = await db.query(
      userTable,
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  //insert transaction
  Future<void> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;

    await db.insert(
      transactionTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }

  // get transactions for a user
  Future<List<Map<String, dynamic>>> getTransactions(String username) async {
    final db = await database;

    return await db.query(
      transactionTable,
      where: "username = ?",
      whereArgs: [username],
      orderBy: "id DESC",
    );

  }

  // delete transaction
  Future<void> deleteTransaction(
    String username,
    String title,
    double amount,
    String date,
  ) async {
    final db = await database;
    

    await db.delete(
      transactionTable,
      where: 'username = ? AND title = ? AND amount = ? AND date = ?',
      whereArgs: [username, title, amount, date],
    );
  }
}