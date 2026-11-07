import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/land_model.dart';

class LandService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<LandModel>> getLands(String userPhone) async {
    final response = await _client
        .from('lands')
        .select()
        .eq('user_phone', userPhone)
        .order('created_at', ascending: false);

    return (response as List).map((row) => LandModel.fromJson(row)).toList();
  }

  Future<LandModel> insertLand(LandModel land) async {
    final response = await _client
        .from('lands')
        .insert(land.toJson())
        .select()
        .single();

    return LandModel.fromJson(response);
  }
}

