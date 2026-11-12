import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../calendar/jalali_helper.dart';
import 'local_database.dart';

typedef RecordMap = Map<String, dynamic>;

class OrchardRepository {
  static final OrchardRepository instance = OrchardRepository._init();
  final _uuid = const Uuid();

  OrchardRepository._init();

  // ==================== ۱. مدیریت قطعات زمین ====================
  Future<List<RecordMap>> getLands() async {
    final db = await LocalDatabase.instance.database;
    return await db.query(
      'lands',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> addLand({
    required String name,
    required double area,
    required String unit,
    required String varieties,
    required int irrigationInterval,
  }) async {
    final db = await LocalDatabase.instance.database;
    await db.insert('lands', {
      'id': _uuid.v4(),
      'name': name,
      'area': area,
      'unit': unit,
      'varieties': varieties,
      'irrigation_interval': irrigationInterval,
      'is_deleted': 0,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteLand(String id) async {
    final db = await LocalDatabase.instance.database;
    await db.update(
      'lands',
      {
        'is_deleted': 1,
        'sync_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== ۲. گزارش‌های ماهانه ====================
  Future<RecordMap?> getMonthlyReport(
      String landId, int year, int month) async {
    final db = await LocalDatabase.instance.database;
    final res = await db.query(
      'monthly_reports',
      where: 'land_id = ? AND year_jalali = ? AND month_jalali = ?',
      whereArgs: [landId, year, month],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> saveMonthlyReport({
    required String landId,
    required int year,
    required int month,
    required String actions,
    required String observations,
  }) async {
    final db = await LocalDatabase.instance.database;
    final existing = await getMonthlyReport(landId, year, month);

    if (existing != null) {
      await db.update(
        'monthly_reports',
        {
          'actions': actions,
          'observations': observations,
          'sync_status': 'pending',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
    } else {
      await db.insert('monthly_reports', {
        'id': _uuid.v4(),
        'land_id': landId,
        'year_jalali': year,
        'month_jalali': month,
        'actions': actions,
        'observations': observations,
        'status': 'submitted',
        'sync_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ==================== ۳. آبیاری (تفکیک برنامه و واقعیت) ====================
  Future<List<RecordMap>> getIrrigationPlans(String landId, int year) async {
    final db = await LocalDatabase.instance.database;
    return await db.query(
      'irrigation_plans',
      where: 'land_id = ? AND year_jalali = ?',
      whereArgs: [landId, year],
      orderBy: 'planned_date ASC',
    );
  }

  Future<void> generateIrrigationPlan({
    required String landId,
    required String startDateStr,
    required int intervalDays,
  }) async {
    final db = await LocalDatabase.instance.database;
    final parts = startDateStr.split('/');
    int y = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    int d = int.parse(parts[2]);

    Jalali current = Jalali(y, m, d);
    int safeInterval = intervalDays <= 0 ? 13 : intervalDays;

    final existingPlans = await getIrrigationPlans(landId, y);
    final existingDates =
        existingPlans.map((e) => e['planned_date'] as String).toSet();

    final batch = db.batch();
    while (current.year == y) {
      final formatted = PersianDateTimeHelper.formatJalali(current);
      if (!existingDates.contains(formatted)) {
        batch.insert('irrigation_plans', {
          'id': _uuid.v4(),
          'land_id': landId,
          'year_jalali': y,
          'planned_date': formatted,
          'is_completed': 0,
          'sync_status': 'pending',
        });
      }
      current = current + safeInterval;
    }
    await batch.commit(noResult: true);
  }

  Future<void> deletePlannedIrrigation(String id) async {
    final db = await LocalDatabase.instance.database;
    await db.delete('irrigation_plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecordMap>> getActualIrrigations(String landId, int year) async {
    final db = await LocalDatabase.instance.database;
    return await db.query(
      'irrigation_events',
      where: 'land_id = ? AND actual_date LIKE ?',
      whereArgs: [landId, '$year/%'],
      orderBy: 'actual_date ASC',
    );
  }

  Future<void> addActualIrrigation({
    required String landId,
    required String actualDate,
    double? durationHours,
    String? notes,
    String? planId,
  }) async {
    final db = await LocalDatabase.instance.database;
    await db.insert('irrigation_events', {
      'id': _uuid.v4(),
      'land_id': landId,
      'actual_date': actualDate,
      'duration_hours': durationHours,
      'notes': notes ?? '',
      'sync_status': 'pending',
    });

    if (planId != null) {
      await db.update(
        'irrigation_plans',
        {'is_completed': 1, 'sync_status': 'pending'},
        where: 'id = ?',
        whereArgs: [planId],
      );
    }
  }

  Future<void> deleteActualIrrigation(String id) async {
    final db = await LocalDatabase.instance.database;
    await db.delete('irrigation_events', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ۴. ثبت تناژ و عملکرد محصول ====================
  Future<RecordMap?> getYieldRecord(String landId, int year) async {
    final db = await LocalDatabase.instance.database;
    final res = await db.query(
      'yield_records',
      where: 'land_id = ? AND year_jalali = ?',
      whereArgs: [landId, year],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> saveYieldRecord({
    required String landId,
    required int year,
    required int bearingTrees,
    required double wetYieldKg,
    required double dryYieldKg,
    required double hollowPercentage,
    required String notes,
  }) async {
    final db = await LocalDatabase.instance.database;
    final existing = await getYieldRecord(landId, year);

    final data = {
      'bearing_trees': bearingTrees,
      'wet_yield_kg': wetYieldKg,
      'dry_yield_kg': dryYieldKg,
      'hollow_percentage': hollowPercentage,
      'notes': notes,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing != null) {
      await db.update('yield_records', data,
          where: 'id = ?', whereArgs: [existing['id']]);
    } else {
      await db.insert('yield_records', {
        'id': _uuid.v4(),
        'land_id': landId,
        'year_jalali': year,
        ...data,
      });
    }
  }

  // ==================== ۵. آزمایشات آب، خاک و برگ ====================
  Future<RecordMap?> getLabTest(String landId, int year) async {
    final db = await LocalDatabase.instance.database;
    final res = await db.query(
      'lab_tests',
      where: 'land_id = ? AND year_jalali = ? AND test_type = ?',
      whereArgs: [landId, year, 'annual_full'],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> saveLabTest({
    required String landId,
    required int year,
    double? soilEc,
    double? soilPh,
    double? waterEc,
    double? leafK,
    String? notes,
  }) async {
    final db = await LocalDatabase.instance.database;
    final existing = await getLabTest(landId, year);

    final data = {
      'soil_ec': soilEc,
      'soil_ph': soilPh,
      'water_ec': waterEc,
      'leaf_k': leafK,
      'notes': notes ?? '',
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing != null) {
      await db.update('lab_tests', data,
          where: 'id = ?', whereArgs: [existing['id']]);
    } else {
      await db.insert('lab_tests', {
        'id': _uuid.v4(),
        'land_id': landId,
        'year_jalali': year,
        'test_type': 'annual_full',
        ...data,
      });
    }
  }

  // ==================== ۶. گزارش‌گیری تجمیعی سالانه ====================
  Future<RecordMap> getAnnualSummary(String landId, int year) async {
    final db = await LocalDatabase.instance.database;
    final yieldData = await getYieldRecord(landId, year);
    final labData = await getLabTest(landId, year);
    final plans = await getIrrigationPlans(landId, year);
    final actuals = await getActualIrrigations(landId, year);

    final reports = await db.query(
      'monthly_reports',
      where: 'land_id = ? AND year_jalali = ?',
      whereArgs: [landId, year],
      orderBy: 'month_jalali ASC',
    );

    return {
      'yield': yieldData,
      'lab': labData,
      'plannedCount': plans.length,
      'actualIrrigations': actuals,
      'monthlyReports': reports,
    };
  }

  Future<int> getPendingSyncCount() async {
    final db = await LocalDatabase.instance.database;
    int total = 0;
    for (final table in [
      'lands',
      'monthly_reports',
      'irrigation_plans',
      'irrigation_events',
      'yield_records',
      'lab_tests'
    ]) {
      final res = await db.rawQuery(
          "SELECT COUNT(*) as c FROM $table WHERE sync_status = 'pending'");
      total += Sqflite.firstIntValue(res) ?? 0;
    }
    return total;
  }
}
