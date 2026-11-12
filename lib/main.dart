import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/local_database.dart';
import 'features/orchard_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;

  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('user_name') ?? '';
  final userPhone = prefs.getString('user_phone') ?? '';
  final userProvince = prefs.getString('user_province') ?? '';
  final userCity = prefs.getString('user_city') ?? '';

  runApp(PistachioApp(
    isLoggedIn: userName.isNotEmpty && userPhone.isNotEmpty,
    userName: userName,
    userPhone: userPhone,
    userProvince: userProvince,
    userCity: userCity,
  ));
}

class PistachioApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final String userPhone;
  final String userProvince;
  final String userCity;

  const PistachioApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.userPhone,
    required this.userProvince,
    required this.userCity,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت باغات پسته',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B5E20),
        scaffoldBackgroundColor: const Color(0xFFF7F9F6),
      ),
      home: isLoggedIn
          ? HomeScreen(
              userName: userName,
              userPhone: userPhone,
              userProvince: userProvince,
              userCity: userCity,
            )
          : const LoginScreen(),
    );
  }
}

