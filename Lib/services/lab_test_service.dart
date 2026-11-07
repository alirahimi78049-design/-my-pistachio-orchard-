import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lab_test_model.dart';

class LabTestService {
  final SupabaseClient _client = Supabase.instance.client;

  // دریافت آزمایش ثبت‌شده یک زمین در سال مشخص
  Future<LabTestModel?> getTestForYear(String landId, int year) async {
    final response = await _client
        .from('annual_lab_tests')
        .select()
        .eq('land_id', landId)
        .eq('solar_year', year)
        .maybeSingle();

    if (response == null) return null;
    return LabTestModel.fromJson(response);
  }

  // ثبت یا به‌روزرسانی برگه آزمایش
  Future<void> saveLabTest(LabTestModel test) async {
    await _client.from('annual_lab_tests').upsert(
          test.toJson(),
          onConflict: 'id',
        );
  }
}

