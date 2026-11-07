import 'package:supabase/supabase.dart';
import '../models/monthly_action_model.dart';
import '../main.dart';

class MonthlyActionService {
  Future<MonthlyActionModel?> getActionForMonth(
      String landId, int year, String month) async {
    final response = await supabase
        .from('monthly_actions')
        .select()
        .eq('land_id', landId)
        .eq('solar_year', year)
        .eq('month', month)
        .maybeSingle();

    if (response == null) return null;
    return MonthlyActionModel.fromJson(response);
  }

  Future<void> saveAction(MonthlyActionModel action) async {
    await supabase.from('monthly_actions').upsert(
          action.toJson(),
          onConflict: 'id',
        );
  }
}
