import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';

// ==================== موتور و ویجت تقویم شمسی نامحدود ====================
Future<String?> showJalaliDatePicker(BuildContext context, {int? initialYear}) async {
  final now = Jalali.now();
  int selectedYear = initialYear ?? now.year;
  int selectedMonth = now.month;
  int selectedDay = now.day;

  final monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final tempDate = Jalali(selectedYear, selectedMonth);
          int maxDays = tempDate.monthLength;
          if (selectedDay > maxDays) selectedDay = maxDays;

          return AlertDialog(
            title: const Text('انتخاب تاریخ در تقویم شمسی', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setDialogState(() => selectedYear--),
                      ),
                      Text('سال $selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() => selectedYear++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<int>(
                        value: selectedDay,
                        items: List.generate(maxDays, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedDay = v!),
                      ),
                      DropdownButton<int>(
                        value: selectedMonth,
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(monthNames[m - 1]),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedMonth = v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () {
                  final j = Jalali(selectedYear, selectedMonth, selectedDay);
                  String m = j.month < 10 ? '0${j.month}' : '${j.month}';
                  String d = j.day < 10 ? '0${j.day}' : '${j.day}';
                  Navigator.pop(context, '${j.year}/$m/$d');
                },
                child: const Text('تأیید'),
              ),
            ],
          );
        },
      );
    },
  );
}

// ==================== اجرای اصلی برنامه ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

// ==================== صفحه ثبت نام / ورود ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _province = TextEditingController();
  final _city = TextEditingController();

  Future<void> _submit() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نام و شماره همراه ضروری هستند')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name.text.trim());
    await prefs.setString('user_phone', _phone.text.trim());
    await prefs.setString('user_province', _province.text.trim());
    await prefs.setString('user_city', _city.text.trim());

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => HomeScreen(
          userName: _name.text.trim(),
          userPhone: _phone.text.trim(),
          userProvince: _province.text.trim(),
          userCity: _city.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.park, size: 75, color: Color(0xFF1B5E20)),
              const SizedBox(height: 12),
              const Text('سامانه هوشمند باغ پسته', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: _name, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی باغدار', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _phone, keyboardType: TextInputType.phone, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'شماره تماس', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _province, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'استان', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _city, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'شهرستان', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submit,
                child: const Text('ورود به سامانه'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== مدل قطعه زمین ====================
class LandItem {
  final String id;
  final String name;
  final double area;
  final String unit;
  final String varieties;
  final int irrigationInterval;

  LandItem({
    required this.id,
    required this.name,
    required this.area,
    required this.unit,
    required this.varieties,
    required this.irrigationInterval,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'area': area,
        'unit': unit,
        'varieties': varieties,
        'irrigationInterval': irrigationInterval,
      };

  factory LandItem.fromMap(Map<String, dynamic> map) => LandItem(
        id: map['id'],
        name: map['name'],
        area: (map['area'] as num).toDouble(),
        unit: map['unit'],
        varieties: map['varieties'] ?? '',
        irrigationInterval: map['irrigationInterval'] ?? 13,
      );
}

// ==================== صفحه اول: لیست قطعات و گزارش سالیانه باغات ====================
class HomeScreen extends StatefulWidget {
  final String userName;
  final String userPhone;
  final String userProvince;
  final String userCity;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userPhone,
    required this.userProvince,
    required this.userCity,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LandItem> _lands = [];

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  Future<void> _loadLands() async {
    final prefs = await SharedPreferences.getInstance();
    final landsString = prefs.getString('saved_lands');
    if (landsString != null) {
      final List decoded = jsonDecode(landsString);
      setState(() {
        _lands = decoded.map((item) => LandItem.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveLands() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_lands', jsonEncode(_lands.map((e) => e.toMap()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.park, color: Color(0xFF1B5E20), size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('باغدار: ${widget.userName}', style: const TextStyle(fontSize: 15)),
                Text('${widget.userProvince} - ${widget.userCity}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        onPressed: () async {
          final res = await Navigator.push<LandItem>(
            context,
            MaterialPageRoute(builder: (c) => const AddLandScreen()),
          );
          if (res != null) {
            setState(() => _lands.add(res));
            _saveLands();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('ثبت قطعه زمین'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.analytics, color: Colors.amber.shade900, size: 30),
                title: const Text('گزارش‌گیری جامع سالیانه باغات', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('مقایسه عملکرد، تناژ و آزمایشات هر سال'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  if (_lands.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ابتدا حداقل یک قطعه زمین ثبت کنید')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => GlobalAnnualReportScreen(lands: _lands)),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _lands.isEmpty
                ? const Center(child: Text('هنوز قطعه زمینی ثبت نشده است'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _lands.length,
                    itemBuilder: (context, index) {
                      final land = _lands[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.park, color: Color(0xFF1B5E20)),
                          ),
                          title: Text(land.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('مساحت: ${land.area} ${land.unit} | مدار آب: ${land.irrigationInterval} روزه\nارقام: ${land.varieties}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (c) => LandHubScreen(land: land)),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== صفحه هاب قطعه زمین ====================
class LandHubScreen extends StatelessWidget {
  final LandItem land;
  const LandHubScreen({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قطعه: ${land.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuItem(
            context,
            icon: Icons.calendar_month,
            title: 'پرونده اقدامات ماهانه و تقویم آبیاری',
            sub: 'محاسبه خودکار دوره‌ها بر مدار چاه با تقویم شمسی',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => MonthlyActionsScreen(land: land)),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.scale,
            title: 'ثبت تناژ و میزان محصول سالانه',
            sub: 'پسته تر، خشک، درصد پوکی و محاسبه عملکرد هر درخت',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => YieldRecordScreen(land: land)),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.science,
            title: 'آزمایشات آب، خاک و برگ',
            sub: 'ثبت یک پرونده آزمایشی برای هر سال زراعی',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => LabTestsScreen(land: land)),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.analytics,
            title: 'گزارش‌گیری جامع سالیانه این قطعه',
            sub: 'مشاهده پرونده کامل و مقایسه عملکرد زراعی',
            color: Colors.amber.shade900,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => AnnualReportScreen(land: land)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon, required String title, required String sub, required VoidCallback onTap, Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: (color ?? const Color(0xFF1B5E20)).withOpacity(0.12),
          child: Icon(icon, color: color ?? const Color(0xFF1B5E20)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(sub, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ==================== صفحه اقدامات ماهانه + تقویم آبیاری هوشمند ====================
class MonthlyActionsScreen extends StatefulWidget {
  final LandItem land;
  const MonthlyActionsScreen({super.key, required this.land});

  @override
  State<MonthlyActionsScreen> createState() => _MonthlyActionsScreenState();
}

class _MonthlyActionsScreenState extends State<MonthlyActionsScreen> {
  int _selectedYear = Jalali.now().year;
  String _selectedMonth = 'فروردین';
  final _actions = TextEditingController();
  final _observations = TextEditingController();
  List<String> _irrigations = [];

  final List<String> _months = const [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _key => 'actions_${widget.land.id}_${_selectedYear}_$_selectedMonth';

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw);
      _actions.text = map['actions'] ?? '';
      _observations.text = map['obs'] ?? '';
      _irrigations = List<String>.from(map['irrigations'] ?? []);
    } else {
      _actions.clear();
      _observations.clear();
      _irrigations = [];
    }
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'actions': _actions.text,
      'obs': _observations.text,
      'irrigations': _irrigations,
    };
    await prefs.setString(_key, jsonEncode(data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرونده ماه ذخیره شد')));
  }

  void _generateIrrigations(String startDateStr) {
    List<String> parts = startDateStr.split('/');
    int y = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    int d = int.parse(parts[2]);

    Jalali current = Jalali(y, m, d);
    int interval = widget.land.irrigationInterval;
    if (interval <= 0) interval = 13;

    List<String> generated = [];
    while (current.year == y) {
      String mStr = current.month < 10 ? '0${current.month}' : '${current.month}';
      String dStr = current.day < 10 ? '0${current.day}' : '${current.day}';
      generated.add('${current.year}/$mStr/$dStr');
      current = current + interval;
    }

    setState(() {
      for (var date in generated) {
        if (!_irrigations.contains(date)) {
          _irrigations.add(date);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اقدامات: ${widget.land.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() => _selectedYear--);
                          _loadData();
                        },
                      ),
                      Text('سال $_selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _selectedYear++);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(labelText: 'ماه زراعی', border: OutlineInputBorder()),
                    items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) {
                      _selectedMonth = v!;
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _actions,
              maxLines: 3,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'عملیات زراعی (کود، سم، هرس، محلول‌پاشی)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _observations,
              maxLines: 2,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'مشاهدات میدانی درختان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تقویم آبیاری (مدار گردش آب: ${widget.land.irrigationInterval} روزه)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            String? picked = await showJalaliDatePicker(context, initialYear: _selectedYear);
                            if (picked != null && !_irrigations.contains(picked)) {
                              setState(() => _irrigations.add(picked));
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('ثبت تک‌نوبت'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            String? firstDate = await showJalaliDatePicker(context, initialYear: _selectedYear);
                            if (firstDate != null) {
                              _generateIrrigations(firstDate);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('نوبت‌های مدار آبیاری تا آخر سال خودکار افزوده شدند')),
                              );
                            }
                          },
                          icon: const Icon(Icons.auto_mode, size: 18),
                          label: const Text('محاسبه خودکار دوره'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _irrigations.isEmpty
                        ? const Text('هیچ تاریخی در تقویم آبیاری ثبت نشده است', style: TextStyle(color: Colors.grey, fontSize: 12))
                        : Wrap(
                            spacing: 8,
                            children: _irrigations
                                .map((d) => Chip(
                                      label: Text(d),
                                      onDeleted: () => setState(() => _irrigations.remove(d)),
                                    ))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveData,
              child: const Text('ذخیره اطلاعات ماه'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== صفحه ثبت تناژ و عملکرد درخت ====================
class YieldRecordScreen extends StatefulWidget {
  final LandItem land;
  const YieldRecordScreen({super.key, required this.land});

  @override
  State<YieldRecordScreen> createState() => _YieldRecordScreenState();
}

class _YieldRecordScreenState extends State<YieldRecordScreen> {
  int _selectedYear = Jalali.now().year;
  final _treesCount = TextEditingController();
  final _wetYield = TextEditingController();
  final _dryYield = TextEditingController();
  final _hollowPercent = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadYield();
  }

  String get _key => 'yield_${widget.land.id}_$_selectedYear';

  Future<void> _loadYield() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw);
      _treesCount.text = map['trees'] ?? '';
      _wetYield.text = map['wet'] ?? '';
      _dryYield.text = map['dry'] ?? '';
      _hollowPercent.text = map['hollow'] ?? '';
      _notes.text = map['notes'] ?? '';
    } else {
      _treesCount.clear();
      _wetYield.clear();
      _dryYield.clear();
      _hollowPercent.clear();
      _notes.clear();
    }
    setState(() {});
  }

  Future<void> _saveYield() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'trees': _treesCount.text.trim(),
      'wet': _wetYield.text.trim(),
      'dry': _dryYield.text.trim(),
      'hollow': _hollowPercent.text.trim(),
      'notes': _notes.text.trim(),
    };
    await prefs.setString(_key, jsonEncode(data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تناژ و عملکرد محصول ذخیره شد')));
  }

  @override
  Widget build(BuildContext context) {
    double dry = double.tryParse(_dryYield.text) ?? 0;
    int trees = int.tryParse(_treesCount.text) ?? 0;
    double yieldPerTree = (trees > 0 && dry > 0) ? (dry / trees) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('ثبت محصول و عملکرد سالانه')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() => _selectedYear--);
                    _loadYield();
                  },
                ),
                Text('سال برداشت: $_selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _selectedYear++);
                    _loadYield();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _treesCount,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'تعداد درختان بارده مبنا', suffixText: 'اصل', border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wetYield,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'وزن پسته تر (کیلوگرم)', suffixText: 'کیلوگرم', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dryYield,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'وزن پسته خشک نهایی (کیلوگرم)', suffixText: 'کیلوگرم', border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hollowPercent,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'درصد پوکی پسته', suffixText: '%', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (yieldPerTree > 0)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('میانگین باردهی هر درخت:'),
                      Text('${yieldPerTree.toStringAsFixed(2)} کیلوگرم خشک', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'توضیحات (انس پسته، سال باردهی اون/آف)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveYield,
              child: const Text('ثبت و ذخیره عملکرد'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== صفحه آزمایشات آب، خاک و برگ (متمرکز سالانه) ====================
class LabTestsScreen extends StatefulWidget {
  final LandItem land;
  const LabTestsScreen({super.key, required this.land});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  int _selectedYear = Jalali.now().year;
  final _soilEc = TextEditingController();
  final _soilPh = TextEditingController();
  final _waterEc = TextEditingController();
  final _leafK = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLab();
  }

  String get _key => 'lab_${widget.land.id}_$_selectedYear';

  Future<void> _loadLab() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw);
      _soilEc.text = map['soilEc'] ?? '';
      _soilPh.text = map['soilPh'] ?? '';
      _waterEc.text = map['waterEc'] ?? '';
      _leafK.text = map['leafK'] ?? '';
    } else {
      _soilEc.clear();
      _soilPh.clear();
      _waterEc.clear();
      _leafK.clear();
    }
    setState(() {});
  }

  Future<void> _saveLab() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'soilEc': _soilEc.text.trim(),
      'soilPh': _soilPh.text.trim(),
      'waterEc': _waterEc.text.trim(),
      'leafK': _leafK.text.trim(),
    };
    await prefs.setString(_key, jsonEncode(data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آزمایشات این سال زراعی ذخیره گردید')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('آزمایشات سالانه آب، خاک و برگ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() => _selectedYear--);
                    _loadLab();
                  },
                ),
                Text('سال زراعی آزمایش: $_selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _selectedYear++);
                    _loadLab();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _soilEc, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'EC خاک (شوری dS/m)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _soilPh, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'pH اسیدیته خاک', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _waterEc, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'EC آب چاه (میکروموس)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _leafK, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'پتاسیم برگ (K %)', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveLab,
              child: const Text('ذخیره آزمایشات سال'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== صفحه گزارش سالیانه تک‌قطعه ====================
class AnnualReportScreen extends StatefulWidget {
  final LandItem land;
  const AnnualReportScreen({super.key, required this.land});

  @override
  State<AnnualReportScreen> createState() => _AnnualReportScreenState();
}

class _AnnualReportScreenState extends State<AnnualReportScreen> {
  int _selectedYear = Jalali.now().year;
  Map<String, dynamic>? _yieldData;
  Map<String, dynamic>? _labData;
  Map<String, Map<String, dynamic>> _monthlyActions = {};
  bool _loading = false;

  final List<String> _months = const [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();

    final yieldRaw = prefs.getString('yield_${widget.land.id}_$_selectedYear');
    _yieldData = yieldRaw != null ? jsonDecode(yieldRaw) : null;

    final labRaw = prefs.getString('lab_${widget.land.id}_$_selectedYear');
    _labData = labRaw != null ? jsonDecode(labRaw) : null;

    _monthlyActions.clear();
    for (String m in _months) {
      final mRaw = prefs.getString('actions_${widget.land.id}_${_selectedYear}_$m');
      if (mRaw != null) {
        _monthlyActions[m] = jsonDecode(mRaw);
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('گزارش سالیانه قطعه ${widget.land.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() => _selectedYear--);
                          _fetchReport();
                        },
                      ),
                      Text('گزارش سال زراعی: $_selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _selectedYear++);
                          _fetchReport();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('میزان تناژ و محصول ثبت‌شده', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          Text('• درختان بارده: ${_yieldData?['trees'] ?? "ثبت نشده"} اصل'),
                          Text('• پسته تر: ${_yieldData?['wet'] ?? "ثبت نشده"} کیلوگرم'),
                          Text('• پسته خشک: ${_yieldData?['dry'] ?? "ثبت نشده"} کیلوگرم'),
                          Text('• درصد پوکی: ${_yieldData?['hollow'] ?? "-"} %'),
                          Text('• نکات: ${_yieldData?['notes'] ?? "ندارد"}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('آزمایشات خاک، آب و برگ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          Text('• EC خاک: ${_labData?['soilEc'] ?? "-"} | pH خاک: ${_labData?['soilPh'] ?? "-"}'),
                          Text('• EC آب چاه: ${_labData?['waterEc'] ?? "-"}'),
                          Text('• پتاسیم برگ (K): ${_labData?['leafK'] ?? "-"} %'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('خلاصه اقدامات ماه‌های سال:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _monthlyActions.isEmpty
                      ? const Text('در این سال گزارشی برای ماه‌ها ثبت نشده است', style: TextStyle(color: Colors.grey))
                      : Column(
                          children: _monthlyActions.entries.map((entry) {
                            final month = entry.key;
                            final data = entry.value;
                            final irrigations = (data['irrigations'] as List?) ?? [];
                            return Card(
                              child: ExpansionTile(
                                leading: const Icon(Icons.check_circle_outline, color: Color(0xFF1B5E20)),
                                title: Text('ماه $month', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('نوبت‌های آبیاری: ${irrigations.length} نوبت'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text('اقدامات: ${data['actions'] ?? "ثبت نشده"}'),
                                        Text('مشاهدات: ${data['obs'] ?? "ندارد"}'),
                                        Text('آبیاری‌ها: ${irrigations.join(' ، ')}'),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}

// ==================== صفحه گزارش کل باغات در صفحه اول ====================
class GlobalAnnualReportScreen extends StatefulWidget {
  final List<LandItem> lands;
  const GlobalAnnualReportScreen({super.key, required this.lands});

  @override
  State<GlobalAnnualReportScreen> createState() => _GlobalAnnualReportScreenState();
}

class _GlobalAnnualReportScreenState extends State<GlobalAnnualReportScreen> {
  int _selectedYear = Jalali.now().year;
  Map<String, Map<String, dynamic>> _allYields = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchGlobal();
  }

  Future<void> _fetchGlobal() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _allYields.clear();

    for (var l in widget.lands) {
      final yRaw = prefs.getString('yield_${l.id}_$_selectedYear');
      if (yRaw != null) {
        _allYields[l.id] = jsonDecode(yRaw);
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش سالیانه تمام باغات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() => _selectedYear--);
                        _fetchGlobal();
                      },
                    ),
                    Text('سال زراعی: $_selectedYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() => _selectedYear++);
                        _fetchGlobal();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...widget.lands.map((land) {
                  final y = _allYields[land.id];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('قطعه: ${land.name} (${land.area} ${land.unit})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          Text('• پسته تر: ${y?['wet'] ?? "ثبت نشده"} کیلوگرم'),
                          Text('• پسته خشک: ${y?['dry'] ?? "ثبت نشده"} کیلوگرم'),
                          Text('• درصد پوکی: ${y?['hollow'] ?? "-"} %'),
                          Text('• نکات: ${y?['notes'] ?? "ندارد"}'),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

// ==================== صفحه افزودن قطعه زمین ====================
class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _varieties = TextEditingController();
  final _interval = TextEditingController(text: '13');
  String _unit = 'هکتار';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت قطعه زمین')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'نام قطعه زمین', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(controller: _area, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'مساحت', border: OutlineInputBorder())),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'هکتار', child: Text('هکتار')),
                      DropdownMenuItem(value: 'قصب', child: Text('قصب')),
                      DropdownMenuItem(value: 'متر', child: Text('متر')),
                    ],
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _varieties, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'ارقام پیوند', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _interval, keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'مدار گردش آب چاه (روز)', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_name.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    LandItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _name.text.trim(),
                      area: double.tryParse(_area.text) ?? 0,
                      unit: _unit,
                      varieties: _varieties.text.trim(),
                      irrigationInterval: int.tryParse(_interval.text) ?? 13,
                    ),
                  );
                }
              },
              child: const Text('ثبت قطعه زمین'),
            ),
          ],
        ),
      ),
    );
  }
}
