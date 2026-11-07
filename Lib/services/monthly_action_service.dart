import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/monthly_action_model.dart';

class MonthlyActionService {
  final SupabaseClient _client = Supabase.instance.client;

  // دریافت اطلاعات ثبت‌شده یک ماه خاص برای یک قطعه زمین
  Future<MonthlyActionModel?> getActionForMonth(
      String landId, int year, String month) async {
    final response = await _client
        .from('monthly_actions')
        .select()
        .eq('land_id', landId)
        .eq('solar_year', year)
        .eq('month', month)
        .maybeSingle();

    if (response == null) return null;
    return MonthlyActionModel.fromJson(response);
  }

  // ثبت یا به‌روزرسانی گزارش ماهانه
  Future<void> saveAction(MonthlyActionModel action) async {
    await _client.from('monthly_actions').upsert(
          action.toJson(),
          onConflict: 'id',
        );
  }
}

