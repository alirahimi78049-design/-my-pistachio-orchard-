import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const PistachioApp());
}

class PistachioApp extends StatelessWidget {
  const PistachioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سامانه هوشمند باغات پسته',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF386641),
          primary: const Color(0xFF386641),
          secondary: const Color(0xFF6B4226),
        ),
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C5134),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black45,
        ),
      ),
      home: const AuthGateScreen(),
    );
  }
}

// ==========================================
// ویجت‌های اختصاصی عمق‌دهی بصری
// ==========================================
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
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF2C5134).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.5,
        ),
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
    this.colors = const [Color(0xFF4A7C43), Color(0xFF2E5329)],
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.35),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
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
}

class ProductItem {
  final String id;
  final String title;
  final String category;
  final int priceTomans;
  final String unit;
  final String targetElement;
  final String imageUrl;

  ProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priceTomans,
    required this.unit,
    required this.targetElement,
    required this.imageUrl,
  });
}

class CartItem {
  final ProductItem product;
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
}

class ConsultantItem {
  final String rowNum;
  final String farmerName;
  final String farmerCode;
  final String landId;
  final String landName;
  String status;

  ConsultantItem({
    required this.rowNum,
    required this.farmerName,
    required this.farmerCode,
    required this.landId,
    required this.landName,
    required this.status,
  });
}

// تقویم بازشونده شمسی پویا
Future<String?> showPersianDatePickerDialog(BuildContext context, {int initialYear = 1404}) async {
  int selYear = initialYear;
  int selMonth = 7;
  int selDay = 15;

  final months = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateDialog) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('انتخاب تاریخ شمسی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: selYear,
                    items: List.generate(45, (i) => 1380 + i).map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (v) => setStateDialog(() => selYear = v!),
                  ),
                  DropdownButton<int>(
                    value: selMonth,
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(value: m, child: Text(months[m - 1]));
                    }).toList(),
                    onChanged: (v) => setStateDialog(() => selMonth = v!),
                  ),
                  DropdownButton<int>(
                    value: selDay,
                    items: List.generate(selMonth <= 6 ? 31 : (selMonth <= 11 ? 30 : 29), (i) => i + 1).map((d) {
                      return DropdownMenuItem(value: d, child: Text('$d'));
                    }).toList(),
                    onChanged: (v) => setStateDialog(() => selDay = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'تاریخ انتخاب‌شده: $selYear/${selMonth.toString().padLeft(2, '0')}/${selDay.toString().padLeft(2, '0')} ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF386641)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('انصراف')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641), foregroundColor: Colors.white),
              onPressed: () {
                final dateStr = '$selYear/${selMonth.toString().padLeft(2, '0')}/${selDay.toString().padLeft(2, '0')}';
                Navigator.pop(ctx, dateStr);
              },
              child: const Text('تأیید'),
            )
          ],
        ),
      ),
    ),
  );
}

// ==========================================
// صفحه ورود هوشمند و معتبر
// ==========================================
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
              Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C5134),
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1543257580-7269da773bf5?auto=format&fit=crop&w=800&q=80'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                    ),
                  ),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(24),
                    child: const Text(
                      'سامانه هوشمند باغات پسته',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ],
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

  void _handleLogin() {
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => MainNavigationShell(currentUser: user)),
    );
  }
}

// ==========================================
// پوسته اصلی برنامه (داشبورد، فروشگاه، سبد و تاریخچه)
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
  final List<int> allAvailableYears = List.generate(45, (index) => 1380 + index);

  final Map<int, String> yearlyNotes = {
    1404: 'بارندگی مناسب پاییزه - برنامه کودی پتاس و سولفات آمونیوم در دستور کار',
  };

  final List<CartItem> cartItems = [];

  final List<ProductItem> storeProducts = [
    ProductItem(
      id: 'P-101',
      title: 'سودوپتاس ۵۲٪ (سولفات پتاسیم)',
      category: 'تغذیه و کود',
      priceTomans: 1850000,
      unit: 'کیسه ۲۵ کیلوگرمی',
      targetElement: 'K',
      imageUrl: 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'P-102',
      title: 'کلات آهن ۶٪ ارتو-ارتو آلمانی',
      category: 'تغذیه و کود',
      priceTomans: 950000,
      unit: 'بسته ۱ کیلوگرمی',
      targetElement: 'Fe',
      imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'P-103',
      title: 'صابون محلول‌پاشی گیاهی ضد پسیل',
      category: 'سموم و محافظت',
      priceTomans: 620000,
      unit: 'گالن ۵ لیتری',
      targetElement: '',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'P-104',
      title: 'قیچی هرس شارژی دو باتری بروس',
      category: 'ادوات باغبانی',
      priceTomans: 4800000,
      unit: 'یک ست کامل',
      targetElement: '',
      imageUrl: 'https://images.unsplash.com/photo-1617576683096-00fc8eecb3af?auto=format&fit=crop&w=300&q=80',
    ),
  ];

  final List<OrchardLand> lands = [
    OrchardLand(
      id: 'L-101',
      name: 'باغ پسته مرکزی',
      unit: 'هکتار',
      areaValue: 2.5,
      standardAreaSquareMeters: 25000.0,
      treeVarieties: ['اکبری', 'احمد آقایی'],
    ),
    OrchardLand(
      id: 'L-102',
      name: 'قطعه غربی',
      unit: 'متر مربع',
      areaValue: 7500.0,
      standardAreaSquareMeters: 7500.0,
      treeVarieties: ['کله‌قوچی', 'فندقی'],
    ),
  ];

  final List<MonthlyRecord> records = [
    MonthlyRecord(
      id: 'REC-DEMO',
      landId: 'L-101',
      solarYear: 1404,
      month: 'مهر',
      countType: 'هکتار',
      treeCount: 350,
      variety: 'اکبری',
      ageGroup: 'بارور (بیش از 8 سال)',
      treeAge: 12,
      leafTestDate: '1404/07/15',
      leafElements: {'N': '1.8', 'P': '0.12', 'K': '0.9', 'Fe': '45', 'Zn': '12'},
      soilType: 'رسی',
      soilTestDate: '1404/07/10',
      soilElements: {'Ec': '3.2', 'pH': '7.8', 'SAR': '4.1'},
      irrigationDates: ['1404/07/04', '1404/07/18'],
      waterElements: {'Ec': '2.8', 'TDS': '1800'},
      periodNotes: 'پیوندها سالم و نیاز به تغذیه پتاسه در آب استارت',
    )
  ];

  void _addToCart(ProductItem product) {
    setState(() {
      final existingIndex = cartItems.indexWhere((c) => c.product.id == product.id);
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity++;
      } else {
        cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.title} به سبد خرید افزوده شد.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConsultant = widget.currentUser.role == 'مشاور/مدیر';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isConsultant ? 'کارتابل مشاور مدیریت' : _getAppBarTitle()),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'خروج از حساب',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AuthGateScreen()),
                );
              },
            )
          ],
        ),
        body: isConsultant ? _buildConsultantView() : _buildCurrentBody(),
        bottomNavigationBar: isConsultant
            ? null
            : Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    )
                  ],
                ),
                child: NavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFD4E7D2),
                  selectedIndex: currentTabIndex,
                  onDestinationSelected: (idx) => setState(() => currentTabIndex = idx),
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.landscape_outlined),
                      selectedIcon: Icon(Icons.landscape, color: Color(0xFF2C5134)),
                      label: 'زمین‌های من',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront, color: Color(0xFF2C5134)),
                      label: 'فروشگاه نهاده‌ها',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        label: Text('${cartItems.fold<int>(0, (sum, i) => sum + i.quantity)}'),
                        isLabelVisible: cartItems.isNotEmpty,
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                      selectedIcon: Badge(
                        label: Text('${cartItems.fold<int>(0, (sum, i) => sum + i.quantity)}'),
                        isLabelVisible: cartItems.isNotEmpty,
                        child: const Icon(Icons.shopping_cart, color: Color(0xFF2C5134)),
                      ),
                      label: 'سبد خرید',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.history_edu_outlined),
                      selectedIcon: Icon(Icons.history_edu, color: Color(0xFF2C5134)),
                      label: 'تاریخچه و آزمایش',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentTabIndex) {
      case 0:
        return 'مدیریت باغات: ${widget.currentUser.fullName}';
      case 1:
        return 'فروشگاه تخصصی نهاده‌های پسته';
      case 2:
        return 'سبد خرید و تسویه‌حساب';
      case 3:
        return 'تاریخچه و تحلیل هوشمند آزمایش‌ها';
      default:
        return 'سامانه هوشمند باغات پسته';
    }
  }

  Widget _buildCurrentBody() {
    switch (currentTabIndex) {
      case 0:
        return _buildFarmerView();
      case 1:
        return _buildStoreView();
      case 2:
        return _buildCartView();
      case 3:
        return _buildAllLandsHistoryView();
      default:
        return _buildFarmerView();
    }
  }

  // تب ۱: داشبورد زمین‌ها
  Widget _buildFarmerView() {
    final activeLands = lands.where((l) => !l.isDeleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedCardBox(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderRadius: 14,
            child: Wrap(
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
                        value: selectedYear,
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
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B4226),
                    side: const BorderSide(color: Color(0xFF6B4226)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _openYearlyNoteDialog,
                  icon: const Icon(Icons.note_alt_outlined, size: 16),
                  label: const Text('یادداشت سال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
          ),
          const SizedBox(height: 10),
          const Text(
            'زمین‌های ثبت‌شده من',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5134)),
          ),
          const SizedBox(height: 12),
          if (activeLands.isEmpty)
            _buildEmptyState('هیچ زمینی برای این حساب ثبت نشده است.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeLands.length,
              itemBuilder: (context, index) {
                return _buildDeepLandCard(activeLands[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDeepLandCard(OrchardLand land) {
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1E7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco, color: Color(0xFF2C5134), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    land.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5134)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B4226), size: 20),
                onPressed: () => _openEditLandDialog(land),
                tooltip: 'ویرایش زمین',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEAE5DB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'مساحت: ${land.areaValue} ${land.unit}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Text('|', style: TextStyle(color: Colors.grey)),
                Text(
                  '(${land.standardAreaSquareMeters.toStringAsFixed(0)} متر مربع)',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'ارقام درختان: ${land.treeVarieties.join('، ')}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF386641),
                    side: const BorderSide(color: Color(0xFF386641), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _promptSelfDeclaration(land),
                  child: const Text('اقدامات گذشته', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DeepGradientButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: () => _openSelfDeclarationForm(land),
                  child: const Text('ثبت جزئیات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4226),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                  ),
                  onPressed: () => _openHistoryView(land),
                  child: const Text('تاریخچه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تب ۲: فروشگاه
  Widget _buildStoreView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ElevatedCardBox(
          baseColor: const Color(0xFFEAF4E9),
          borderRadius: 14,
          padding: const EdgeInsets.all(12),
          child: const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF2C5134)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نهاده‌های دارای استاندارد و تاییدیه کیفی با ضمانت بازگشت وجه',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F3A25)),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.65,
          ),
          itemCount: storeProducts.length,
          itemBuilder: (context, index) {
            final p = storeProducts[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: const Color(0xFFEFECE5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      p.imageUrl,
                      height: 115,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(p.unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '${p.priceTomans.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} تومان',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C5134), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: DeepGradientButton(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: () => _addToCart(p),
                            child: const Text('افزودن به سبد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // تب ۳: سبد خرید
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
            DeepGradientButton(
              onPressed: () => setState(() => currentTabIndex = 1),
              child: const Text('مشاهده و خرید نهاده‌ها'),
            )
          ],
        ),
      );
    }

    final totalAmount = cartItems.fold<int>(0, (sum, i) => sum + (i.product.priceTomans * i.quantity));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ElevatedCardBox(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(item.product.imageUrl, width: 65, height: 65, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('مجموع فاکتور سفارش:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} تومان',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5134)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DeepGradientButton(
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
                            child: const Text('تأیید پرداخت'),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Text('اتصال به درگاه بانکی شاپرک', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // تب ۴: تاریخچه
  Widget _buildAllLandsHistoryView() {
    final activeLands = lands.where((l) => !l.isDeleted).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeLands.length,
      itemBuilder: (context, idx) {
        final land = activeLands[idx];
        final landRecs = records.where((r) => r.landId == land.id && r.solarYear == selectedYear).toList();

        return ElevatedCardBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(land.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2C5134))),
                  Text('سال زراعی: $selectedYear', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Divider(height: 20),
              if (landRecs.isEmpty)
                const Text('برای این سال سابقه‌ای ثبت نشده است.', style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('آخرین خوداظهاری: ماه ${landRecs.first.month} (${landRecs.first.variety})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                              SizedBox(width: 6),
                              Text('توصیه فنی هوشمند سیستم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'بر اساس آزمایش برگ، سطح پتاسیم (K: 0.9%) کمتر از حد آستانه است.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          DeepGradientButton(
                            colors: const [Color(0xFF6B4226), Color(0xFF4A2E1A)],
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onPressed: () {
                              final potas = storeProducts.firstWhere((p) => p.targetElement == 'K');
                              _addToCart(potas);
                              setState(() => currentTabIndex = 2);
                            },
                            child: const Text('سفارش کود اصلاحی این قطعه (سودوپتاس)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
            ],
          ),
        );
      },
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
          content: TextField(
            controller: noteCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'توضیحات کلی، تغییرات آب‌وهوایی یا خسارت‌های محیطی...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            DeepGradientButton(
              onPressed: () {
                setState(() => yearlyNotes[selectedYear] = noteCtrl.text.trim());
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
    String selectedUnit = 'هکتار';
    final List<String> availableVarieties = ['اکبری', 'احمد آقایی', 'اوحدی', 'کله‌قوچی', 'فندقی', 'بادامی'];
    final List<String> selectedVarieties = <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ثبت زمین جدید در باغ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین *', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مقدار مساحت *', border: OutlineInputBorder())),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: ['هکتار', 'متر مربع'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedUnit = val);
                          },
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('نوع درختان:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Wrap(
                    spacing: 8,
                    children: availableVarieties.map<Widget>((v) {
                      final isSelected = selectedVarieties.contains(v);
                      return FilterChip(
                        label: Text(v),
                        selected: isSelected,
                        selectedColor: const Color(0xFFB5C9B3),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selectedVarieties.add(v);
                            } else {
                              selectedVarieties.remove(v);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DeepGradientButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty || areaCtrl.text.trim().isEmpty) return;
                        final val = double.tryParse(areaCtrl.text.trim()) ?? 1.0;
                        setState(() {
                          lands.insert(0, OrchardLand(
                            id: 'L-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            unit: selectedUnit,
                            areaValue: val,
                            standardAreaSquareMeters: selectedUnit == 'هکتار' ? val * 10000 : val,
                            treeVarieties: selectedVarieties.isEmpty ? ['اکبری'] : selectedVarieties,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('ذخیره زمین', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEditLandDialog(OrchardLand land) {
    final nameCtrl = TextEditingController(text: land.name);
    final areaCtrl = TextEditingController(text: land.areaValue.toString());
    String selectedUnit = land.unit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین')),
              const SizedBox(height: 12),
              TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مساحت')),
              const SizedBox(height: 16),
              DeepGradientButton(
                onPressed: () {
                  setState(() {
                    land.name = nameCtrl.text.trim();
                    final v = double.tryParse(areaCtrl.text.trim()) ?? land.areaValue;
                    land.areaValue = v;
                    land.standardAreaSquareMeters = selectedUnit == 'هکتار' ? v * 10000 : v;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('ذخیره ویرایش'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _promptSelfDeclaration(OrchardLand land) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('اقدامات گذشته / سال قبل'),
          content: const Text('آیا مایل به ثبت اطلاعات دوره‌ای هستید؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('خیر')),
            DeepGradientButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openSelfDeclarationForm(land);
              },
              child: const Text('بله'),
            ),
          ],
        ),
      ),
    );
  }

  void _openSelfDeclarationForm(OrchardLand land, [MonthlyRecord? recordToEdit]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => SelfDeclarationScreen(
          land: land,
          year: selectedYear,
          existingRecords: records,
          recordToEdit: recordToEdit,
          onSave: (newRec) {
            setState(() {
              if (recordToEdit != null) {
                final idx = records.indexWhere((r) => r.id == recordToEdit.id);
                if (idx != -1) records[idx] = newRec;
              } else {
                records.add(newRec);
              }
            });
          },
        ),
      ),
    );
  }

  void _openHistoryView(OrchardLand land) {
    setState(() => currentTabIndex = 3);
  }

  Widget _buildConsultantView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('کارتابل مشاورین تخصصی باغات پسته', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ردیف')),
                DataColumn(label: Text('باغدار')),
                DataColumn(label: Text('زمین')),
                DataColumn(label: Text('وضعیت بررسی')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('۱')),
                  DataCell(Text('علی احمدی')),
                  DataCell(Text('باغ مرکزی')),
                  DataCell(Text('در حال بررسی', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Text(msg, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// ==========================================
// فرم اقدامات گذشته
// ==========================================
class SelfDeclarationScreen extends StatefulWidget {
  final OrchardLand land;
  final int year;
  final List<MonthlyRecord> existingRecords;
  final MonthlyRecord? recordToEdit;
  final Function(MonthlyRecord) onSave;

  const SelfDeclarationScreen({
    super.key,
    required this.land,
    required this.year,
    required this.existingRecords,
    this.recordToEdit,
    required this.onSave,
  });

  @override
  State<SelfDeclarationScreen> createState() => _SelfDeclarationScreenState();
}

class _SelfDeclarationScreenState extends State<SelfDeclarationScreen> {
  int currentStep = 0;
  String selectedMonth = 'مهر';
  final List<String> months = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];

  String countType = 'هکتار';
  final treeCountCtrl = TextEditingController(text: '350');
  String variety = 'اکبری';
  String ageGroup = 'بارور (بیش از 8 سال)';
  final treeAgeCtrl = TextEditingController(text: '12');

  final leafDateCtrl = TextEditingController(text: '1404/07/15');
  final Map<String, TextEditingController> leafCtrls = {};

  String soilType = 'رسی';
  final soilDateCtrl = TextEditingController(text: '1404/07/10');
  final Map<String, TextEditingController> soilCtrls = {};

  final List<String> irrigationDates = <String>['1404/07/04', '1404/07/18'];
  final Map<String, TextEditingController> waterCtrls = {};
  final periodNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var k in ['N', 'P', 'K', 'Ca', 'Mg', 'Na', 'Cl', 'B', 'Cu', 'Zn', 'Fe', 'Mn']) {
      leafCtrls[k] = TextEditingController(text: widget.recordToEdit?.leafElements[k] ?? '1.2');
    }
    for (var k in ['Ec', 'pH', 'Ca', 'Mg', 'Na', 'SAR', 'K', 'P', 'Clay', 'Silt', 'Sand', 'Fe', 'Cu', 'Mn', 'T.N.V']) {
      soilCtrls[k] = TextEditingController(text: widget.recordToEdit?.soilElements[k] ?? '2.1');
    }
    for (var k in ['Ec', 'TDS', 'SAR', 'pH']) {
      waterCtrls[k] = TextEditingController(text: widget.recordToEdit?.waterElements[k] ?? '3.5');
    }

    if (widget.recordToEdit != null) {
      selectedMonth = widget.recordToEdit!.month;
      treeCountCtrl.text = widget.recordToEdit!.treeCount.toString();
      treeAgeCtrl.text = widget.recordToEdit!.treeAge.toString();
      variety = widget.recordToEdit!.variety;
      ageGroup = widget.recordToEdit!.ageGroup;
      countType = widget.recordToEdit!.countType;
      soilType = widget.recordToEdit!.soilType;
      leafDateCtrl.text = widget.recordToEdit!.leafTestDate;
      soilDateCtrl.text = widget.recordToEdit!.soilTestDate;
      irrigationDates.clear();
      irrigationDates.addAll(widget.recordToEdit!.irrigationDates);
      periodNotesCtrl.text = widget.recordToEdit!.periodNotes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recordToEdit != null ? 'ویرایش اقدامات گذشته' : 'ثبت اقدامات گذشته - ${widget.land.name}'),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepIndicator(0, '۱. ماه'),
                  _buildStepIndicator(1, '۲. درخت و برگ'),
                  _buildStepIndicator(2, '۳. خاک، آب و آبیاری'),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  _buildMonthStep(),
                  _buildTreeStep(),
                  _buildSoilWaterStep(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              if (currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => currentStep--),
                    child: const Text('مرحله قبل'),
                  ),
                ),
              if (currentStep > 0) const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DeepGradientButton(
                  onPressed: () {
                    if (currentStep < 2) {
                      setState(() => currentStep++);
                    } else {
                      _submitRecord();
                    }
                  },
                  child: Text(currentStep == 2 ? 'ثبت نهایی اطلاعات دوره' : 'مرحله بعد', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = currentStep == stepIndex;
    return GestureDetector(
      onTap: () => setState(() => currentStep = stepIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2C5134) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [BoxShadow(color: const Color(0xFF2C5134).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ),
    );
  }

  Widget _buildMonthStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedCardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('انتخاب ماه زراعی:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMonth,
              items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedMonth = val);
              },
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'ماه شمسی'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مشخصات شمارش و رقم درخت', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: countType,
                        items: ['هکتار', 'قفیز', 'جریب', 'دانه'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => countType = v!),
                        decoration: const InputDecoration(labelText: 'واحد شمارش', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: treeCountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'تعداد در $countType *', border: const OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: variety,
                        items: ['اکبری', 'احمد آقایی', 'اوحدی', 'کله‌قوچی', 'فندقی', 'بادامی'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => variety = v!),
                        decoration: const InputDecoration(labelText: 'نوع درخت', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: ageGroup,
                        items: ['نونهال (1 تا 3 سال)', 'جوان (4 تا 8 سال)', 'بارور (بیش از 8 سال)'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (v) => setState(() => ageGroup = v!),
                        decoration: const InputDecoration(labelText: 'گروه سنی', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: treeAgeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'سن دقیق درخت (سال) *', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          ElevatedCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تاریخ آزمایش برگ:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_month, color: Color(0xFF386641)),
                      label: Text(leafDateCtrl.text),
                      onPressed: () async {
                        final picked = await showPersianDatePickerDialog(context);
                        if (picked != null) setState(() => leafDateCtrl.text = picked);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: leafCtrls.entries.map<Widget>((e) {
                    final isPpm = ['B', 'Cu', 'Zn', 'Fe', 'Mn'].contains(e.key);
                    return SizedBox(
                      width: 105,
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          labelText: '${e.key} (${isPpm ? 'PPM' : '%'})',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilWaterStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('آزمایش خاک و بافت', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C5134))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: soilType,
                        items: ['شنی', 'رسی', 'سیلتی', 'لومی'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => soilType = v!),
                        decoration: const InputDecoration(labelText: 'نوع بافت خاک', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: Text(soilDateCtrl.text, style: const TextStyle(fontSize: 11)),
                        onPressed: () async {
                          final picked = await showPersianDatePickerDialog(context);
                          if (picked != null) setState(() => soilDateCtrl.text = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: soilCtrls.entries.map<Widget>((e) {
                    return SizedBox(
                      width: 105,
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          labelText: e.key,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ElevatedCardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('دوره‌های آبیاری این ماه:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    DeepGradientButton(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      onPressed: () async {
                        final pickedDate = await showPersianDatePickerDialog(context);
                        if (pickedDate != null && !irrigationDates.contains(pickedDate)) {
                          setState(() => irrigationDates.add(pickedDate));
                        }
                      },
                      child: const Text('افزودن تاریخ', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: irrigationDates.map<Widget>((date) {
                    return Chip(
                      backgroundColor: const Color(0xFFE8F1E7),
                      label: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => irrigationDates.remove(date)),
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                const Text('شاخص‌های شیمیایی کیفیت آب:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: waterCtrls.entries.map<Widget>((e) {
                    return SizedBox(
                      width: 110,
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          labelText: e.key,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: periodNotesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'یادداشت و مشاهدات دوره ۶ ماهه',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitRecord() {
    final isDuplicate = widget.existingRecords.any((r) =>
        r.landId == widget.land.id &&
        r.solarYear == widget.year &&
        r.month == selectedMonth &&
        r.id != widget.recordToEdit?.id);

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اطلاعات ماه $selectedMonth قبلاً ثبت شده است.')),
      );
      setState(() => currentStep = 0);
      return;
    }

    final newRecord = MonthlyRecord(
      id: widget.recordToEdit?.id ?? 'REC-${DateTime.now().millisecondsSinceEpoch}',
      landId: widget.land.id,
      solarYear: widget.year,
      month: selectedMonth,
      countType: countType,
      treeCount: int.tryParse(treeCountCtrl.text) ?? 0,
      variety: variety,
      ageGroup: ageGroup,
      treeAge: int.tryParse(treeAgeCtrl.text) ?? 0,
      leafTestDate: leafDateCtrl.text,
      leafElements: leafCtrls.map((k, v) => MapEntry(k, v.text)),
      soilType: soilType,
      soilTestDate: soilDateCtrl.text,
      soilElements: soilCtrls.map((k, v) => MapEntry(k, v.text)),
      irrigationDates: irrigationDates,
      waterElements: waterCtrls.map((k, v) => MapEntry(k, v.text)),
      periodNotes: periodNotesCtrl.text.trim(),
    );

    widget.onSave(newRecord);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اطلاعات با موفقیت ذخیره گردید.')),
    );
  }
}
