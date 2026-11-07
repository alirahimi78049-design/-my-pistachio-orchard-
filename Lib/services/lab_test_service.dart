import 'package:supabase/supabase.dart';
import '../models/lab_test_model.dart';
import '../main.dart';

class LabTestService {
  Future<LabTestModel?> getTestForYear(String landId, int year) async {
    final response = await supabase
        .from('annual_lab_tests')
        .select()
        .eq('land_id', landId)
        .eq('solar_year', year)
        .maybeSingle();

    if (response == null) return null;
    return LabTestModel.fromJson(response);
  }

  Future<void> saveLabTest(LabTestModel test) async {
    await supabase.from('annual_lab_tests').upsert(
          test.toJson(),
          onConflict: 'id',
        );
  }
}
