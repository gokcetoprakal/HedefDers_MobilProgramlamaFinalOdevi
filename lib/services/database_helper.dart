import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dersler.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Verileri JSON string olarak tek bir tabloda tutacağız
    await db.execute('''
      CREATE TABLE veriler (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anahtar TEXT UNIQUE,
        icerik TEXT
      )
    ''');
  }

  // Veri Kaydetme
  Future<void> veriyiKaydet(String anahtar, String icerik) async {
    final db = await instance.database;
    await db.insert('veriler', {
      'anahtar': anahtar,
      'icerik': icerik,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Veri Getirme
  Future<String?> veriyiGetir(String anahtar) async {
    final db = await instance.database;
    final maps = await db.query(
      'veriler',
      columns: ['icerik'],
      where: 'anahtar = ?',
      whereArgs: [anahtar],
    );

    if (maps.isNotEmpty) {
      return maps.first['icerik'] as String;
    }
    return null;
  }
}
