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
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A8F53),
          primary: const Color(0xFF4A7C43),
          secondary: const Color(0xFF6D4C41),
        ),
        fontFamily: 'Tahoma',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A7C43),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const AuthGateScreen(),
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
  final String role; // "باغدار" یا "مشاور/مدیر"

  UserProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.province,
    required this.city,
    required this.role,
  });
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

// تقویم شمسی پویا
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
                'تاریخ انتخاب‌شده: $selYear/${selMonth.toString().padLeft(2, '0')}/${selDay.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A7C43)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('انصراف')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C43), foregroundColor: Colors.white),
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
// صفحه ورود هوشمند با استان و شهر و تایید مدیر
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
                    height: 230,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A7C43),
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1543257580-7269da773bf5?auto=format&fit=crop&w=800&q=80'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                  ),
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'سامانه هوشمند باغات پسته',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ثبت اطلاعات کاربری و ورود', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      decoration: const InputDecoration(
                        labelText: 'شماره همراه (مثال: 09123456789) *',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedProvince,
                            items: iranProvinces.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (prov) {
                              if (prov != null) {
                                setState(() {
                                  selectedProvince = prov;
                                  selectedCity = iranProvinces[prov]!.first;
                                });
                              }
                            },
                            decoration: const InputDecoration(labelText: 'استان *', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCity,
                            items: iranProvinces[selectedProvince]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (c) {
                              if (c != null) setState(() => selectedCity = c);
                            },
                            decoration: const InputDecoration(labelText: 'شهر / منطقه *', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ['باغدار', 'مشاور/مدیر'].map((r) => DropdownMenuItem(value: r, child: Text('نقش: $r'))).toList(),
                      onChanged: (v) {
                        setState(() => selectedRole = v!);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    if (selectedRole == 'مشاور/مدیر') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: adminCodeController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'کد امنیتی تأیید مدیر (Passcode) *',
                          hintText: 'کد احراز صلاحیت مشاور',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C43),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _handleLogin,
                        child: const Text('ورود به سامانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً نام و نام خانوادگی را وارد کنید.')));
      return;
    }

    final phoneRegex = RegExp(r'^09[0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره همراه باید ۱۱ رقم بوده و با ۰۹ شروع شود.')));
      return;
    }

    if (selectedRole == 'مشاور/مدیر') {
      if (adminCodeController.text.trim() != '1404') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد امنیتی تأیید مدیر نادرست است. ورود مجاز نیست.')));
        return;
      }
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
// صفحه اصلی بدون اورفلو و با سال نامحدود
// ==========================================
class MainNavigationShell extends StatefulWidget {
  final UserProfile currentUser;

  const MainNavigationShell({super.key, required this.currentUser});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int selectedYear = 1404;
  final List<int> allAvailableYears = List.generate(45, (index) => 1380 + index);

  final Map<int, String> yearlyNotes = {
    1404: 'بارندگی مناسب پاییزه - برنامه کودی پتاس و سولفات آمونیوم در دستور کار',
  };

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

  final List<MonthlyRecord> records = [];
  final List<ConsultantItem> consultantList = [
    ConsultantItem(
      rowNum: '۱',
      farmerName: 'علی احمدی',
      farmerCode: 'BA-9021',
      landId: 'L-101',
      landName: 'باغ پسته مرکزی',
      status: 'در حال بررسی',
    ),
    ConsultantItem(
      rowNum: '۲',
      farmerName: 'رضا حسینی',
      farmerCode: 'BA-8412',
      landId: 'L-102',
      landName: 'قطعه غربی',
      status: 'انجام شده',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isConsultant = widget.currentUser.role == 'مشاور/مدیر';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isConsultant ? 'کارتابل مشاور مدیریت' : 'مدیریت باغات: ${widget.currentUser.fullName}'),
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
        drawer: _buildDrawer(isConsultant),
        body: isConsultant ? _buildConsultantView() : _buildFarmerView(),
      ),
    );
  }

  Widget _buildDrawer(bool isConsultant) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF9F6F0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4A7C43)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF4A7C43), size: 40),
              ),
              accountName: Text(widget.currentUser.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('${widget.currentUser.role} | ${widget.currentUser.province} - ${widget.currentUser.city}'),
            ),
            if (!isConsultant) ...[
              _drawerItem(Icons.add_location_alt, 'افزودن زمین', () {
                Navigator.pop(context);
                _openAddLandDialog();
              }),
              _drawerItem(Icons.landscape, 'زمین‌های من', () => Navigator.pop(context)),
              _drawerItem(Icons.assignment, 'اقدامات گذشته / سال قبل', () {
                Navigator.pop(context);
                final nonDeleted = lands.where((l) => !l.isDeleted).toList();
                if (nonDeleted.isNotEmpty) {
                  _promptSelfDeclaration(nonDeleted.first);
                }
              }),
              _drawerItem(Icons.nature_people, 'جزئیات زمین من', () {
                Navigator.pop(context);
                final nonDeleted = lands.where((l) => !l.isDeleted).toList();
                if (nonDeleted.isNotEmpty) {
                  _openSelfDeclarationForm(nonDeleted.first);
                }
              }),
              _drawerItem(Icons.history_edu, 'تاریخچه من', () {
                Navigator.pop(context);
                final nonDeleted = lands.where((l) => !l.isDeleted).toList();
                if (nonDeleted.isNotEmpty) {
                  _openHistoryView(nonDeleted.first);
                }
              }),
            ] else ...[
              _drawerItem(Icons.people_alt, 'کشاورزان تحت پوشش', () => Navigator.pop(context)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A7C43)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      onTap: onTap,
    );
  }

  // حل مشکل سرریز (نوار سیاه و زرد) با Wrap
  Widget _buildFarmerView() {
    final activeLands = lands.where((l) => !l.isDeleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5A8F53)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('سال: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                  foregroundColor: const Color(0xFF6D4C41),
                  side: const BorderSide(color: Color(0xFF6D4C41)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 38),
                ),
                onPressed: _openYearlyNoteDialog,
                icon: const Icon(Icons.note_alt, size: 16),
                label: const Text('یادداشت سال', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(0, 38),
                ),
                onPressed: _openAddLandDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('افزودن زمین', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'زمین‌های ثبت‌شده من',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
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
                return _buildGlassLandCard(activeLands[index]);
              },
            ),
        ],
      ),
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
              hintText: 'توضیحات کلی، تغییرات آب‌وهوایی، برنامه کودی سال یا خسارت‌های محیطی را یادداشت کنید...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C43), foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  yearlyNotes[selectedYear] = noteCtrl.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('یادداشت سال با موفقیت ذخیره شد.')));
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassLandCard(OrchardLand land) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2D8B0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      land.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E4B28)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6D4C41), size: 20),
                      onPressed: () => _openEditLandDialog(land),
                      tooltip: 'ویرایش زمین',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'متراژ: ${land.areaValue} ${land.unit} (${land.standardAreaSquareMeters.toStringAsFixed(0)} متر مربع)',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'ارقام درختان: ${land.treeVarieties.join('، ')}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A7C43),
                          side: const BorderSide(color: Color(0xFF4A7C43)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _promptSelfDeclaration(land),
                        child: const Text('اقدامات گذشته', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A8F53),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _openSelfDeclarationForm(land),
                        child: const Text('ثبت جزئیات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4C41),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _openHistoryView(land),
                        child: const Text('تاریخچه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          backgroundColor: const Color(0xFFF9F6F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('اقدامات گذشته / سال قبل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: const Text(
            'آیا مایل به تکمیل و مشاهده اطلاعات ۶ ماهه و اقدامات گذشته خود هستید؟',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('خیر', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C43), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                _openSelfDeclarationForm(land);
              },
              child: const Text('بله', style: TextStyle(fontWeight: FontWeight.bold)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  const Text('ثبت زمین جدید در باغ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'نام زمین *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: areaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'مقدار مساحت *', border: OutlineInputBorder()),
                        ),
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
                  const Text('نوع درختان (چند انتخابی):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Wrap(
                    spacing: 8,
                    children: availableVarieties.map<Widget>((v) {
                      final isSelected = selectedVarieties.contains(v);
                      return FilterChip(
                        label: Text(v),
                        selected: isSelected,
                        selectedColor: const Color(0xFFB2D8B0),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C43), foregroundColor: Colors.white),
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty || areaCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً فیلدهای اجباری را پر کنید.')));
                              return;
                            }
                            final double? val = double.tryParse(areaCtrl.text.trim());
                            if (val == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فرمت مساحت نامعتبر است.')));
                              return;
                            }
                            final double standardSq = selectedUnit == 'هکتار' ? val * 10000 : val;
                            setState(() {
                              lands.insert(0, OrchardLand(
                                id: 'L-${DateTime.now().millisecondsSinceEpoch}',
                                name: nameCtrl.text.trim(),
                                unit: selectedUnit,
                                areaValue: val,
                                standardAreaSquareMeters: standardSq,
                                treeVarieties: selectedVarieties.isEmpty ? ['اکبری'] : selectedVarieties,
                              ));
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('زمین با موفقیت ثبت شد.')));
                          },
                          child: const Text('ذخیره'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
                    ],
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ویرایش مشخصات زمین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام زمین', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مساحت', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7C43), foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          land.name = nameCtrl.text.trim();
                          final double? v = double.tryParse(areaCtrl.text.trim());
                          if (v != null) {
                            land.areaValue = v;
                            land.standardAreaSquareMeters = selectedUnit == 'هکتار' ? v * 10000 : v;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('ذخیره تغییرات'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() => land.isDeleted = true);
                      Navigator.pop(ctx);
                    },
                    child: const Text('حذف زمین', style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
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
    final landRecords = records.where((r) => r.landId == land.id && r.solarYear == selectedYear).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: Text('تاریخچه: ${land.name} ($selectedYear)')),
            body: landRecords.isEmpty
                ? _buildEmptyState('برای این سال اطلاعاتی ثبت نشده است.')
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ردیف', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('ماه', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('نوع و تعداد', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('سن درخت', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('برگ (N, P, K)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('خاک (Ec, pH, SAR)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('آب (Ec, TDS)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('آبیاری', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('یادداشت دوره', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('عملیات', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: List.generate(landRecords.length, (idx) {
                            final r = landRecords[idx];
                            return DataRow(
                              cells: [
                                DataCell(Text((idx + 1).toString())),
                                DataCell(Text(r.month)),
                                DataCell(Text('${r.variety} (${r.treeCount} ${r.countType})')),
                                DataCell(Text('${r.ageGroup} - ${r.treeAge} ساله')),
                                DataCell(Text('N:${r.leafElements['N'] ?? '-'}% | P:${r.leafElements['P'] ?? '-'}% | K:${r.leafElements['K'] ?? '-'}%')),
                                DataCell(Text('Ec:${r.soilElements['Ec'] ?? '-'} | pH:${r.soilElements['pH'] ?? '-'} | SAR:${r.soilElements['SAR'] ?? '-'}')),
                                DataCell(Text('Ec:${r.waterElements['Ec'] ?? '-'} | TDS:${r.waterElements['TDS'] ?? '-'}')),
                                DataCell(
                                  Wrap(
                                    spacing: 4,
                                    children: r.irrigationDates.map<Widget>((d) => Chip(
                                      label: Text(d, style: const TextStyle(fontSize: 10)),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    )).toList(),
                                  ),
                                ),
                                DataCell(Text(r.periodNotes.isNotEmpty ? r.periodNotes : '-')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _openSelfDeclarationForm(land, r);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsultantView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('کارتابل مدیریت زمین‌های کشاورزان تحت نظارت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ردیف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('نام باغدار', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('شناسه', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('نام زمین', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('مشاهده جزئیات', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('وضعیت بررسی', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: consultantList.map<DataRow>((c) {
                  return DataRow(cells: [
                    DataCell(Text(c.rowNum)),
                    DataCell(Text(c.farmerName)),
                    DataCell(Text(c.farmerCode)),
                    DataCell(Text(c.landName)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye, color: Color(0xFF4A7C43)),
                        onPressed: () {
                          final targetLand = lands.firstWhere((l) => l.id == c.landId, orElse: () => lands.first);
                          _openHistoryView(targetLand);
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: c.status,
                        underline: const SizedBox(),
                        items: ['در حال بررسی', 'انجام شده'].map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: TextStyle(
                                color: s == 'انجام شده' ? Colors.green.shade700 : Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            setState(() => c.status = newStatus);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('وضعیت به "$newStatus" تغییر یافت.')),
                            );
                          }
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
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
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 10),
            Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// فرم اقدامات گذشته / سال قبل (با اصلاح هکتار/تعداد و حذف تاریخ آب)
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

  // مشخصات شمارش و تعداد متغیر
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
          title: Text(widget.recordToEdit != null ? 'ویرایش اطلاعات دوره' : 'ثبت اقدامات گذشته - ${widget.land.name}'),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (currentStep < 2) {
                      setState(() => currentStep++);
                    } else {
                      _submitRecord();
                    }
                  },
                  child: Text(
                    currentStep == 2 ? 'ثبت نهایی اطلاعات دوره' : 'مرحله بعد',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5A8F53) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('انتخاب ماه خوداظهاری (سال زراعی فعال):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }

  // تفکیک دقیق هکتار در سمت راست و تعداد پویا در سمت چپ
  Widget _buildTreeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مشخصات شمارش و نوع درخت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
          const SizedBox(height: 12),
          Row(
            children: [
              // سمت راست: نوع شمارش (نصف کادر)
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: countType,
                  items: ['هکتار', 'قفیز', 'جریب', 'دانه'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() {
                      countType = v!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'واحد شمارش', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              // سمت چپ: فیلد داینامیک بر اساس واحد انتخابی
              Expanded(
                child: TextField(
                  controller: treeCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'تعداد در $countType *',
                    border: const OutlineInputBorder(),
                  ),
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
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تاریخ آزمایش برگ:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month, color: Color(0xFF4A7C43)),
                label: Text(leafDateCtrl.text),
                onPressed: () async {
                  final picked = await showPersianDatePickerDialog(context);
                  if (picked != null) setState(() => leafDateCtrl.text = picked);
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text('عناصر آزمایش برگ (درصد % و PPM):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
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
    );
  }

  // حذف فیلد تاریخ کیفیت آب و حفظ یادداشت ۶ ماهه
  Widget _buildSoilWaterStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('آزمایش خاک', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
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
          const Text('شاخص‌های شیمیایی خاک (۱۵ مورد):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('دوره‌های آبیاری این ماه:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A8F53),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('افزودن تاریخ آبیاری', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final pickedDate = await showPersianDatePickerDialog(context);
                  if (pickedDate != null && !irrigationDates.contains(pickedDate)) {
                    setState(() {
                      irrigationDates.add(pickedDate);
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: irrigationDates.map<Widget>((date) {
              return Chip(
                label: Text(date, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    irrigationDates.remove(date);
                  });
                },
              );
            }).toList(),
          ),
          const Divider(height: 32),

          // بخش کیفیت آب با حذف دکمه تاریخ
          const Text('کیفیت آب و شاخص‌های شیمیایی:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
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

          const SizedBox(height: 24),
          const Text('یادداشت و مشاهدات شش ماهه:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
          const SizedBox(height: 8),
          TextField(
            controller: periodNotesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'علائم ظاهری برگ و تنه، میزان پیوندها، علائم آفت و یادداشت‌های ۶ ماهه را بنویسید...',
              border: OutlineInputBorder(),
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
        SnackBar(content: Text('برای سال منتخب شما اطلاعات ماه $selectedMonth ذخیره شده است لطفاً مجدداً انتخاب نمایید')),
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
