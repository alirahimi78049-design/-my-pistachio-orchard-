import 'package:supabase/supabase.dart';
import '../models/land_model.dart';
import '../main.dart';

class LandService {
  Future<List<LandModel>> getLands(String userPhone) async {
    final response = await supabase
        .from('lands')
        .select()
        .eq('user_phone', userPhone)
        .order('created_at', ascending: false);

    return (response as List).map((row) => LandModel.fromJson(row)).toList();
  }

  Future<LandModel> insertLand(LandModel land) async {
    final response = await supabase
        .from('lands')
        .insert(land.toJson())
        .select()
        .single();

    return LandModel.fromJson(response);
  }
}
