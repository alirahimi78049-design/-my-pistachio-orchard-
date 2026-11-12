import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../core/calendar/jalali_helper.dart';
import '../core/database/orchard_repository.dart';

// ==================== ۱. صفحه ثبت نام / ورود ====================
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
      body: SafeArea(
        child: Column(
          children: [
            const LiveClockBanner(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.park, size: 75, color: Color(0xFF1B5E20)),
                      const SizedBox(height: 12),
                      const Text('سامانه هوشمند باغ پسته',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextField(
                          controller: _name,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              labelText: 'نام و نام خانوادگی باغدار',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              labelText: 'شماره تماس',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: _province,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                      labelText: 'استان',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextField(
                                  controller: _city,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                      labelText: 'شهرستان',
                                      border: OutlineInputBorder()))),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۲. صفحه اصلی: لیست قطعات و وضعیت SQLite ====================
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
  List<RecordMap> _lands = [];
  int _pendingSync = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final data = await OrchardRepository.instance.getLands();
    final pending = await OrchardRepository.instance.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _lands = data;
        _pendingSync = pending;
        _loading = false;
      });
    }
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('باغدار: ${widget.userName}',
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                  Text('${widget.userProvince} - ${widget.userCity}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Chip(
              avatar: const Icon(Icons.storage, size: 15, color: Color(0xFF1B5E20)),
              label: Text('آفلاین ($_pendingSync)',
                  style: const TextStyle(fontSize: 11)),
              backgroundColor: Colors.green.shade50,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (c) => const AddLandScreen()),
          );
          if (added == true) _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('ثبت قطعه زمین'),
      ),
      body: Column(
        children: [
          const LiveClockBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading:
                    Icon(Icons.analytics, color: Colors.amber.shade900, size: 30),
                title: const Text('گزارش‌گیری جامع سالیانه باغات',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('مقایسه عملکرد، تناژ، آبیاری‌ها و آزمایشات'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  if (_lands.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('ابتدا حداقل یک قطعه زمین ثبت کنید')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => GlobalAnnualReportScreen(lands: _lands)),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _lands.isEmpty
                    ? const Center(child: Text('هنوز قطعه زمینی ثبت نشده است'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _lands.length,
                        itemBuilder: (context, index) {
                          final land = _lands[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child:
                                    Icon(Icons.park, color: Color(0xFF1B5E20)),
                              ),
                              title: Text(land['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              subtitle: Text(
                                  'مساحت: ${land['area']} ${land['unit']} | مدار آب: ${land['irrigation_interval']} روزه\nارقام: ${land['varieties'] ?? ''}'),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => LandHubScreen(land: land)),
                                );
                                _refresh();
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

// ==================== ۳. صفحه هاب قطعه زمین ====================
class LandHubScreen extends StatelessWidget {
  final RecordMap land;
  const LandHubScreen({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قطعه: ${land['name']}')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _menuItem(
                  context,
                  icon: Icons.edit_calendar,
                  title: 'گزارش اقدامات ماهانه',
                  sub: 'ثبت کوددهی، سم‌پاشی، هرس و مشاهدات هر ماه',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => MonthlyActionsScreen(land: land)),
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.water_drop,
                  title: 'مدیریت آبیاری (برنامه خودکار + ثبت واقعی)',
                  sub: 'تفکیک نوبت‌های پیش‌بینی‌شده از آبیاری‌های انجام‌شده',
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => IrrigationScreen(land: land)),
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.scale,
                  title: 'ثبت تناژ و میزان محصول سالانه',
                  sub: 'پسته تر، خشک، درصد پوکی و محاسبه عملکرد هر درخت',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => YieldRecordScreen(land: land)),
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.science,
                  title: 'آزمایشات آب، خاک و برگ',
                  sub: 'ثبت یک پرونده آزمایشی برای هر سال زراعی',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => LabTestsScreen(land: land)),
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.analytics,
                  title: 'گزارش‌گیری جامع سالیانه این قطعه',
                  sub: 'مشاهده تجمیعی تمام اطلاعات ثبت‌شده این قطعه',
                  color: Colors.amber.shade900,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => AnnualReportScreen(land: land)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String sub,
      required VoidCallback onTap,
      Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: (color ?? const Color(0xFF1B5E20)).withOpacity(0.12),
          child: Icon(icon, color: color ?? const Color(0xFF1B5E20)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

// ==================== ۴. صفحه مدیریت آبیاری ====================
class IrrigationScreen extends StatefulWidget {
  final RecordMap land;
  const IrrigationScreen({super.key, required this.land});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  int _selectedYear = Jalali.now().year;
  List<RecordMap> _plans = [];
  List<RecordMap> _actuals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await OrchardRepository.instance
        .getIrrigationPlans(widget.land['id'], _selectedYear);
    final a = await OrchardRepository.instance
        .getActualIrrigations(widget.land['id'], _selectedYear);
    if (mounted) {
      setState(() {
        _plans = p;
        _actuals = a;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int interval = widget.land['irrigation_interval'] ?? 13;

    return Scaffold(
      appBar: AppBar(title: Text('آبیاری: ${widget.land['name']}')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: SingleChildScrollView(
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
                          _loadData();
                        },
                      ),
                      Text('سال زراعی: $_selectedYear (مدار $interval روزه)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _selectedYear++);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('۱. برنامه نوبت‌های آبیاری',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  String? first = await showJalaliDatePicker(
                                      context,
                                      initialYear: _selectedYear);
                                  if (first != null) {
                                    await OrchardRepository.instance
                                        .generateIrrigationPlan(
                                      landId: widget.land['id'],
                                      startDateStr: first,
                                      intervalDays: interval,
                                    );
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.auto_mode, size: 16),
                                label: const Text('تولید خودکار دوره'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _plans.isEmpty
                              ? const Text(
                                  'هنوز برنامه‌ای تولید نشده است. تاریخ شروع را بزنید.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54))
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: _plans.map((p) {
                                    bool done = (p['is_completed'] ?? 0) == 1;
                                    return InputChip(
                                      label: Text(p['planned_date']),
                                      avatar: Icon(
                                        done
                                            ? Icons.check_circle
                                            : Icons.schedule,
                                        size: 16,
                                        color:
                                            done ? Colors.green : Colors.blue,
                                      ),
                                      onPressed: done
                                          ? null
                                          : () async {
                                              await OrchardRepository.instance
                                                  .addActualIrrigation(
                                                landId: widget.land['id'],
                                                actualDate: p['planned_date'],
                                                notes: 'اجرا طبق برنامه',
                                                planId: p['id'],
                                              );
                                              _loadData();
                                            },
                                      onDeleted: () async {
                                        await OrchardRepository.instance
                                            .deletePlannedIrrigation(p['id']);
                                        _loadData();
                                      },
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('۲. آبیاری‌های واقعی انجام‌شده',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B5E20),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  String? actual = await showJalaliDatePicker(
                                      context,
                                      initialYear: _selectedYear);
                                  if (actual != null) {
                                    await OrchardRepository.instance
                                        .addActualIrrigation(
                                      landId: widget.land['id'],
                                      actualDate: actual,
                                    );
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('ثبت آبیاری واقعی'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _actuals.isEmpty
                              ? const Text(
                                  'هنوز آبیاری واقعی ثبت نشده است.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54))
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: _actuals.map((a) {
                                    return Chip(
                                      backgroundColor: Colors.white,
                                      avatar: const Icon(Icons.water_drop,
                                          size: 16, color: Color(0xFF1B5E20)),
                                      label: Text(a['actual_date']),
                                      onDeleted: () async {
                                        await OrchardRepository.instance
                                            .deleteActualIrrigation(a['id']);
                                        _loadData();
                                      },
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ۵. صفحه اقدامات ماهانه ====================
class MonthlyActionsScreen extends StatefulWidget {
  final RecordMap land;
  const MonthlyActionsScreen({super.key, required this.land});

  @override
  State<MonthlyActionsScreen> createState() => _MonthlyActionsScreenState();
}

class _MonthlyActionsScreenState extends State<MonthlyActionsScreen> {
  late int _selectedYear;
  late int _selectedMonthIndex;
  final _actions = TextEditingController();
  final _observations = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _selectedYear = now.year;
    _selectedMonthIndex = now.month;
    _loadData();
  }

  Future<void> _loadData() async {
    final report = await OrchardRepository.instance.getMonthlyReport(
      widget.land['id'],
      _selectedYear,
      _selectedMonthIndex,
    );
    if (report != null) {
      _actions.text = report['actions'] ?? '';
      _observations.text = report['observations'] ?? '';
    } else {
      _actions.clear();
      _observations.clear();
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveData() async {
    await OrchardRepository.instance.saveMonthlyReport(
      landId: widget.land['id'],
      year: _selectedYear,
      month: _selectedMonthIndex,
      actions: _actions.text.trim(),
      observations: _observations.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('گزارش ماه در SQLite ذخیره شد')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اقدامات ماهانه: ${widget.land['name']}')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: SingleChildScrollView(
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
                            Text('سال $_selectedYear',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
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
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonthIndex,
                          decoration: const InputDecoration(
                              labelText: 'ماه زراعی',
                              border: OutlineInputBorder()),
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                        PersianDateTimeHelper.monthNames[m - 1]),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            _selectedMonthIndex = v!;
                            _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _actions,
                    maxLines: 4,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'عملیات زراعی (کود، سم، هرس، محلول‌پاشی)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _observations,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'مشاهدات میدانی درختان',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _saveData,
                    child: const Text('ذخیره گزارش ماه'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ۶. صفحه ثبت تناژ و عملکرد ====================
class YieldRecordScreen extends StatefulWidget {
  final RecordMap land;
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

  Future<void> _loadYield() async {
    final record = await OrchardRepository.instance
        .getYieldRecord(widget.land['id'], _selectedYear);
    if (record != null) {
      _treesCount.text = '${record['bearing_trees']}';
      _wetYield.text = '${record['wet_yield_kg']}';
      _dryYield.text = '${record['dry_yield_kg']}';
      _hollowPercent.text = '${record['hollow_percentage']}';
      _notes.text = record['notes'] ?? '';
    } else {
      _treesCount.clear();
      _wetYield.clear();
      _dryYield.clear();
      _hollowPercent.clear();
      _notes.clear();
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveYield() async {
    await OrchardRepository.instance.saveYieldRecord(
      landId: widget.land['id'],
      year: _selectedYear,
      bearingTrees: int.tryParse(_treesCount.text) ?? 0,
      wetYieldKg: double.tryParse(_wetYield.text) ?? 0,
      dryYieldKg: double.tryParse(_dryYield.text) ?? 0,
      hollowPercentage: double.tryParse(_hollowPercent.text) ?? 0,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تناژ محصول ذخیره شد')));
  }

  @override
  Widget build(BuildContext context) {
    double dry = double.tryParse(_dryYield.text) ?? 0;
    int trees = int.tryParse(_treesCount.text) ?? 0;
    double yieldPerTree = (trees > 0 && dry > 0) ? (dry / trees) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('ثبت محصول و عملکرد سالانه')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: SingleChildScrollView(
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
                      Text('سال برداشت: $_selectedYear',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                    decoration: const InputDecoration(
                        labelText: 'تعداد درختان بارده مبنا',
                        suffixText: 'اصل',
                        border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _wetYield,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                        labelText: 'وزن پسته تر (کیلوگرم)',
                        suffixText: 'کیلوگرم',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dryYield,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                        labelText: 'وزن پسته خشک نهایی (کیلوگرم)',
                        suffixText: 'کیلوگرم',
                        border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hollowPercent,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                        labelText: 'درصد پوکی پسته',
                        suffixText: '%',
                        border: OutlineInputBorder()),
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
                            Text('${yieldPerTree.toStringAsFixed(2)} کیلوگرم خشک',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notes,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                        labelText: 'توضیحات (انس پسته، سال باردهی)',
                        border: OutlineInputBorder()),
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
          ),
        ],
      ),
    );
  }
}

// ==================== ۷. صفحه آزمایشات آب، خاک و برگ ====================
class LabTestsScreen extends StatefulWidget {
  final RecordMap land;
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

  Future<void> _loadLab() async {
    final lab = await OrchardRepository.instance
        .getLabTest(widget.land['id'], _selectedYear);
    if (lab != null) {
      _soilEc.text = lab['soil_ec'] != null ? '${lab['soil_ec']}' : '';
      _soilPh.text = lab['soil_ph'] != null ? '${lab['soil_ph']}' : '';
      _waterEc.text = lab['water_ec'] != null ? '${lab['water_ec']}' : '';
      _leafK.text = lab['leaf_k'] != null ? '${lab['leaf_k']}' : '';
    } else {
      _soilEc.clear();
      _soilPh.clear();
      _waterEc.clear();
      _leafK.clear();
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveLab() async {
    await OrchardRepository.instance.saveLabTest(
      landId: widget.land['id'],
      year: _selectedYear,
      soilEc: double.tryParse(_soilEc.text),
      soilPh: double.tryParse(_soilPh.text),
      waterEc: double.tryParse(_waterEc.text),
      leafK: double.tryParse(_leafK.text),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('آزمایشات سال ذخیره شد')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('آزمایشات سالانه آب، خاک و برگ')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: SingleChildScrollView(
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
                      Text('سال زراعی آزمایش: $_selectedYear',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                  TextField(
                      controller: _soilEc,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'EC خاک (شوری dS/m)',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _soilPh,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'pH اسیدیته خاک',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _waterEc,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'EC آب چاه (میکروموس)',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _leafK,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'پتاسیم برگ (K %)',
                          border: OutlineInputBorder())),
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
          ),
        ],
      ),
    );
  }
}

// ==================== ۸. گزارش سالیانه تجمیعی ====================
class AnnualReportScreen extends StatefulWidget {
  final RecordMap land;
  const AnnualReportScreen({super.key, required this.land});

  @override
  State<AnnualReportScreen> createState() => _AnnualReportScreenState();
}

class _AnnualReportScreenState extends State<AnnualReportScreen> {
  int _selectedYear = Jalali.now().year;
  RecordMap? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _loading = true);
    final res = await OrchardRepository.instance
        .getAnnualSummary(widget.land['id'], _selectedYear);
    if (mounted) {
      setState(() {
        _summary = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final yieldData = _summary?['yield'];
    final labData = _summary?['lab'];
    final actuals = (_summary?['actualIrrigations'] as List?) ?? [];
    final reports = (_summary?['monthlyReports'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('گزارش سالیانه: ${widget.land['name']}')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: _loading
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
                            Text('گزارش سال زراعی: $_selectedYear',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
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
                                const Text('عملکرد و تناژ برداشت',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Divider(),
                                Text(
                                    '• درختان بارده: ${yieldData?['bearing_trees'] ?? "ثبت نشده"} اصل'),
                                Text(
                                    '• پسته تر: ${yieldData?['wet_yield_kg'] ?? "ثبت نشده"} کیلوگرم'),
                                Text(
                                    '• پسته خشک: ${yieldData?['dry_yield_kg'] ?? "ثبت نشده"} کیلوگرم'),
                                Text(
                                    '• درصد پوکی: ${yieldData?['hollow_percentage'] ?? "-"} %'),
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
                                const Text('خلاصه آبیاری‌های واقعی انجام‌شده',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Divider(),
                                Text(
                                    '• تعداد نوبت‌های اجراشده: ${actuals.length} نوبت'),
                                if (actuals.isNotEmpty)
                                  Text(
                                      '• تاریخ‌ها: ${actuals.map((e) => e['actual_date']).join(' ، ')}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.purple.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('آزمایشات خاک، آب و برگ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Divider(),
                                Text(
                                    '• EC خاک: ${labData?['soil_ec'] ?? "-"} | pH خاک: ${labData?['soil_ph'] ?? "-"}'),
                                Text(
                                    '• EC آب چاه: ${labData?['water_ec'] ?? "-"}'),
                                Text(
                                    '• پتاسیم برگ (K): ${labData?['leaf_k'] ?? "-"} %'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('گزارش‌های ماهانه ثبت‌شده:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        reports.isEmpty
                            ? const Text('گزارش ماهانه‌ای ثبت نشده است',
                                style: TextStyle(color: Colors.grey))
                            : Column(
                                children: reports.map((r) {
                                  int mIdx = (r['month_jalali'] as int) - 1;
                                  return Card(
                                    child: ExpansionTile(
                                      title: Text(
                                          'ماه ${PersianDateTimeHelper.monthNames[mIdx]}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  'اقدامات: ${r['actions'] ?? "-"}'),
                                              Text(
                                                  'مشاهدات: ${r['observations'] ?? "-"}'),
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
          ),
        ],
      ),
    );
  }
}

// ==================== ۹. گزارش کل باغات ====================
class GlobalAnnualReportScreen extends StatefulWidget {
  final List<RecordMap> lands;
  const GlobalAnnualReportScreen({super.key, required this.lands});

  @override
  State<GlobalAnnualReportScreen> createState() =>
      _GlobalAnnualReportScreenState();
}

class _GlobalAnnualReportScreenState extends State<GlobalAnnualReportScreen> {
  int _selectedYear = Jalali.now().year;
  final Map<String, RecordMap?> _allYields = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGlobal();
  }

  Future<void> _fetchGlobal() async {
    setState(() => _loading = true);
    _allYields.clear();
    for (var l in widget.lands) {
      _allYields[l['id']] = await OrchardRepository.instance
          .getYieldRecord(l['id'], _selectedYear);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش سالیانه تمام باغات')),
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: _loading
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
                          Text('سال زراعی: $_selectedYear',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
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
                        final y = _allYields[land['id']];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'قطعه: ${land['name']} (${land['area']} ${land['unit']})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Divider(),
                                Text(
                                    '• پسته تر: ${y?['wet_yield_kg'] ?? "ثبت نشده"} کیلوگرم'),
                                Text(
                                    '• پسته خشک: ${y?['dry_yield_kg'] ?? "ثبت نشده"} کیلوگرم'),
                                Text(
                                    '• درصد پوکی: ${y?['hollow_percentage'] ?? "-"} %'),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== ۱۰. افزودن قطعه زمین ====================
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
      body: Column(
        children: [
          const LiveClockBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                      controller: _name,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'نام قطعه زمین',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                            controller: _area,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                                labelText: 'مساحت',
                                border: OutlineInputBorder())),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: 'هکتار', child: Text('هکتار')),
                            DropdownMenuItem(value: 'قصب', child: Text('قصب')),
                            DropdownMenuItem(value: 'متر', child: Text('متر')),
                          ],
                          onChanged: (v) => setState(() => _unit = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _varieties,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'ارقام پیوند',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _interval,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'مدار گردش آب چاه (روز)',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (_name.text.isNotEmpty) {
                        await OrchardRepository.instance.addLand(
                          name: _name.text.trim(),
                          area: double.tryParse(_area.text) ?? 0,
                          unit: _unit,
                          varieties: _varieties.text.trim(),
                          irrigationInterval:
                              int.tryParse(_interval.text) ?? 13,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('ثبت قطعه زمین'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
