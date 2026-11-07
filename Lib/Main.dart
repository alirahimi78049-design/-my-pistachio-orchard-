import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'core/constants/supabase_config.dart';
import 'features/lands/screens/lands_list_screen.dart';

// کلاینت اصلی ارتباط با سرور ابری
final supabase = SupabaseClient(
  SupabaseConfig.url,
  SupabaseConfig.anonKey,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PistachioApp());
}

class PistachioApp extends StatelessWidget {
  const PistachioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت باغ پسته',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LandsListScreen(userPhone: '09120000000'),
    );
  }
}
