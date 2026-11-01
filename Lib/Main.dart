import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ==========================================
// موتور تبدیل استاندارد تقویم میلادی به شمسی
// ==========================================
class PersianDateUtils {
  static String nowPersian() {
    return toPersian(DateTime.now());
  }

  static String toPersian(DateTime dt) {
    int gY = dt.year;
    int gM = dt.month;
    int gD = dt.day;

    final gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];

    int gy2 = (gM > 2) ? (gY + 1) : gY;
    int gDayNo = 365 * gY + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) - 80;
    for (int i = 0; i < gM - 1; ++i) {
      gDayNo += gDaysInMonth[i];
    }
    gDayNo += gD;

    int jDayNo = gDayNo - 79;
    int jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    int jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    int jm = 0;
    for (int i = 0; i < 11 && jDayNo >= jDaysInMonth[i]; ++i) {
      jDayNo -= jDaysInMonth[i];
      jm = i + 1;
    }
    int jd = jDayNo + 1;
    jm = jm + 1;

    // محافظت در برابر مقادیر خارج از محدوده
    if (jy < 1350 || jy > 1450) {
      jy = 1404;
    }

    final mStr = jm.toString().padLeft(2, '0');
    final dStr = jd.toString().padLeft(2, '0');
    return '$jy/$mStr/$dStr';
  }
}

// ذخیره‌سازی محلی فایل‌ها
class FileStorageService {
  static Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName.json');
  }

  static Future<void> saveString(String fileName, String content) async {
    try {
      final file = await _getFile(fileName);
      await file.writeAsString(content, flush: true);
    } catch (_) {}
  }

  static Future<String?> readString(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return null;
  }
}

// ==========================================
// مدل‌ها
// ==========================================
class UserProfile {
  final String fullName;
  final String phoneNumber;
  final String province;
  final String city;
  final String role;

  UserProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.province,
    required this.city,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'province': province,
        'city': city,
        'role': role,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: json['fullName'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        province: json['province'] ?? '',
        city: json['city'] ?? '',
        role: json['role'] ?? 'باغدار',
      );
}

class ProductDetailItem {
  final String id;
  final String title;
  final String category;
  final int priceTomans;
  final String unit;
  final String description;
  final String practicalUsage;
  final IconData icon;

  ProductDetailItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priceTomans,
    required this.unit,
    required this.description,
    required this.practicalUsage,
    required this.icon,
  });
}

class CartItem {
  final ProductDetailItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class OrchardLand {
  final String id;
  String name;
  String unit;
  double areaValue;
  double standardAreaSquareMeters;
  List<String> treeVarieties;
  bool isDeleted;

  OrchardLand({
    required this.id,
    required this.name,
    required this.unit,
    required this.areaValue,
    required this.standardAreaSquareMeters,
    required this.treeVarieties,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'areaValue': areaValue,
        'standardAreaSquareMeters': standardAreaSquareMeters,
        'treeVarieties': treeVarieties,
        'isDeleted': isDeleted,
      };

  factory OrchardLand.fromJson(Map<String, dynamic> json) => OrchardLand(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        unit: json['unit'] ?? 'هکتار',
        areaValue: (json['areaValue'] as num?)?.toDouble() ?? 1.0,
        standardAreaSquareMeters: (json['standardAreaSquareMeters'] as num?)?.toDouble() ?? 10000.0,
        treeVarieties: List<String>.from(json['treeVarieties'] ?? []),
        isDeleted: json['isDeleted'] ?? false,
      );
}

class MonthlyRecord {
  final String id;
  final String landId;
  final int solarYear;
  final String month;
  String countType;
  int treeCount;
  String variety;
  String ageGroup;
  int treeAge;
  String leafTestDate;
  Map<String, String> leafElements;
  String soilType;
  String soilTestDate;
  Map<String, String> soilElements;
  List<String> irrigationDates;
  Map<String, String> waterElements;
  String periodNotes;

  MonthlyRecord({
    required this.id,
    required this.landId,
    required this.solarYear,
    required this.month,
    required this.countType,
    required this.treeCount,
    required this.variety,
    required this.ageGroup,
    required this.treeAge,
    required this.leafTestDate,
    required this.leafElements,
    required this.soilType,
    required this.soilTestDate,
    required this.soilElements,
    required this.irrigationDates,
    required this.waterElements,
    required this.periodNotes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'landId': landId,
        'solarYear': solarYear,
        'month': month,
        'countType': countType,
        'treeCount': treeCount,
        'variety': variety,
        'ageGroup': ageGroup,
        'treeAge': treeAge,
        'leafTestDate': leafTestDate,
        'leafElements': leafElements,
        'soilType': soilType,
        'soilTestDate': soilTestDate,
        'soilElements': soilElements,
        'irrigationDates': irrigationDates,
        'waterElements': waterElements,
        'periodNotes': periodNotes,
      };

  factory MonthlyRecord.fromJson(Map<String, dynamic> json) => MonthlyRecord(
        id: json['id'] ?? '',
        landId: json['landId'] ?? '',
        solarYear: json['solarYear'] ?? 1404,
        month: json['month'] ?? 'مهر',
        countType: json['countType'] ?? 'هکتار',
        treeCount: json['treeCount'] ?? 0,
        variety: json['variety'] ?? 'اکبری',
        ageGroup: json['ageGroup'] ?? 'بارور',
        treeAge: json['treeAge'] ?? 0,
        leafTestDate: json['leafTestDate'] ?? '',
        leafElements: Map<String, String>.from(json['leafElements'] ?? {}),
        soilType: json['soilType'] ?? 'رسی',
        soilTestDate: json['soilTestDate'] ?? '',
        soilElements: Map<String, String>.from(json['soilElements'] ?? {}),
        irrigationDates: List<String>.from(json['irrigationDates'] ?? []),
        waterElements: Map<String, String>.from(json['waterElements'] ?? {}),
        periodNotes: json['periodNotes'] ?? '',
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserProfile? savedUser;
  final userJson = await FileStorageService.readString('user_profile');
  if (userJson != null) {
    try {
      savedUser = UserProfile.fromJson(jsonDecode(userJson));
    } catch (_) {}
  }
  runApp(PistachioApp(initialUser: savedUser));
}

class PistachioApp extends StatelessWidget {
  final UserProfile? initialUser;
  const PistachioApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سامانه هوشمند باغات پسته',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5329),
          primary: const Color(0xFF2E5329),
          secondary: const Color(0xFF6B4226),
        ),
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF244420),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 3,
        ),
      ),
      home: initialUser != null
          ? MainNavigationShell(currentUser: initialUser!)
          : const AuthGateScreen(),
    );
  }
}

// پیکر تاریخ متصل به ساعت و تقویم گوشی بدون ارور دراپ‌داون
Future<String?> pickDeviceSyncedDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2035),
    locale: const Locale('en', 'US'),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E5329),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    return PersianDateUtils.toPersian(picked);
  }
  return null;
}

// ویجت‌های طراحی
class ElevatedCardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color baseColor;

  const ElevatedCardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.only(bottom: 16.0),
    this.borderRadius = 18.0,
    this.baseColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
        border: Border.all(color: const Color(0xFFE5DFD5), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class DeepGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry padding;

  const DeepGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [Color(0xFF386641), Color(0xFF224227)],
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: colors.last.withOpacity(0.3), offset: const Offset(0, 3), blurRadius: 8),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

// صفحه لاگین
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final adminCodeController = TextEditingController();

  final Map<String, List<String>> iranProvinces = {
    'کرمان': ['رفسنجان', 'سیرجان', 'انار', 'زرند', 'شهربابک', 'کرمان'],
    'یزد': ['مهریز', 'خاتم', 'ابرکوه', 'تفت', 'یزد'],
    'خراسان رضوی': ['مه ولات', 'بردسکن', 'خلیل آباد', 'سبزوار', 'مشهد'],
    'خراسان جنوبی': ['بشرویه', 'فردوس', 'سرایان', 'بیرجند'],
    'سمنان': ['دامغان', 'شاهرود', 'سمنان'],
    'فارس': ['نی ریز', 'سروستان', 'شیراز'],
    'مرکزی': ['زرندیه', 'ساوه', 'اراک'],
    'قزوین': ['بوئین زهرا', 'قزوین'],
    'قم': ['قم'],
    'تهران': ['ورامین', 'تهران'],
  };

  String selectedProvince = 'کرمان';
  late String selectedCity;
  String selectedRole = 'باغدار';

  @override
  void initState() {
    super.initState();
    selectedCity = iranProvinces[selectedProvince]!.first;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B3818), Color(0xFF2C5528)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.park, size: 68, color: Color(0xFFC7E6C0)),
                    SizedBox(height: 10),
                    Text(
                      'سامانه هوشمند باغات پسته',
                      style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedCardBox(
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ثبت اطلاعات کاربری و ورود', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
                        const SizedBox(height: 16),
                        _buildStyledInput(controller: nameController, label: 'نام و نام خانوادگی *', icon: Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildStyledInput(controller: phoneController, label: 'شماره همراه (مثال: 09123456789) *', icon: Icons.phone_android_outlined, isPhone: true),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedProvince,
                                items: iranProvinces.keys.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (prov) {
                                  if (prov != null) {
                                    setState(() {
                                      selectedProvince = prov;
                                      selectedCity = iranProvinces[prov]!.first;
                                    });
                                  }
                                },
                                decoration: _inputDecoration('استان *', Icons.map_outlined),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCity,
                                items: iranProvinces[selectedProvince]!.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (c) {
                                  if (c != null) setState(() => selectedCity = c);
                                },
                                decoration: _inputDecoration('شهر *', Icons.location_city_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          items: ['باغدار', 'مشاور/مدیر'].map((r) => DropdownMenuItem(value: r, child: Text('نقش: $r'))).toList(),
                          onChanged: (v) => setState(() => selectedRole = v!),
                          decoration: _inputDecoration('نقش کاربری', Icons.badge_outlined),
                        ),
                        if (selectedRole == 'مشاور/مدیر') ...[
                          const SizedBox(height: 12),
                          _buildStyledInput(controller: adminCodeController, label: 'کد امنیتی تأیید مدیر (Passcode) *', icon: Icons.lock_outline, isPassword: true),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DeepGradientButton(
                            onPressed: _handleLogin,
                            child: const Text('ورود به سامانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF386641), size: 20),
      filled: true,
      fillColor: const Color(0xFFFAFAF7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4DED2))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4DED2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF386641), width: 2)),
    );
  }

  Widget _buildStyledInput({required TextEditingController controller, required String label, required IconData icon, bool isPhone = false, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLength: isPhone ? 11 : null,
      decoration: _inputDecoration(label, icon).copyWith(counterText: ''),
    );
  }

  void _handleLogin() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً نام خود را وارد فرمایید.')));
      return;
    }

    final phoneRegex = RegExp(r'^09[0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره همراه باید ۱۱ رقم بوده و با ۰۹ آغاز شود.')));
      return;
    }

    if (selectedRole == 'مشاور/مدیر' && adminCodeController.text.trim() != '1404') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد امنیتی مدیر نادرست است.')));
      return;
    }

    final user = UserProfile(
      fullName: name,
      phoneNumber: phone,
      province: selectedProvince,
      city: selectedCity,
      role: selectedRole,
    );

    await FileStorageService.saveString('user_profile', jsonEncode(user.toJson()));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => MainNavigationShell(currentUser: user)),
    );
  }
}

// پوسته اصلی
class MainNavigationShell extends StatefulWidget {
  final UserProfile currentUser;

  const MainNavigationShell({super.key, required this.currentUser});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int currentTabIndex = 0;
  int selectedYear = 1404;

  // سال‌های استاندارد با اعتبارسنجی
  final List<int> allAvailableYears = List.generate(40, (index) => 1390 + index);

  Map<int, String> yearlyNotes = {};
  List<OrchardLand> lands = [];
  List<MonthlyRecord> records = [];
  final List<CartItem> cartItems = [];

  final List<ProductDetailItem> allProducts = [
    ProductDetailItem(
      id: 'F-101',
      title: 'سودوپتاس ۵۲٪ (سولفات پتاسیم)',
      category: 'کود و کلات',
      priceTomans: 1850000,
      unit: 'کیسه ۲۵ کیلوگرمی',
      icon: Icons.grain,
      description: '• تأمین سریع پتاسیم و گوگرد محلول برای درختان بارور\n• افزایش وزن، پر شدن مغز و خندان شدن طبیعی پسته\n• بهبود ضخامت پوست استخوانی\n• تقویت سیستم ایمنی گیاه در برابر تنش شوری و کم‌آبی\n• حلالیت ۱۰۰ درصد بدون رسوب‌گذاری',
      practicalUsage: 'در ماه‌های تیر و مرداد (زمان پر شدن مغز پسته) همراه با آب آبیاری مصرف شود.',
    ),
    ProductDetailItem(
      id: 'F-102',
      title: 'کلات آهن ۶٪ ارتو-ارتو (EDDHA)',
      category: 'کود و کلات',
      priceTomans: 950000,
      unit: 'بسته ۱ کیلوگرمی',
      icon: Icons.science,
      description: '• بهترین و پایدارترین فرم آهن برای خاک‌های آهکی\n• رفع سریع زردی بین رگبرگی برگ‌ها\n• پایداری بالا در خاک‌های قلیایی با pH بالای ۷.۵\n• افزایش فتوسنتز و شادابی شاخه‌ها\n• فاقد سدیم و کلر',
      practicalUsage: 'در فروردین و اردیبهشت ماه در سایه‌انداز درخت مصرف شود.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDataFromDevice();
  }

  Future<void> _loadDataFromDevice() async {
    final landsData = await FileStorageService.readString('lands_data');
    if (landsData != null) {
      try {
        final List decoded = jsonDecode(landsData);
        setState(() {
          lands = decoded.map((e) => OrchardLand.fromJson(e)).toList();
        });
      } catch (_) {}
    } else {
      setState(() {
        lands = [
          OrchardLand(
            id: 'L-101',
            name: 'باغ پسته مرکزی',
            unit: 'هکتار',
            areaValue: 2.5,
            standardAreaSquareMeters: 25000.0,
            treeVarieties: ['اکبری', 'احمد آقایی'],
          ),
        ];
      });
      _persistLands();
    }

    final recsData = await FileStorageService.readString('records_data');
    if (recsData != null) {
      try {
        final List decoded = jsonDecode(recsData);
        setState(() {
          records = decoded.map((e) => MonthlyRecord.fromJson(e)).toList();
        });
      } catch (_) {}
    }

    final notesData = await FileStorageService.readString('notes_data');
    if (notesData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(notesData);
        setState(() {
          yearlyNotes = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
        });
      } catch (_) {}
    }
  }

  Future<void> _persistLands() async {
    final jsonStr = jsonEncode(lands.map((e) => e.toJson()).toList());
    await FileStorageService.saveString('lands_data', jsonStr);
  }

  Future<void> _persistRecords() async {
    final jsonStr = jsonEncode(records.map((e) => e.toJson()).toList());
    await FileStorageService.saveString('records_data', jsonStr);
  }

  Future<void> _persistNotes() async {
    final jsonStr = jsonEncode(yearlyNotes.map((k, v) => MapEntry(k.toString(), v)));
    await FileStorageService.saveString('notes_data', jsonStr);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مدیریت باغات: ${widget.currentUser.fullName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FileStorageService.saveString('user_profile', '');
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AuthGateScreen()),
                );
              },
            )
          ],
        ),
        body: _buildCurrentBody(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentTabIndex,
          onDestinationSelected: (idx) => setState(() => currentTabIndex = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.landscape_outlined), selectedIcon: Icon(Icons.landscape), label: 'زمین‌های من'),
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'فروشگاه'),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'سبد خرید'),
            NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'تاریخچه'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBody() {
    switch (currentTabIndex) {
      case 0:
        return _buildFarmerView();
      case 1:
        return _buildStorePlaceholder();
      case 2:
        return _buildCartPlaceholder();
      case 3:
        return _buildHistoryPlaceholder();
      default:
        return _buildFarmerView();
    }
  }

  Widget _buildFarmerView() {
    final activeLands = lands.where((l) => !l.isDeleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedCardBox(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFF244420),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.park, size: 38, color: Color(0xFFA5D6A7))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('مدیریت باغات و اقدامات سالانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                          const SizedBox(height: 4),
                          Text('سال زراعی فعال: $selectedYear | ${widget.currentUser.province} - ${widget.currentUser.city}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F1EA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB5C9B3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('سال: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C5134))),
                          DropdownButton<int>(
                            value: allAvailableYears.contains(selectedYear) ? selectedYear : allAvailableYears.first,
                            underline: const SizedBox(),
                            isDense: true,
                            items: allAvailableYears.map((int y) {
                              return DropdownMenuItem<int>(
                                value: y,
                                child: Text(y.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (newYear) {
                              if (newYear != null) setState(() => selectedYear = newYear);
                            },
                          ),
                        ],
                      ),
                    ),
                    DeepGradientButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onPressed: _openAddLandDialog,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('افزودن زمین', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('زمین‌های ثبت‌شده من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeLands.length,
            itemBuilder: (context, index) {
              final land = activeLands[index];
              return ElevatedCardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(land.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('مساحت: ${land.areaValue} ${land.unit}'),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5329), foregroundColor: Colors.white),
                            onPressed: () => _openSelfDeclarationForm(land),
                            child: const Text('ثبت جزئیات و تاریخ'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openAddLandDialog() {
    final nameCtrl = TextEditingController();
    final areaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ثبت زمین جدید', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مساحت (هکتار)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5329), foregroundColor: Colors.white),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty || areaCtrl.text.trim().isEmpty) return;
                  final val = double.tryParse(areaCtrl.text.trim()) ?? 1.0;
                  final newLand = OrchardLand(
                    id: 'L-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    unit: 'هکتار',
                    areaValue: val,
                    standardAreaSquareMeters: val * 10000,
                    treeVarieties: ['اکبری'],
                  );
                  setState(() => lands.insert(0, newLand));
                  await _persistLands();
                  if (!mounted) return;
                  Navigator.pop(ctx);
                },
                child: const Text('ذخیره زمین'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openSelfDeclarationForm(OrchardLand land) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => SelfDeclarationScreen(
          land: land,
          year: selectedYear,
          existingRecords: records,
          onSave: (newRec) async {
            setState(() => records.add(newRec));
            await _persistRecords();
          },
        ),
      ),
    );
  }

  Widget _buildStorePlaceholder() => const Center(child: Text('بخش فروشگاه در مرحله بعد اصلاح می‌شود.'));
  Widget _buildCartPlaceholder() => const Center(child: Text('سبد خرید'));
  Widget _buildHistoryPlaceholder() => const Center(child: Text('تاریخچه'));
}

// فرم اقدامات با پیکر تاریخ متصل به سیستم گوشی
class SelfDeclarationScreen extends StatefulWidget {
  final OrchardLand land;
  final int year;
  final List<MonthlyRecord> existingRecords;
  final Function(MonthlyRecord) onSave;

  const SelfDeclarationScreen({
    super.key,
    required this.land,
    required this.year,
    required this.existingRecords,
    required this.onSave,
  });

  @override
  State<SelfDeclarationScreen> createState() => _SelfDeclarationScreenState();
}

class _SelfDeclarationScreenState extends State<SelfDeclarationScreen> {
  late TextEditingController leafDateCtrl;
  late TextEditingController soilDateCtrl;
  final treeCountCtrl = TextEditingController(text: '350');
  final treeAgeCtrl = TextEditingController(text: '12');
  final periodNotesCtrl = TextEditingController();
  final List<String> irrigationDates = [];

  @override
  void initState() {
    super.initState();
    // دریافت تاریخ دقیق امروز از تقویم و ساعت گوشی
    final today = PersianDateUtils.nowPersian();
    leafDateCtrl = TextEditingController(text: today);
    soilDateCtrl = TextEditingController(text: today);
    irrigationDates.add(today);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('ثبت جزئیات: ${widget.land.name}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // کادر آزمایش برگ متصل به ساعت و تقویم گوشی
              ElevatedCardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاریخ آزمایش برگ:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await pickDeviceSyncedDate(context);
                        if (picked != null) {
                          setState(() => leafDateCtrl.text = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(leafDateCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Icon(Icons.calendar_month, color: Color(0xFF2E5329)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // کادر آزمایش خاک متصل به ساعت و تقویم گوشی
              ElevatedCardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاریخ آزمایش خاک:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await pickDeviceSyncedDate(context);
                        if (picked != null) {
                          setState(() => soilDateCtrl.text = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(soilDateCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Icon(Icons.calendar_month, color: Color(0xFF2E5329)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // دوره‌های آبیاری متصل به ساعت و تقویم گوشی
              ElevatedCardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('دوره‌های آبیاری:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5329), foregroundColor: Colors.white),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('افزودن تاریخ امروز/جدید'),
                          onPressed: () async {
                            final picked = await pickDeviceSyncedDate(context);
                            if (picked != null && !irrigationDates.contains(picked)) {
                              setState(() => irrigationDates.add(picked));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: irrigationDates.map((d) => Chip(
                        label: Text(d),
                        onDeleted: () => setState(() => irrigationDates.remove(d)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5329), foregroundColor: Colors.white),
                  onPressed: () {
                    final rec = MonthlyRecord(
                      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
                      landId: widget.land.id,
                      solarYear: widget.year,
                      month: 'مهر',
                      countType: 'هکتار',
                      treeCount: int.tryParse(treeCountCtrl.text) ?? 350,
                      variety: 'اکبری',
                      ageGroup: 'بارور',
                      treeAge: int.tryParse(treeAgeCtrl.text) ?? 12,
                      leafTestDate: leafDateCtrl.text,
                      leafElements: {},
                      soilType: 'رسی',
                      soilTestDate: soilDateCtrl.text,
                      soilElements: {},
                      irrigationDates: irrigationDates,
                      waterElements: {},
                      periodNotes: periodNotesCtrl.text.trim(),
                    );
                    widget.onSave(rec);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات با تاریخ انتخابی ذخیره شد.')));
                  },
                  child: const Text('ثبت نهایی', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
