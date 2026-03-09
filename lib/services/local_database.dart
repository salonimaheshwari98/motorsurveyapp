import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _instance;

  static Future<Database> getInstance() async {
    if (_instance != null) return _instance!;
    final path = await getDatabasesPath();
    _instance = await openDatabase(
      join(path, 'motorsurvey.db'),
      version: 1,
      onCreate: (db, version) async {
        // create tables for claims, parts, photos, documents, assessment
        await db.execute('''
          CREATE TABLE claims (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_number TEXT,
            policy_number TEXT,
            insurer TEXT,
            insured_name TEXT,
            phone TEXT,
            vehicle_number TEXT,
            vehicle_model TEXT,
            manufacture_year INTEGER,
            accident_date TEXT,
            accident_location TEXT,
            status TEXT,
            sync_status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE parts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_id INTEGER,
            part_name TEXT,
            quantity INTEGER,
            rate REAL,
            amount REAL,
            material_type TEXT,
            depreciation_percent REAL,
            approved_amount REAL,
            accepted INTEGER,
            sync_status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_id INTEGER,
            image_url TEXT,
            timestamp TEXT,
            gps_location TEXT,
            photo_type TEXT,
            sync_status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_id INTEGER,
            document_type TEXT,
            file_url TEXT,
            sync_status TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE assessment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claim_id INTEGER,
            inspection_notes TEXT,
            liability REAL,
            recommendation TEXT,
            final_amount REAL,
            sync_status TEXT
          );
        ''');
      },
    );
    return _instance!;
  }
}
