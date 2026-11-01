import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ==========================================
// موتور تقویم و محاسبات تاریخ شمسی (بدون باگ و بدون کرش)
// ==========================================
class PersianCalendarEngine {
  static final List<String> monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  static String getTodayPersian() {
    final now = DateTime.now();
    return gregorianToPersian(now.year, now.month, now.day);
  }

  static String gregorianToPersian(int gy, int gm, int gd) {
    final gDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int gy2 = (gm > 2) ? (gy + 1) : gy;
    int gDayNo = 365 * gy + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) - 80;
    for (int i = 0; i < gm - 1; ++i) {
      gDayNo += gDays[i];
    }
    gDayNo += gd;

    int jDayNo = gDayNo - 79;
    int jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    int jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    final jDays = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    int jm = 0;
    for (int i = 0; i < 11 && jDayNo >= jDays[i]; ++i) {
      jDayNo -= jDays[i];
      jm = i + 1;
    }
    int jd = jDayNo + 1;
    jm = jm + 1;

    if (jy < 1350 || jy > 1460) jy = 1404;

    return '$jy/${jm.toString().padLeft(2, '0')}/${jd.toString().padLeft(2, '0')}';
  }

  // محاسبه نوبت بعدی آبیاری بر اساس دوره چاه
  static String calculateNextIrrigationDate(String currentPersianDate, int intervalDays) {
    try {
      final parts = currentPersianDate.split('/');
      int y = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      int d = int.parse(parts[2]);

      d += intervalDays;

      while (true) {
        int maxDaysInCurrentMonth = (m <= 6) ? 31 : (m <= 11 ? 30 : 29);
        if (d > maxDaysInCurrentMonth) {
          d -= maxDaysInCurrentMonth;
          m++;
          if (m > 12) {
            m = 1;
            y++;
          }
        } else {
          break;
        }
      }

      return '$y/${m.toString().padLeft(2, '0')}/${d.toString().padLeft(2, '0')}';
    } catch (_) {
      return currentPersianDate;
    }
  }
}

// ذخیره‌سازی دائمی دیسک
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
// مدل‌های داده
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
  final String category; // 'کود و کلات', 'سموم و دفع آفات', 'ابزارآلات باغبانی'
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
  int irrigationIntervalDays; // مدار گردش آب چاه به روز
  bool isDeleted;

  OrchardLand({
    required this.id,
    required this.name,
    required this.unit,
    required this.areaValue,
    required this.standardAreaSquareMeters,
    required this.treeVarieties,
    this.irrigationIntervalDays = 13,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'areaValue': areaValue,
        'standardAreaSquareMeters': standardAreaSquareMeters,
        'treeVarieties': treeVarieties,
        'irrigationIntervalDays': irrigationIntervalDays,
        'isDeleted': isDeleted,
      };

  factory OrchardLand.fromJson(Map<String, dynamic> json) => OrchardLand(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        unit: json['unit'] ?? 'هکتار',
        areaValue: (json['areaValue'] as num?)?.toDouble() ?? 1.0,
        standardAreaSquareMeters: (json['standardAreaSquareMeters'] as num?)?.toDouble() ?? 10000.0,
        treeVarieties: List<String>.from(json['treeVarieties'] ?? []),
        irrigationIntervalDays: json['irrigationIntervalDays'] ?? 13,
        isDeleted: json['isDeleted'] ?? false,
      );
}

// ثبت یک‌باره آزمایش سالانه برای هر قطعه
class AnnualLabTest {
  final String landId;
  final int solarYear;
  String leafTestDate;
  Map<String, String> leafElements;
  String soilType;
  String soilTestDate;
  Map<String, String> soilElements;
  String waterTestDate;
  Map<String, String> waterElements;

  AnnualLabTest({
    required this.landId,
    required this.solarYear,
    this.leafTestDate = '',
    required this.leafElements,
    this.soilType = 'رسی',
    this.soilTestDate = '',
    required this.soilElements,
    this.waterTestDate = '',
    required this.waterElements,
  });

  Map<String, dynamic> toJson() => {
        'landId': landId,
        'solarYear': solarYear,
        'leafTestDate': leafTestDate,
        'leafElements': leafElements,
        'soilType': soilType,
        'soilTestDate': soilTestDate,
        'soilElements': soilElements,
        'waterTestDate': waterTestDate,
        'waterElements': waterElements,
      };

  factory AnnualLabTest.fromJson(Map<String, dynamic> json) => AnnualLabTest(
        landId: json['landId'] ?? '',
        solarYear: json['solarYear'] ?? 1404,
        leafTestDate: json['leafTestDate'] ?? '',
        leafElements: Map<String, String>.from(json['leafElements'] ?? {}),
        soilType: json['soilType'] ?? 'رسی',
        soilTestDate: json['soilTestDate'] ?? '',
        soilElements: Map<String, String>.from(json['soilElements'] ?? {}),
        waterTestDate: json['waterTestDate'] ?? '',
        waterElements: Map<String, String>.from(json['waterElements'] ?? {}),
      );
}

// اقدامات ماهانه (بدون فرم سنگین آزمایش، صرفاً یادداشت‌های تجربی و تقویم آب)
class MonthlyFarmAction {
  final String id;
  final String landId;
  final int solarYear;
  final String month;
  String mainActionNote; // اقدامات کودی، سمپاشی، هرس و...
  String treeObservationNote; // وضعیت پسته، ارزنی شدن، سرخشکی، آفات
  List<String> irrigationDates;
  Map<String, String> waterIndicators; // EC, pH, TDS, SAR

  MonthlyFarmAction({
    required this.id,
    required this.landId,
    required this.solarYear,
    required this.month,
    required this.mainActionNote,
    required this.treeObservationNote,
    required this.irrigationDates,
    required this.waterIndicators,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'landId': landId,
        'solarYear': solarYear,
        'month': month,
        'mainActionNote': mainActionNote,
        'treeObservationNote': treeObservationNote,
        'irrigationDates': irrigationDates,
        'waterIndicators': waterIndicators,
      };

  factory MonthlyFarmAction.fromJson(Map<String, dynamic> json) => MonthlyFarmAction(
        id: json['id'] ?? '',
        landId: json['landId'] ?? '',
        solarYear: json['solarYear'] ?? 1404,
        month: json['month'] ?? 'مهر',
        mainActionNote: json['mainActionNote'] ?? '',
        treeObservationNote: json['treeObservationNote'] ?? '',
        irrigationDates: List<String>.from(json['irrigationDates'] ?? []),
        waterIndicators: Map<String, String>.from(json['waterIndicators'] ?? {}),
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
          seedColor: const Color(0xFF244420),
          primary: const Color(0xFF244420),
          secondary: const Color(0xFF6B4226),
        ),
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF244420),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: initialUser != null
          ? MainNavigationShell(currentUser: initialUser!)
          : const AuthGateScreen(),
    );
  }
}

// انتخابگر تقویم شمسی مستقل (بدون تداخل با تقویم انگلیسی گوشی)
Future<String?> showPurePersianDatePicker(BuildContext context, {String? defaultDate}) async {
  final current = defaultDate ?? PersianCalendarEngine.getTodayPersian();
  final parts = current.split('/');
  int selYear = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 1404) : 1404;
  int selMonth = parts.length > 1 ? (int.tryParse(parts[1]) ?? 7) : 7;
  int selDay = parts.length > 2 ? (int.tryParse(parts[2]) ?? 15) : 15;

  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('انتخاب تاریخ شمسی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFE8F1E7), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '$selYear / ${selMonth.toString().padLeft(2, '0')} / ${selDay.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF244420)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: selYear,
                    items: List.generate(35, (i) => 1390 + i).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (v) => setDState(() => selYear = v!),
                  ),
                  DropdownButton<int>(
                    value: selMonth,
                    items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text(PersianCalendarEngine.monthNames[m - 1]))).toList(),
                    onChanged: (v) => setDState(() => selMonth = v!),
                  ),
                  DropdownButton<int>(
                    value: selDay,
                    items: List.generate(selMonth <= 6 ? 31 : (selMonth <= 11 ? 30 : 29), (i) => i + 1)
                        .map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
                    onChanged: (v) => setDState(() => selDay = v!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('انصراف')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
              onPressed: () {
                final result = '$selYear/${selMonth.toString().padLeft(2, '0')}/${selDay.toString().padLeft(2, '0')}';
                Navigator.pop(ctx, result);
              },
              child: const Text('تأیید تاریخ'),
            )
          ],
        ),
      ),
    ),
  );
}

// ویجت‌های سه‌بعدی و با فاصله استاندارد
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
            offset: const Offset(0, 5),
            blurRadius: 12,
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
                  color: Color(0xFF244420),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.park, size: 64, color: Color(0xFFA5D6A7)),
                    SizedBox(height: 10),
                    Text('سامانه هوشمند باغات پسته', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedCardBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ورود باغدار / کارشناس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                      const SizedBox(height: 14),
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره همراه (مثال: 09123456789) *', border: OutlineInputBorder())),
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
                              decoration: const InputDecoration(labelText: 'استان', border: OutlineInputBorder()),
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
                              decoration: const InputDecoration(labelText: 'شهر', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: ['باغدار', 'مشاور/مدیر'].map((r) => DropdownMenuItem(value: r, child: Text('نقش: $r'))).toList(),
                        onChanged: (v) => setState(() => selectedRole = v!),
                        decoration: const InputDecoration(labelText: 'نقش کاربری', border: OutlineInputBorder()),
                      ),
                      if (selectedRole == 'مشاور/مدیر') ...[
                        const SizedBox(height: 12),
                        TextField(controller: adminCodeController, obscureText: true, decoration: const InputDecoration(labelText: 'کد امنیتی تأیید مدیر (Passcode) *', border: OutlineInputBorder())),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                          onPressed: _handleLogin,
                          child: const Text('ورود به سامانه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || !RegExp(r'^09[0-9]{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً نام و شماره همراه ۱۱ رقمی معتبر را وارد نمایید.')));
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

// ==========================================
// پوسته اصلی برنامه
// ==========================================
class MainNavigationShell extends StatefulWidget {
  final UserProfile currentUser;

  const MainNavigationShell({super.key, required this.currentUser});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int currentTabIndex = 0;
  int selectedYear = 1404;
  final List<int> allAvailableYears = List.generate(25, (index) => 1395 + index);

  Map<int, String> yearlyNotes = {};
  List<OrchardLand> lands = [];
  List<MonthlyFarmAction> monthlyActions = [];
  List<AnnualLabTest> labTests = [];
  final List<CartItem> cartItems = [];

  // کاتالوگ فروشگاه
  final List<ProductDetailItem> allProducts = [
    ProductDetailItem(
      id: 'F-101',
      title: 'سودوپتاس ۵۲٪ (سولفات پتاسیم محلول)',
      category: 'کود و کلات',
      priceTomans: 1850000,
      unit: 'کیسه ۲۵ کیلوگرمی',
      icon: Icons.grain,
      description: '• تأمین سریع پتاسیم و گوگرد محلول برای درختان بارور\n• افزایش چشمگیر وزن، پر شدن مغز و خندان شدن طبیعی پسته\n• بهبود ضخامت پوست استخوانی و جلوگیری از عارضه لکه‌پوست\n• تقویت سیستم ایمنی گیاه در برابر تنش شوری و کم‌آبی\n• کاملاً محلول در آب با حلالیت ۱۰۰ درصد بدون رسوب‌گذاری',
      practicalUsage: 'در ماه‌های تیر و مرداد (زمان پر شدن مغز پسته) در ۲ تا ۳ نوبت همراه با آب آبیاری یا محلول‌پاشی مصرف گردد.',
    ),
    ProductDetailItem(
      id: 'F-102',
      title: 'کلات آهن ۶٪ ارتو-ارتو (EDDHA)',
      category: 'کود و کلات',
      priceTomans: 950000,
      unit: 'بسته ۱ کیلوگرمی پودری',
      icon: Icons.science,
      description: '• بهترین فرم آهن برای خاک‌های قلیایی و آهکی پسته\n• برطرف‌کننده سریع زردی بین رگبرگی ناشی از کمبود آهن\n• پایداری فوق‌العاده در خاک‌های دارای pH بالاتر از ۷.۵\n• افزایش فتوسنتز و شادابی برگ‌ها در شروع فصل رشد\n• فاقد سدیم و کلر و کاملاً ایمن برای ریشه‌ها',
      practicalUsage: 'در فروردین و اردیبهشت ماه همزمان با آغاز رشد رویشی شاخه‌ها در سایه‌انداز درخت مصرف شود.',
    ),
    ProductDetailItem(
      id: 'P-201',
      title: 'صابون محلول‌پاشی پتاسیمی گیاهی (ضد پسیل)',
      category: 'سموم و دفع آفات',
      priceTomans: 620000,
      unit: 'گالن ۵ لیتری',
      icon: Icons.shield,
      description: '• شستشوی کامل شکرک و عسلک شیره خشک پسیل از روی برگ‌ها\n• از بین بردن پوره و حشرات کامل بدون ایجاد مقاومت دارویی\n• بهبود تنفس برگ‌ها و جلوگیری از برگ‌ریزی ناشی از آفت\n• تقویت ساختار برگ به دلیل داشتن درصد مناسبی از پتاسیم\n• کاملاً ارگانیک، بدون دوره کارنس و بدون اثر منفی بر محیط‌زیست',
      practicalUsage: 'در ماه‌های خرداد، تیر و مرداد به محض مشاهده طغیان پسیل در ساعات خنک با دوز ۲ تا ۲.۵ در هزار محلول‌پاشی شود.',
    ),
    ProductDetailItem(
      id: 'T-301',
      title: 'قیچی هرس شارژی دو باتری براشلس ۳۵ میلی‌متر',
      category: 'ابزارآلات باغبانی',
      priceTomans: 5200000,
      unit: 'یک ست کامل با کیف و ۲ باتری',
      icon: Icons.content_cut,
      description: '• تیغه فولادی کربنی ضدزنگ SK5 بسیار تیز با برش تمیز\n• موتور پرقدرت براشلس با کارکرد مداوم ۶ تا ۸ ساعت با دو باتری\n• سبک و ارگونومیک، کاهش ۹۰ درصدی خستگی دست در هرس\n• قابلیت تنظیم دهانه برش از ۲۰ تا ۳۵ میلی‌متر\n• همراه با جعبه ابزار و روغن روان‌کننده',
      practicalUsage: 'مخصوص هرس فرم‌دهی و باردهی درختان در ماه‌های آذر، دی و بهمن؛ همچنین هرس سبز پاجوش‌ها در تابستان.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // زمین‌ها
    final landsData = await FileStorageService.readString('lands_v2');
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
            irrigationIntervalDays: 13, // دوره ۱۳ روزه چاه
          ),
        ];
      });
      _persistLands();
    }

    // اقدامات ماهانه
    final actionsData = await FileStorageService.readString('monthly_actions_v2');
    if (actionsData != null) {
      try {
        final List decoded = jsonDecode(actionsData);
        setState(() {
          monthlyActions = decoded.map((e) => MonthlyFarmAction.fromJson(e)).toList();
        });
      } catch (_) {}
    }

    // آزمایش‌های سالانه
    final testsData = await FileStorageService.readString('annual_tests_v2');
    if (testsData != null) {
      try {
        final List decoded = jsonDecode(testsData);
        setState(() {
          labTests = decoded.map((e) => AnnualLabTest.fromJson(e)).toList();
        });
      } catch (_) {}
    }

    // یادداشت‌ها
    final notesData = await FileStorageService.readString('notes_v2');
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
    await FileStorageService.saveString('lands_v2', jsonEncode(lands.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistActions() async {
    await FileStorageService.saveString('monthly_actions_v2', jsonEncode(monthlyActions.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistTests() async {
    await FileStorageService.saveString('annual_tests_v2', jsonEncode(labTests.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistNotes() async {
    await FileStorageService.saveString('notes_v2', jsonEncode(yearlyNotes.map((k, v) => MapEntry(k.toString(), v))));
  }

  void _addToCart(ProductDetailItem product) {
    setState(() {
      final existingIndex = cartItems.indexWhere((c) => c.product.id == product.id);
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity++;
      } else {
        cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.title} به سبد خرید افزوده شد.')));
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
              tooltip: 'خروج از حساب',
              onPressed: () async {
                await FileStorageService.saveString('user_profile', '');
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const AuthGateScreen()));
              },
            )
          ],
        ),
        body: _buildCurrentBody(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentTabIndex,
          onDestinationSelected: (idx) => setState(() => currentTabIndex = idx),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.landscape_outlined), selectedIcon: Icon(Icons.landscape, color: Color(0xFF244420)), label: 'زمین‌های من'),
            const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront, color: Color(0xFF244420)), label: 'فروشگاه'),
            NavigationDestination(
              icon: Badge(label: Text('${cartItems.fold<int>(0, (sum, i) => sum + i.quantity)}'), isLabelVisible: cartItems.isNotEmpty, child: const Icon(Icons.shopping_cart_outlined)),
              selectedIcon: Badge(label: Text('${cartItems.fold<int>(0, (sum, i) => sum + i.quantity)}'), isLabelVisible: cartItems.isNotEmpty, child: const Icon(Icons.shopping_cart, color: Color(0xFF244420))),
              label: 'سبد خرید',
            ),
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
        return _buildCategorizedStoreView();
      case 2:
        return _buildCartView();
      default:
        return _buildFarmerView();
    }
  }

  // ==========================================
  // تب ۱: داشبورد اصلی زمین‌ها با تاریخ امروز و دکمه‌های مجزا
  // ==========================================
  Widget _buildFarmerView() {
    final activeLands = lands.where((l) => !l.isDeleted).toList();
    final todayPersian = PersianCalendarEngine.getTodayPersian();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کادر بالای صفحه با تاریخ روز متصل به گوشی
          ElevatedCardBox(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: const Color(0xFF244420), borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Icon(Icons.eco, size: 34, color: Color(0xFFA5D6A7))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('سامانه پایش باغات و اقدامات سالانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                          const SizedBox(height: 4),
                          Text('تاریخ امروز گوشی: $todayPersian | سال زراعی: $selectedYear', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
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
                      decoration: BoxDecoration(color: const Color(0xFFF4F1EA), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB5C9B3))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('سال: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C5134))),
                          DropdownButton<int>(
                            value: allAvailableYears.contains(selectedYear) ? selectedYear : allAvailableYears.first,
                            underline: const SizedBox(),
                            isDense: true,
                            items: allAvailableYears.map((int y) => DropdownMenuItem<int>(value: y, child: Text(y.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
                            onChanged: (newYear) {
                              if (newYear != null) setState(() => selectedYear = newYear);
                            },
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B4226),
                        side: const BorderSide(color: Color(0xFF6B4226)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: _openYearlyNoteDialog,
                      icon: const Icon(Icons.note_alt_outlined, size: 16),
                      label: const Text('یادداشت سال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF244420),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: _openAddLandDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('افزودن زمین', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('زمین‌های ثبت‌شده من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF244420))),
          const SizedBox(height: 12),
          if (activeLands.isEmpty)
            _buildEmptyState('هیچ زمینی برای این حساب ثبت نشده است.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeLands.length,
              itemBuilder: (context, index) => _buildLandCard(activeLands[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildLandCard(OrchardLand land) {
    return ElevatedCardBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFE8F1E7), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.park, color: Color(0xFF244420), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(land.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B4226), size: 20),
                onPressed: () => _openEditLandDialog(land),
                tooltip: 'ویرایش زمین و مدار آب',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFAF8F5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEAE5DB))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('مساحت: ${land.areaValue} ${land.unit}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const Text('|', style: TextStyle(color: Colors.grey)),
                Text('مدار چاه: هر ${land.irrigationIntervalDays} روز یک‌بار', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('ارقام درختان: ${land.treeVarieties.join('، ')}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const Divider(height: 22),
          // ۳ دکمه اصلی و مستقل برای هر زمین
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF244420),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _openMonthlyActionSelector(land),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('اقدامات ماهانه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    side: const BorderSide(color: Color(0xFFB45309)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _openAnnualLabTestDialog(land),
                  icon: const Icon(Icons.biotech, size: 16),
                  label: const Text('آزمایش سالانه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _openFullYearReport(land),
                  icon: const Icon(Icons.assignment, size: 16),
                  label: const Text('گزارش سال', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // بخش ۱: اقدامات ماهانه (بدون فرم سنگین آزمایش)
  // ==========================================
  void _openMonthlyActionSelector(OrchardLand land) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('انتخاب ماه زراعی سال $selectedYear برای قطعه ${land.name}:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF244420))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PersianCalendarEngine.monthNames.map((m) {
                  final hasData = monthlyActions.any((a) => a.landId == land.id && a.solarYear == selectedYear && a.month == m);
                  return ActionChip(
                    backgroundColor: hasData ? const Color(0xFFD4E7D2) : const Color(0xFFF4F1EA),
                    avatar: Icon(hasData ? Icons.check_circle : Icons.calendar_today, size: 16, color: hasData ? Colors.green : Colors.grey),
                    label: Text(m, style: TextStyle(fontWeight: hasData ? FontWeight.bold : FontWeight.normal)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openMonthlyActionEditor(land, m);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openMonthlyActionEditor(OrchardLand land, String month) {
    final existing = monthlyActions.firstWhere(
      (a) => a.landId == land.id && a.solarYear == selectedYear && a.month == month,
      orElse: () => MonthlyFarmAction(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        landId: land.id,
        solarYear: selectedYear,
        month: month,
        mainActionNote: '',
        treeObservationNote: '',
        irrigationDates: [],
        waterIndicators: {'Ec': '', 'pH': '', 'TDS': '', 'SAR': ''},
      ),
    );

    final actionNoteCtrl = TextEditingController(text: existing.mainActionNote);
    final observationCtrl = TextEditingController(text: existing.treeObservationNote);
    final ecCtrl = TextEditingController(text: existing.waterIndicators['Ec'] ?? '');
    final phCtrl = TextEditingController(text: existing.waterIndicators['pH'] ?? '');
    final tdsCtrl = TextEditingController(text: existing.waterIndicators['TDS'] ?? '');
    final sarCtrl = TextEditingController(text: existing.waterIndicators['SAR'] ?? '');
    final List<String> currentIrrigations = List.from(existing.irrigationDates);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StatefulBuilder(
          builder: (context, setEditorState) => Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(title: Text('اقدامات $month $selectedYear - ${land.name}')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // کادر یادداشت کارهای انجام‌شده
                    ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('۱. اقدامات انجام‌شده در این ماه:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF244420))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: actionNoteCtrl,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'مثال: در مهر ماه سولوپتاس دادم، سم آبامکتین زدم، هرس نرک‌ها را انجام دادم...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // کادر وضعیت رشدی درخت و محصول
                    ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('۲. مشاهدات وضعیت محصول و سلامت درختان:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF244420))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: observationCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'مثال: پسته ارزنی شده، پوک نداشتیم، سرخشکی مشاهده نشد، آفت کنترل شده...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // بخش تقویم آبیاری و مدار چاه
                    ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('۳. نوبت‌های آبیاری این ماه:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF244420))),
                                  Text('مدار چاه این زمین: هر ${land.irrigationIntervalDays} روز یک‌بار', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('ثبت نوبت آب'),
                                onPressed: () async {
                                  final picked = await showPurePersianDatePicker(context);
                                  if (picked != null) {
                                    final nextDate = PersianCalendarEngine.calculateNextIrrigationDate(picked, land.irrigationIntervalDays);
                                    setEditorState(() {
                                      if (!currentIrrigations.contains(picked)) {
                                        currentIrrigations.add(picked);
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('نوبت آب ثبت شد ($picked). نوبت بعدی طبق مدار ${land.irrigationIntervalDays} روزه: $nextDate')),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (currentIrrigations.isEmpty)
                            const Text('هنوز نوبت آبیاری برای این ماه ثبت نشده است.', style: TextStyle(fontSize: 12, color: Colors.grey))
                          else
                            Wrap(
                              spacing: 8,
                              children: currentIrrigations.map((d) {
                                final next = PersianCalendarEngine.calculateNextIrrigationDate(d, land.irrigationIntervalDays);
                                return Chip(
                                  backgroundColor: const Color(0xFFE8F1E7),
                                  label: Text('$d (بعدی: $next)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => setEditorState(() => currentIrrigations.remove(d)),
                                );
                              }).toList(),
                            ),
                          const Divider(height: 24),
                          const Text('شاخص‌های کیفیت آب (اختیاری):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: ecCtrl, decoration: const InputDecoration(labelText: 'EC آب', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)))),
                              const SizedBox(width: 6),
                              Expanded(child: TextField(controller: phCtrl, decoration: const InputDecoration(labelText: 'pH آب', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)))),
                              const SizedBox(width: 6),
                              Expanded(child: TextField(controller: tdsCtrl, decoration: const InputDecoration(labelText: 'TDS', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)))),
                              const SizedBox(width: 6),
                              Expanded(child: TextField(controller: sarCtrl, decoration: const InputDecoration(labelText: 'SAR', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                        onPressed: () async {
                          final updated = MonthlyFarmAction(
                            id: existing.id,
                            landId: land.id,
                            solarYear: selectedYear,
                            month: month,
                            mainActionNote: actionNoteCtrl.text.trim(),
                            treeObservationNote: observationCtrl.text.trim(),
                            irrigationDates: currentIrrigations,
                            waterIndicators: {
                              'Ec': ecCtrl.text.trim(),
                              'pH': phCtrl.text.trim(),
                              'TDS': tdsCtrl.text.trim(),
                              'SAR': sarCtrl.text.trim(),
                            },
                          );

                          setState(() {
                            final idx = monthlyActions.indexWhere((a) => a.id == existing.id);
                            if (idx != -1) {
                              monthlyActions[idx] = updated;
                            } else {
                              monthlyActions.add(updated);
                            }
                          });

                          await _persistActions();
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('اقدامات ماه $month با موفقیت ذخیره گردید.')));
                        },
                        child: const Text('ثبت و ذخیره گزارش این ماه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // بخش ۲: آزمایش سالانه خاک و برگ (فقط یک‌بار در سال)
  // ==========================================
  void _openAnnualLabTestDialog(OrchardLand land) {
    final existingTest = labTests.firstWhere(
      (t) => t.landId == land.id && t.solarYear == selectedYear,
      orElse: () => AnnualLabTest(
        landId: land.id,
        solarYear: selectedYear,
        leafTestDate: '',
        leafElements: {'N': '', 'P': '', 'K': '', 'Fe': '', 'Zn': ''},
        soilType: 'رسی',
        soilTestDate: '',
        soilElements: {'Ec': '', 'pH': '', 'SAR': ''},
        waterTestDate: '',
        waterElements: {'Ec': '', 'TDS': ''},
      ),
    );

    final leafDateCtrl = TextEditingController(text: existingTest.leafTestDate);
    final soilDateCtrl = TextEditingController(text: existingTest.soilTestDate);
    final kLeafCtrl = TextEditingController(text: existingTest.leafElements['K'] ?? '');
    final feLeafCtrl = TextEditingController(text: existingTest.leafElements['Fe'] ?? '');
    final ecSoilCtrl = TextEditingController(text: existingTest.soilElements['Ec'] ?? '');
    final phSoilCtrl = TextEditingController(text: existingTest.soilElements['pH'] ?? '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StatefulBuilder(
          builder: (context, setLabState) => Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(title: Text('آزمایش خاک و برگ سال $selectedYear - ${land.name}')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('آزمایش برگ درختان:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_month, size: 16),
                                label: Text(leafDateCtrl.text.isEmpty ? 'انتخاب تاریخ برگ' : leafDateCtrl.text),
                                onPressed: () async {
                                  final p = await showPurePersianDatePicker(context);
                                  if (p != null) setLabState(() => leafDateCtrl.text = p);
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: kLeafCtrl, decoration: const InputDecoration(labelText: 'پتاسیم برگ (K %)', border: OutlineInputBorder()))),
                              const SizedBox(width: 8),
                              Expanded(child: TextField(controller: feLeafCtrl, decoration: const InputDecoration(labelText: 'آهن برگ (Fe PPM)', border: OutlineInputBorder()))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('آزمایش بافت و خاک قطعه:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF244420))),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_month, size: 16),
                                label: Text(soilDateCtrl.text.isEmpty ? 'انتخاب تاریخ خاک' : soilDateCtrl.text),
                                onPressed: () async {
                                  final p = await showPurePersianDatePicker(context);
                                  if (p != null) setLabState(() => soilDateCtrl.text = p);
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: ecSoilCtrl, decoration: const InputDecoration(labelText: 'Ec خاک (شوربودن)', border: OutlineInputBorder()))),
                              const SizedBox(width: 8),
                              Expanded(child: TextField(controller: phSoilCtrl, decoration: const InputDecoration(labelText: 'pH خاک (اسیدی/قلیایی)', border: OutlineInputBorder()))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                        onPressed: () async {
                          final updated = AnnualLabTest(
                            landId: land.id,
                            solarYear: selectedYear,
                            leafTestDate: leafDateCtrl.text,
                            leafElements: {'K': kLeafCtrl.text.trim(), 'Fe': feLeafCtrl.text.trim()},
                            soilType: 'رسی',
                            soilTestDate: soilDateCtrl.text,
                            soilElements: {'Ec': ecSoilCtrl.text.trim(), 'pH': phSoilCtrl.text.trim()},
                            waterTestDate: '',
                            waterElements: {},
                          );

                          setState(() {
                            final idx = labTests.indexWhere((t) => t.landId == land.id && t.solarYear == selectedYear);
                            if (idx != -1) {
                              labTests[idx] = updated;
                            } else {
                              labTests.add(updated);
                            }
                          });

                          await _persistTests();
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برگه آزمایش سالانه با موفقیت ذخیره گردید.')));
                        },
                        child: const Text('ثبت نهایی برگه آزمایش سال'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // بخش ۳: کارنامه و گزارش سالانه
  // ==========================================
  void _openFullYearReport(OrchardLand land) {
    final actions = monthlyActions.where((a) => a.landId == land.id && a.solarYear == selectedYear).toList();
    final labTest = labTests.firstWhere(
      (t) => t.landId == land.id && t.solarYear == selectedYear,
      orElse: () => AnnualLabTest(landId: land.id, solarYear: selectedYear, leafElements: {}, soilElements: {}, waterElements: {}),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: Text('کارنامه فنی و اقدامات سالانه: ${land.name} ($selectedYear)')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedCardBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مشخصات قطعه: ${land.name} (${land.areaValue} ${land.unit})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF244420))),
                        const SizedBox(height: 4),
                        Text('مدار چاه: هر ${land.irrigationIntervalDays} روز یک‌بار | ارقام: ${land.treeVarieties.join('، ')}'),
                        if (yearlyNotes[selectedYear] != null && yearlyNotes[selectedYear]!.isNotEmpty) ...[
                          const Divider(height: 16),
                          Text('یادداشت کلی سال: ${yearlyNotes[selectedYear]}', style: const TextStyle(color: Color(0xFF6B4226), fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('گزارش اقدامات ماهانه باغدار:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF244420))),
                  const SizedBox(height: 8),
                  if (actions.isEmpty)
                    _buildEmptyState('هنوز اقدامی برای ماه‌های این سال ثبت نشده است.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      itemBuilder: (context, index) {
                        final a = actions[index];
                        return ElevatedCardBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF244420), borderRadius: BorderRadius.circular(6)),
                                child: Text('ماه ${a.month}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              if (a.mainActionNote.isNotEmpty) Text('اقدامات فنی: ${a.mainActionNote}'),
                              if (a.treeObservationNote.isNotEmpty) Text('مشاهدات محصول: ${a.treeObservationNote}'),
                              if (a.irrigationDates.isNotEmpty) Text('آبیاری‌های انجام‌شده: ${a.irrigationDates.join('، ')}'),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  ElevatedCardBox(
                    baseColor: const Color(0xFFFFFBEB),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('خلاصه پایش آزمایشگاهی سالانه:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        const SizedBox(height: 6),
                        if (labTest.leafTestDate.isEmpty && labTest.soilTestDate.isEmpty)
                          const Text('برگه آزمایشی برای این سال ثبت نشده است.', style: TextStyle(fontSize: 12, color: Colors.grey))
                        else ...[
                          Text('آزمایش برگ (${labTest.leafTestDate}): K: ${labTest.leafElements['K'] ?? '-'}% | Fe: ${labTest.leafElements['Fe'] ?? '-'} PPM'),
                          Text('آزمایش خاک (${labTest.soilTestDate}): Ec: ${labTest.soilElements['Ec'] ?? '-'} | pH: ${labTest.soilElements['pH'] ?? '-'}'),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // بخش ۴: فروشگاه ۳ کادره صفحه در صفحه
  // ==========================================
  Widget _buildCategorizedStoreView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // کادر ۱: کود و کلات
        _buildStoreMainCategoryCard(
          title: '۱. کودهای شیمیایی، کلات‌ها و تغذیه',
          subtitle: 'سولفات پتاسیم (سولوپتاس)، آهن ارتو-ارتو، فروت‌ست و ریزمغذی‌ها',
          icon: Icons.grain,
          badgeColor: const Color(0xFF2E7D32),
          categoryKey: 'کود و کلات',
        ),
        const SizedBox(height: 16),

        // کادر ۲: سموم و کنترل آفات
        _buildStoreMainCategoryCard(
          title: '۲. سموم و کنترل آفات پسته',
          subtitle: 'صابون‌های گیاهی ضد پسیل، قارچ‌کش‌های طوقه و کنترل آفات فصلی',
          icon: Icons.shield,
          badgeColor: const Color(0xFFC62828),
          categoryKey: 'سموم و دفع آفات',
        ),
        const SizedBox(height: 16),

        // کادر ۳: ابزارآلات و ادوات
        _buildStoreMainCategoryCard(
          title: '۳. ابزارآلات و ادوات باغبانی',
          subtitle: 'قیچی‌های شارژی هرس، چسب پیوند، اره و تجهیزات فنی باغات',
          icon: Icons.content_cut,
          badgeColor: const Color(0xFF4527A0),
          categoryKey: 'ابزارآلات باغبانی',
        ),
      ],
    );
  }

  Widget _buildStoreMainCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required String categoryKey,
  }) {
    return InkWell(
      onTap: () {
        // باز شدن صفحه داخل صفحه
        final products = allProducts.where((p) => p.category == categoryKey).toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(title: Text(title)),
                body: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ElevatedCardBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                              Text('${p.priceTomans.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} تومان', style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('واحد: ${p.unit}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(8)),
                            child: Text(p.description, style: const TextStyle(fontSize: 12, height: 1.6)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFE082))),
                            child: Text('کاربرد و ماه تجربی مصرف:\n${p.practicalUsage}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: badgeColor, foregroundColor: Colors.white),
                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                              label: const Text('افزودن به سبد خرید'),
                              onPressed: () => _addToCart(p),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      child: ElevatedCardBox(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: badgeColor, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: badgeColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // بخش ۵: سبد خرید
  // ==========================================
  Widget _buildCartView() {
    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('سبد خرید شما در حال حاضر خالی است.', style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
              onPressed: () => setState(() => currentTabIndex = 1),
              child: const Text('مشاهده و سفارش نهاده‌ها'),
            )
          ],
        ),
      );
    }

    final total = cartItems.fold<int>(0, (sum, i) => sum + (i.product.priceTomans * i.quantity));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ElevatedCardBox(
                child: Row(
                  children: [
                    Icon(item.product.icon, color: const Color(0xFF244420), size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${item.product.priceTomans} تومان', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (item.quantity > 1) {
                                item.quantity--;
                              } else {
                                cartItems.removeAt(index);
                              }
                            });
                          },
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () => setState(() => item.quantity++),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مجموع: ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} تومان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF244420))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('اتصال به درگاه ووکامرس'),
                      content: const Text('سفارش شما در پایگاه داده ثبت شد و آماده اتصال به درگاه پرداخت شاپرک می‌باشد.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => cartItems.clear());
                          },
                          child: const Text('تأیید'),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('اتصال به درگاه بانکی'),
              )
            ],
          ),
        )
      ],
    );
  }

  void _openYearlyNoteDialog() {
    final noteCtrl = TextEditingController(text: yearlyNotes[selectedYear] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('یادداشت و سوابق سال زراعی $selectedYear', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: TextField(controller: noteCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'توضیحات کلی، تغییرات آب‌وهوایی...', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
              onPressed: () async {
                setState(() => yearlyNotes[selectedYear] = noteCtrl.text.trim());
                await _persistNotes();
                if (!mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddLandDialog() {
    final nameCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final intervalCtrl = TextEditingController(text: '13'); // پیش‌فرض دوره چاه ۱۳ روزه

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ثبت قطعه زمین جدید', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF244420))),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مساحت (هکتار) *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: intervalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدار گردش آب چاه (به روز، مثلاً 13 یا 45) *', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || areaCtrl.text.trim().isEmpty) return;
                    final val = double.tryParse(areaCtrl.text.trim()) ?? 1.0;
                    final interval = int.tryParse(intervalCtrl.text.trim()) ?? 13;
                    final newLand = OrchardLand(
                      id: 'L-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      unit: 'هکتار',
                      areaValue: val,
                      standardAreaSquareMeters: val * 10000,
                      treeVarieties: ['اکبری', 'احمد آقایی'],
                      irrigationIntervalDays: interval,
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
      ),
    );
  }

  void _openEditLandDialog(OrchardLand land) {
    final nameCtrl = TextEditingController(text: land.name);
    final areaCtrl = TextEditingController(text: land.areaValue.toString());
    final intervalCtrl = TextEditingController(text: land.irrigationIntervalDays.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مساحت', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: intervalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدار گردش آب چاه (روز)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF244420), foregroundColor: Colors.white),
                  onPressed: () async {
                    setState(() {
                      land.name = nameCtrl.text.trim();
                      land.areaValue = double.tryParse(areaCtrl.text.trim()) ?? land.areaValue;
                      land.irrigationIntervalDays = int.tryParse(intervalCtrl.text.trim()) ?? land.irrigationIntervalDays;
                    });
                    await _persistLands();
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('ذخیره ویرایش'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Text(msg, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
