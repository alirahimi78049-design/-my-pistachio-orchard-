import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';
import 'features/lands/screens/lands_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

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
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // شماره پیش‌فرض باغدار برای تفکیک اطلاعات در سرور ابری
      home: const LandsListScreen(userPhone: '09120000000'),
    );
  }
}
