import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pistachio_orchard.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // ۱. جدول قطعات زمین
    await db.execute('''
      CREATE TABLE lands (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        area REAL NOT NULL,
        unit TEXT NOT NULL,
        varieties TEXT,
        irrigation_interval INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        updated_at TEXT NOT NULL
      )
    ''');

    // ۲. جدول گزارش‌های ماهانه (محدودیت یکتا برای جلوگیری از ثبت تکراری ماه)
    await db.execute('''
      CREATE TABLE monthly_reports (
        id TEXT PRIMARY KEY,
        land_id TEXT NOT NULL,
        year_jalali INTEGER NOT NULL,
        month_jalali INTEGER NOT NULL,
        actions TEXT,
        observations TEXT,
        status TEXT DEFAULT 'submitted',
        sync_status TEXT DEFAULT 'pending',
        updated_at TEXT NOT NULL,
        UNIQUE(land_id, year_jalali, month_jalali),
        FOREIGN KEY (land_id) REFERENCES lands (id) ON DELETE CASCADE
      )
    ''');

    // ۳. جدول برنامه پیش‌بینی آبیاری
    await db.execute('''
      CREATE TABLE irrigation_plans (
        id TEXT PRIMARY KEY,
        land_id TEXT NOT NULL,
        year_jalali INTEGER NOT NULL,
        planned_date TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (land_id) REFERENCES lands (id) ON DELETE CASCADE
      )
    ''');

    // ۴. جدول آبیاری واقعی انجام‌شده (تفکیک از برنامه)
    await db.execute('''
      CREATE TABLE irrigation_events (
        id TEXT PRIMARY KEY,
        land_id TEXT NOT NULL,
        actual_date TEXT NOT NULL,
        duration_hours REAL,
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (land_id) REFERENCES lands (id) ON DELETE CASCADE
      )
    ''');

    // ۵. جدول عملکرد و تناژ سالانه
    await db.execute('''
      CREATE TABLE yield_records (
        id TEXT PRIMARY KEY,
        land_id TEXT NOT NULL,
        year_jalali INTEGER NOT NULL,
        bearing_trees INTEGER NOT NULL,
        wet_yield_kg REAL NOT NULL,
        dry_yield_kg REAL NOT NULL,
        hollow_percentage REAL DEFAULT 0,
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        updated_at TEXT NOT NULL,
        UNIQUE(land_id, year_jalali),
        FOREIGN KEY (land_id) REFERENCES lands (id) ON DELETE CASCADE
      )
    ''');

    // ۶. جدول آزمایشات آب، خاک و برگ (یک آزمایش از هر نوع در سال)
    await db.execute('''
      CREATE TABLE lab_tests (
        id TEXT PRIMARY KEY,
        land_id TEXT NOT NULL,
        year_jalali INTEGER NOT NULL,
        test_type TEXT NOT NULL,
        soil_ec REAL,
        soil_ph REAL,
        water_ec REAL,
        leaf_k REAL,
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        updated_at TEXT NOT NULL,
        UNIQUE(land_id, year_jalali, test_type),
        FOREIGN KEY (land_id) REFERENCES lands (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

