import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const PistachioApp());
}

// ----------------- تم و رنگ‌بندی طبق سند PRD -----------------
class AppTheme {
  static const Color creamBackground = Color(0xFFFBF9F1); // پس‌زمینه شیری ملایم
  static const Color pistachioLight = Color(0xFFE8F5E9); // سبز پسته ای بسیار کم‌رنگ
  static const Color darkGreenBorder = Color(0xFF2E7D32); // حاشیه سبز پررنگ
  static const Color buttonGreen = Color(0xFF388E3C); // دکمه‌های سبز
  static const Color darkBrownText = Color(0xFF3E2723); // متن قهوه‌ای بسیار تیره
}

// مدل‌های داده‌ای پروژه
class TreeRecord {
  String countingType;
  int treeCount;
  String treeType;
  String ageGroup;
  int exactAge;
  String leafTestDate;
  Map<String, String> chemicalElements;

  TreeRecord({
    required this.countingType,
    required this.treeCount,
    required this.treeType,
    required this.ageGroup,
    required this.exactAge,
    required this.leafTestDate,
    required this.chemicalElements,
  });
}

class LandDetailsRecord {
  String soilType;
  String soilTestDate;
  Map<String, String> soilParams;
  List<String> irrigationDates;
  String waterTestDate;
  Map<String, String> waterParams;

  LandDetailsRecord({
    required this.soilType,
    required this.soilTestDate,
    required this.soilParams,
    required this.irrigationDates,
    required this.waterTestDate,
    required this.waterParams,
  });
}

class HistoryRecord {
  final String id;
  final String landName;
  final int year;
  final String month;
  final TreeRecord tree;
  final LandDetailsRecord details;
  String consultantStatus; // "در حال بررسی" یا "انجام شده"

  HistoryRecord({
    required this.id,
    required this.landName,
    required this.year,
    required this.month,
    required this.tree,
    required this.details,
    this.consultantStatus = "در حال بررسی",
  });
}

class Land {
  final String id;
  String name;
  double area; // بر حسب متر مربع به صورت استاندارد
  String selectedUnit; // "متر مربع" یا "هکتار"
  List<String> treeTypes;
  bool isDeleted;

  Land({
    required this.id,
    required this.name,
    required this.area,
    required this.selectedUnit,
    required this.treeTypes,
    this.isDeleted = false,
  });
}

// ----------------- اپلیکیشن اصلی -----------------
class PistachioApp extends StatelessWidget {
  const PistachioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدیریت زمین های باغداری پسته',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.creamBackground,
        fontFamily: 'Tahoma',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.darkGreenBorder,
          primary: AppTheme.buttonGreen,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// حافظه موقت مشترک
class AppData {
  static List<Land> lands = [
    Land(
      id: '1',
      name: 'باغ پسته مرکزی',
      area: 25000,
      selectedUnit: 'هکتار',
      treeTypes: ['اکبری', 'احمد آقایی'],
    ),
  ];

  static List<HistoryRecord> histories = [];
  static int selectedYear = 1404;
}

// ----------------- صفحه مدیریت ناوبری اصلی و سوییچ نقش‌ها -----------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  bool isConsultant = false; // جابجایی بین حالت باغدار و مشاور کشاورزی

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.pistachioLight,
        title: Text(
          isConsultant ? 'پنل مشاور کشاورزی' : 'سامانه مدیریت باغ پسته',
          style: const TextStyle(color: AppTheme.darkBrownText, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Text(
                isConsultant ? 'مشاور' : 'باغدار',
                style: const TextStyle(color: AppTheme.darkBrownText, fontSize: 12),
              ),
              Switch(
                value: isConsultant,
                activeColor: AppTheme.buttonGreen,
                onChanged: (val) {
                  setState(() {
                    isConsultant = val;
                  });
                },
              ),
            ],
          )
        ],
      ),
      endDrawer: isConsultant ? _buildConsultantDrawer() : _buildFarmerDrawer(),
      body: isConsultant ? const ConsultantDashboard() : FarmerDashboard(onRefresh: () => setState(() {})),
    );
  }

  // استوری 11: منوی کشویی ۵ گزینه‌ای باغدار
  Widget _buildFarmerDrawer() {
    return Drawer(
      backgroundColor: AppTheme.creamBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.pistachioLight),
            child: Center(
              child: Text(
                'منوی مدیریت باغدار',
                style: TextStyle(fontSize: 18, color: AppTheme.darkBrownText, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerItem('افزودن زمین', () {
            Navigator.pop(context);
            _navigateToAddLand();
          }),
          _drawerItem('زمین‌های من', () {
            Navigator.pop(context);
          }),
          _drawerItem('خوداظهاری', () {
            Navigator.pop(context);
            if (AppData.lands.isNotEmpty) {
              _startSelfDeclaration(AppData.lands.first);
            }
          }),
          _drawerItem('جزئیات زمین من', () {
            Navigator.pop(context);
            if (AppData.lands.isNotEmpty) {
              _navigateToDetails(AppData.lands.first);
            }
          }),
          _drawerItem('تاریخچه من', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ComprehensiveHistoryScreen()));
          }),
        ],
      ),
    );
  }

  // استوری 12: منوی کشویی ۲ گزینه‌ای مشاور
  Widget _buildConsultantDrawer() {
    return Drawer(
      backgroundColor: AppTheme.creamBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.pistachioLight),
            child: Center(
              child: Text(
                'منوی مشاور کشاورزی',
                style: TextStyle(fontSize: 18, color: AppTheme.darkBrownText, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerItem('کشاورزهای من', () {
            Navigator.pop(context);
          }),
          _drawerItem('اعلان‌های من', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('در فیچرهای بعدی ارائه می‌شود')),
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.darkBrownText, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.darkGreenBorder),
      onTap: onTap,
    );
  }

  void _navigateToAddLand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddLandScreen(onSaved: () => setState(() {}))),
    );
  }

  void _navigateToDetails(Land land) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LandDetailScreen(land: land)),
    );
  }

  void _startSelfDeclaration(Land land) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.creamBackground,
        title: const Text('فرایند خوداظهاری', style: TextStyle(color: AppTheme.darkBrownText)),
        content: const Text(
          'آیا مایل به تکمیل اطلاعات ۶ ماهه گذشته خود هستید؟',
          style: TextStyle(color: AppTheme.darkBrownText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('خیر', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SelfDeclarationFlowScreen(land: land)),
              );
            },
            child: const Text('بله', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ----------------- استوری 1 و 2: داشبورد باغدار -----------------
class FarmerDashboard extends StatelessWidget {
  final VoidCallback onRefresh;
  const FarmerDashboard({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final activeLands = AppData.lands.where((l) => !l.isDeleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // استوری 2: هدر بالا سمت چپ برای انتخاب سال و افزودن زمین
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('افزودن زمین', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddLandScreen(onSaved: onRefresh)),
                  );
                },
              ),
              DropdownButton<int>(
                value: AppData.selectedYear,
                dropdownColor: AppTheme.pistachioLight,
                items: [1402, 1403, 1404, 1405].map((y) {
                  return DropdownMenuItem<int>(
                    value: y,
                    child: Text('سال $y', style: const TextStyle(color: AppTheme.darkBrownText, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (newYear) {
                  if (newYear != null) {
                    AppData.selectedYear = newYear;
                    onRefresh();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // لیست کارت‌های شیشه‌ای زمین‌ها
          if (activeLands.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('هیچ زمینی ثبت نشده است.', style: TextStyle(color: AppTheme.darkBrownText)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeLands.length,
              itemBuilder: (ctx, index) {
                final land = activeLands[index];
                return GlassLandCard(
                  land: land,
                  onSelfDeclare: () {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: AppTheme.creamBackground,
                        content: const Text(
                          'آیا مایل به تکمیل اطلاعات ۶ ماهه گذشته خود هستید؟',
                          style: TextStyle(color: AppTheme.darkBrownText),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: const Text('خیر', style: TextStyle(color: Colors.red)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                            onPressed: () {
                              Navigator.pop(dCtx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SelfDeclarationFlowScreen(land: land)),
                              );
                            },
                            child: const Text('بله', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LandDetailScreen(land: land)),
                    );
                  },
                  onHistory: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ComprehensiveHistoryScreen(landFilter: land.name)),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// کامپوننت کارت زمین با طراحی Glassmorphism طبق سند
class GlassLandCard extends StatelessWidget {
  final Land land;
  final VoidCallback onSelfDeclare;
  final VoidCallback onDetails;
  final VoidCallback onHistory;

  const GlassLandCard({
    super.key,
    required this.land,
    required this.onSelfDeclare,
    required this.onDetails,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    String displayArea = land.selectedUnit == 'هکتار'
        ? '${(land.area / 10000).toStringAsFixed(1)} هکتار'
        : '${land.area.toStringAsFixed(0)} متر مربع';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.pistachioLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkGreenBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نام زمین : ${land.name}',
                  style: const TextStyle(color: AppTheme.darkBrownText, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'متراژ: $displayArea',
                  style: const TextStyle(color: AppTheme.darkBrownText, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'نوع درختان: ${land.treeTypes.join("، ")}',
                  style: const TextStyle(color: AppTheme.darkBrownText, fontSize: 14),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                      onPressed: onSelfDeclare,
                      child: const Text('خوداظهاری', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                      onPressed: onDetails,
                      child: const Text('ثبت جزئیات', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                      onPressed: onHistory,
                      child: const Text('تاریخچه', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- استوری 3: ثبت زمین جدید -----------------
class AddLandScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const AddLandScreen({super.key, required this.onSaved});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  String selectedUnit = 'متر مربع';
  final List<String> availableTrees = ['اکبری', 'احمد آقایی', 'اوحدی', 'کله‌قوچی', 'فندقی', 'بادامی'];
  final List<String> selectedTrees = [];
  String? errorMessage;

  void saveLand() {
    final name = nameController.text.trim();
    final areaText = areaController.text.trim();

    if (name.isEmpty || areaText.isEmpty || selectedTrees.isEmpty) {
      setState(() {
        errorMessage = 'لطفاً تمام فیلدهای اجباری (نام، مساحت و نوع درخت) را تکمیل کنید.';
      });
      return;
    }

    final isDuplicate = AppData.lands.any((l) => !l.isDeleted && l.name == name);
    if (isDuplicate) {
      setState(() {
        errorMessage = 'نام زمین انتخاب شده تکراری است. لطفاً نام دیگری انتخاب کنید.';
      });
      return;
    }

    final double? areaValue = double.tryParse(areaText);
    if (areaValue == null || areaValue <= 0) {
      setState(() {
        errorMessage = 'فرمت مقدار مساحت نادرست است. لطفاً عدد وارد کنید.';
      });
      return;
    }

    double standardizedArea = selectedUnit == 'هکتار' ? areaValue * 10000 : areaValue;

    final newLand = Land(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      area: standardizedArea,
      selectedUnit: selectedUnit,
      treeTypes: List.from(selectedTrees),
    );

    AppData.lands.insert(0, newLand);
    widget.onSaved();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('زمین با موفقیت ثبت شد')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت زمین جدید در باغ', style: TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'نام زمین *',
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.pistachioLight)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.darkGreenBorder)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: areaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'مقدار مساحت *',
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.pistachioLight)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.darkGreenBorder)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    items: ['متر مربع', 'هکتار'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setState(() => selectedUnit = val!),
                    decoration: const InputDecoration(
                      labelText: 'واحد',
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.pistachioLight)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('نوع درخت (انتخاب چندگانه) *:', style: TextStyle(color: AppTheme.darkBrownText, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: availableTrees.map((tree) {
                final isSelected = selectedTrees.contains(tree);
                return FilterChip(
                  label: Text(tree),
                  selected: isSelected,
                  selectedColor: AppTheme.pistachioLight,
                  checkmarkColor: AppTheme.darkGreenBorder,
                  onSelected: (val) {
                    setState(() {
                      val ? selectedTrees.add(tree) : selectedTrees.remove(tree);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                    onPressed: saveLand,
                    child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف', style: TextStyle(color: AppTheme.darkBrownText)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 4: انتخاب ماه و خوداظهاری -----------------
class SelfDeclarationFlowScreen extends StatefulWidget {
  final Land land;
  const SelfDeclarationFlowScreen({super.key, required this.land});

  @override
  State<SelfDeclarationFlowScreen> createState() => _SelfDeclarationFlowScreenState();
}

class _SelfDeclarationFlowScreenState extends State<SelfDeclarationFlowScreen> {
  final List<String> persianMonths = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];
  String selectedMonth = 'فروردین';

  TreeRecord? treeData;
  LandDetailsRecord? landDetailsData;

  void validateAndSubmit() {
    final isDuplicateMonth = AppData.histories.any(
      (h) => h.landName == widget.land.name && h.year == AppData.selectedYear && h.month == selectedMonth,
    );

    if (isDuplicateMonth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('برای سال منتخب شما اطلاعات ماه $selectedMonth ذخیره شده است لطفاً مجدداً انتخاب نمایید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (treeData == null || landDetailsData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً هم اطلاعات درختان و هم اطلاعات زمین را تکمیل فرمایید.')),
      );
      return;
    }

    AppData.histories.add(
      HistoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        landName: widget.land.name,
        year: AppData.selectedYear,
        month: selectedMonth,
        tree: treeData!,
        details: landDetailsData!,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اطلاعات زمین با موفقیت در تاریخچه ذخیره شد')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خوداظهاری: ${widget.land.name}', style: const TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppTheme.pistachioLight.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.darkGreenBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('۱. انتخاب ماه خوداظهاری', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMonth,
                      items: persianMonths.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => selectedMonth = val!),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppTheme.pistachioLight.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.darkGreenBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('۲. اطلاعات درختان و آزمایش برگ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
                subtitle: Text(treeData == null ? 'هنوز تکمیل نشده است' : 'اطلاعات با موفقیت درج شد', style: TextStyle(color: treeData == null ? Colors.red : Colors.green)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push<TreeRecord>(
                    context,
                    MaterialPageRoute(builder: (_) => const TreeDetailsFormScreen()),
                  );
                  if (result != null) {
                    setState(() => treeData = result);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppTheme.pistachioLight.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.darkGreenBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('۳. اطلاعات زمین (خاک، آبیاری و آب)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
                subtitle: Text(landDetailsData == null ? 'هنوز تکمیل نشده است' : 'اطلاعات با موفقیت درج شد', style: TextStyle(color: landDetailsData == null ? Colors.red : Colors.green)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push<LandDetailsRecord>(
                    context,
                    MaterialPageRoute(builder: (_) => const LandDetailsFormScreen()),
                  );
                  if (result != null) {
                    setState(() => landDetailsData = result);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: validateAndSubmit,
              child: const Text('ثبت نهایی و ارسال به تاریخچه', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 5: فرم جزئیات درختان و آزمایش برگ -----------------
class TreeDetailsFormScreen extends StatefulWidget {
  final TreeRecord? initialRecord;
  const TreeDetailsFormScreen({super.key, this.initialRecord});

  @override
  State<TreeDetailsFormScreen> createState() => _TreeDetailsFormScreenState();
}

class _TreeDetailsFormScreenState extends State<TreeDetailsFormScreen> {
  final countingTypes = ['هکتار تعداد', 'قفیز تعداد', 'جریب تعداد', 'تعداد (واحد دانه)'];
  final treeTypes = ['اکبری', 'احمد آقایی', 'اوحدی', 'کله‌قوچی', 'فندقی', 'بادامی'];
  final ageGroups = ['نو نهال ( 1 تا 3 سال )', 'جوان( 4 تا 8 سال )', 'بارور ( بیش از 8 سال )'];

  String selectedCounting = 'هکتار تعداد';
  String selectedTree = 'اکبری';
  String selectedAgeGroup = 'نو نهال ( 1 تا 3 سال )';

  final TextEditingController countController = TextEditingController();
  final TextEditingController exactAgeController = TextEditingController();
  final TextEditingController leafDateController = TextEditingController(text: '1404/07/15');

  final Map<String, TextEditingController> elements = {
    'نیتروژن (N) %': TextEditingController(text: '2.1'),
    'فسفر (P) %': TextEditingController(text: '0.14'),
    'پتاسیم (K) %': TextEditingController(text: '1.2'),
    'کلسیم (Ca) %': TextEditingController(text: '1.8'),
    'منیزیم (Mg) %': TextEditingController(text: '0.6'),
    'سدیم (Na) %': TextEditingController(text: '0.05'),
    'کلر (Cl) %': TextEditingController(text: '0.2'),
    'بور (B) P.PM': TextEditingController(text: '65'),
    'مس (Cu) P.PM': TextEditingController(text: '8'),
    'روی / زینک (Zn) P.PM': TextEditingController(text: '14'),
    'آهن (Fe) P.PM': TextEditingController(text: '90'),
    'منگنز (Mn) P.PM': TextEditingController(text: '45'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final r = widget.initialRecord!;
      selectedCounting = r.countingType;
      selectedTree = r.treeType;
      selectedAgeGroup = r.ageGroup;
      countController.text = r.treeCount.toString();
      exactAgeController.text = r.exactAge.toString();
      leafDateController.text = r.leafTestDate;
      r.chemicalElements.forEach((k, v) {
        if (elements.containsKey(k)) elements[k]!.text = v;
      });
    }
  }

  void saveTreeRecord() {
    if (countController.text.isEmpty || exactAgeController.text.isEmpty || leafDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً فیلدهای اجباری شمارش و سن درخت را تکمیل فرمایید.')),
      );
      return;
    }

    final Map<String, String> chemicalMap = {};
    elements.forEach((k, v) {
      chemicalMap[k] = v.text;
    });

    final record = TreeRecord(
      countingType: selectedCounting,
      treeCount: int.tryParse(countController.text) ?? 0,
      treeType: selectedTree,
      ageGroup: selectedAgeGroup,
      exactAge: int.tryParse(exactAgeController.text) ?? 0,
      leafTestDate: leafDateController.text,
      chemicalElements: chemicalMap,
    );

    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت اطلاعات درختان و آزمایش برگ', style: TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الف) مشخصات شمارش و نوع درخت', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCounting,
              items: countingTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => selectedCounting = v!),
              decoration: const InputDecoration(labelText: 'نوع شمارش درخت *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'تعداد درخت *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTree,
              items: treeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => selectedTree = v!),
              decoration: const InputDecoration(labelText: 'نوع درخت *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedAgeGroup,
              items: ageGroups.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) => setState(() => selectedAgeGroup = v!),
              decoration: const InputDecoration(labelText: 'گروه سن درخت *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: exactAgeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سن دقیق درخت (عددی) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('ب) تصاویر تخصصی (حداکثر ۲ عکس برای هر بخش)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            Wrap(
              spacing: 8,
              children: ['تصویر برگ', 'تصویر تنه', 'تصویر ریشه', 'تصویر کلی'].map((t) {
                return OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('ج) تاریخ و نتایج آزمایش برگ (عناصر شیمیایی)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            const SizedBox(height: 8),
            TextField(
              controller: leafDateController,
              decoration: const InputDecoration(labelText: 'تاریخ آزمایش برگ (تقویم شمسی) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ...elements.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen),
                    onPressed: saveTreeRecord,
                    child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 6: فرم اطلاعات زمین (خاک، آبیاری و آب) -----------------
class LandDetailsFormScreen extends StatefulWidget {
  final LandDetailsRecord? initialRecord;
  const LandDetailsFormScreen({super.key, this.initialRecord});

  @override
  State<LandDetailsFormScreen> createState() => _LandDetailsFormScreenState();
}

class _LandDetailsFormScreenState extends State<LandDetailsFormScreen> {
  final List<String> soilTypes = ['شنی', 'رسی', 'سیلتی', 'لومی'];
  String selectedSoil = 'شنی';

  final TextEditingController soilDateController = TextEditingController(text: '1404/07/10');
  final TextEditingController waterDateController = TextEditingController(text: '1404/07/12');

  final List<String> irrigationDates = ['1404/07/05', '1404/07/20'];
  final TextEditingController newIrrigationDateController = TextEditingController();

  final Map<String, TextEditingController> soilParams = {
    'EC (هدایت الکتریکی) - ds/m': TextEditingController(text: '4.2'),
    'pH (اسیدیته)': TextEditingController(text: '7.8'),
    'Ca (کلسیم) - meq/l': TextEditingController(text: '12'),
    'Mg (منیزیم) - meq/l': TextEditingController(text: '8'),
    'Na (سدیم) - meq/l': TextEditingController(text: '15'),
    'SAR (نسبت جذب سدیم)': TextEditingController(text: '4.7'),
    'K (پتاسیم) - mg/kg': TextEditingController(text: '280'),
    'P (فسفر) - mg/kg': TextEditingController(text: '15'),
    'Clay (رس) - %': TextEditingController(text: '22'),
    'Silt (سیلت) - %': TextEditingController(text: '28'),
    'Sand (شن) - %': TextEditingController(text: '50'),
    'Fe (آهن) - mg/kg': TextEditingController(text: '6'),
    'Cu (مس) - mg/kg': TextEditingController(text: '1.2'),
    'Mn (منگنز) - mg/kg': TextEditingController(text: '8.5'),
    'T.N.V (مواد خنثی شونده) - %': TextEditingController(text: '18'),
  };

  final Map<String, TextEditingController> waterParams = {
    'EC قابلیت هدایت الکتریکی - ds/m': TextEditingController(text: '3.5'),
    'TDS مقدار کل املاح': TextEditingController(text: '2200'),
    'SAR نسبت جذب سدیم': TextEditingController(text: '5.1'),
    'pH اسیدیته': TextEditingController(text: '7.4'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      final r = widget.initialRecord!;
      selectedSoil = r.soilType;
      soilDateController.text = r.soilTestDate;
      waterDateController.text = r.waterTestDate;
      irrigationDates.clear();
      irrigationDates.addAll(r.irrigationDates);
      r.soilParams.forEach((k, v) {
        if (soilParams.containsKey(k)) soilParams[k]!.text = v;
      });
      r.waterParams.forEach((k, v) {
        if (waterParams.containsKey(k)) waterParams[k]!.text = v;
      });
    }
  }

  void saveDetailsRecord() {
    final Map<String, String> sMap = {};
    soilParams.forEach((k, v) => sMap[k] = v.text);

    final Map<String, String> wMap = {};
    waterParams.forEach((k, v) => wMap[k] = v.text);

    final record = LandDetailsRecord(
      soilType: selectedSoil,
      soilTestDate: soilDateController.text,
      soilParams: sMap,
      irrigationDates: List.from(irrigationDates),
      waterTestDate: waterDateController.text,
      waterParams: wMap,
    );

    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اطلاعات زمین (خاک، آبیاری، آب)', style: TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بخش اول: آزمایش خاک', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSoil,
              items: soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedSoil = v!),
              decoration: const InputDecoration(labelText: 'نوع خاک *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: soilDateController,
              decoration: const InputDecoration(labelText: 'تاریخ آزمایش خاک (شمسی) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ...soilParams.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TextField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key, border: const OutlineInputBorder()),
                  ),
                )),
            const Divider(height: 32),
            const Text('بخش دوم: دوره آبیاری (تاریخ‌های آبیاری)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newIrrigationDateController,
                    decoration: const InputDecoration(hintText: 'مثال: 1404/07/28', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.buttonGreen, size: 32),
                  onPressed: () {
                    if (newIrrigationDateController.text.isNotEmpty) {
                      setState(() {
                        irrigationDates.add(newIrrigationDateController.text);
                        newIrrigationDateController.clear();
                      });
                    }
                  },
                )
              ],
            ),
            Wrap(
              spacing: 6,
              children: irrigationDates.map((d) => Chip(label: Text(d), onDeleted: () => setState(() => irrigationDates.remove(d)))).toList(),
            ),
            const Divider(height: 32),
            const Text('بخش سوم: آزمایش آب', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
            const SizedBox(height: 8),
            TextField(
              controller: waterDateController,
              decoration: const InputDecoration(labelText: 'تاریخ آزمایش آب (شمسی) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ...waterParams.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TextField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key, border: const OutlineInputBorder()),
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen, minimumSize: const Size.fromHeight(46)),
              onPressed: saveDetailsRecord,
              child: const Text('ثبت اطلاعات زمین', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 7: مدیریت جزئیات زمین -----------------
class LandDetailScreen extends StatelessWidget {
  final Land land;
  const LandDetailScreen({super.key, required this.land});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مدیریت زمین: ${land.name}', style: const TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonGreen, minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ComprehensiveHistoryScreen(landFilter: land.name)),
                );
              },
              child: const Text('مشاهده تاریخچه این زمین', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pistachioLight, foregroundColor: AppTheme.darkBrownText, minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SelfDeclarationFlowScreen(land: land)),
                );
              },
              child: const Text('ورود به ثبت و خوداظهاری ماهانه'),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 9 و 10: تاریخچه جامع و ویرایش -----------------
class ComprehensiveHistoryScreen extends StatefulWidget {
  final String? landFilter;
  const ComprehensiveHistoryScreen({super.key, this.landFilter});

  @override
  State<ComprehensiveHistoryScreen> createState() => _ComprehensiveHistoryScreenState();
}

class _ComprehensiveHistoryScreenState extends State<ComprehensiveHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    List<HistoryRecord> records = AppData.histories;
    if (widget.landFilter != null) {
      records = records.where((r) => r.landName == widget.landFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول جامع تاریخچه', style: TextStyle(color: AppTheme.darkBrownText)),
        backgroundColor: AppTheme.pistachioLight,
      ),
      body: records.isEmpty
          ? const Center(child: Text('برای این سال و زمین اطلاعاتی ثبت نشده است', style: TextStyle(color: AppTheme.darkBrownText)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: records.length,
              itemBuilder: (ctx, index) {
                final r = records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppTheme.darkGreenBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${r.landName} - ماه ${r.month} (${r.year})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkBrownText)),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.buttonGreen),
                              onPressed: () => _editHistoryItem(r),
                            )
                          ],
                        ),
                        const Divider(),
                        Text('اطلاعات پایه: ${r.tree.treeType} - ${r.tree.ageGroup} - ${r.tree.treeCount} اصله'),
                        Text('آزمایش خاک: نوع ${r.details.soilType} - تاریخ: ${r.details.soilTestDate}'),
                        Text('آزمایش برگ: تاریخ ${r.tree.leafTestDate}'),
                        Text('آزمایش آب: تاریخ ${r.details.waterTestDate}'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: r.details.irrigationDates.map((d) => Chip(label: Text('آبیاری: $d', style: const TextStyle(fontSize: 10)))).toList(),
                        ),
                        const SizedBox(height: 6),
                        Text('وضعیت بررسی مشاور: ${r.consultantStatus}', style: TextStyle(fontWeight: FontWeight.bold, color: r.consultantStatus == "انجام شده" ? Colors.green : Colors.orange)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _editHistoryItem(HistoryRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bCtx) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          children: [
            const Text('ویرایش تاریخچه (استوری 10)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('ویرایش اطلاعات درختان و برگ'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                Navigator.pop(bCtx);
                final updated = await Navigator.push<TreeRecord>(
                  context,
                  MaterialPageRoute(builder: (_) => TreeDetailsFormScreen(initialRecord: record.tree)),
                );
                if (updated != null) {
                  setState(() {
                    record.chemicalElements.addAll(updated.chemicalElements);
                  });
                }
              },
            ),
            ListTile(
              title: const Text('ویرایش اطلاعات زمین و آزمایش خاک و آب'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                Navigator.pop(bCtx);
                final updated = await Navigator.push<LandDetailsRecord>(
                  context,
                  MaterialPageRoute(builder: (_) => LandDetailsFormScreen(initialRecord: record.details)),
                );
                if (updated != null) {
                  setState(() {
                    record.details.soilParams.addAll(updated.soilParams);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- استوری 13: کارتابل مشاور کشاورزی -----------------
class ConsultantDashboard extends StatefulWidget {
  const ConsultantDashboard({super.key});

  @override
  State<ConsultantDashboard> createState() => _ConsultantDashboardState();
}

class _ConsultantDashboardState extends State<ConsultantDashboard> {
  @override
  Widget build(BuildContext context) {
    final activeLands = AppData.lands.where((l) => !l.isDeleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'کارتابل مدیریت زمین‌ها (مشاور کشاورزی)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkBrownText),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppTheme.pistachioLight),
              columns: const [
                DataColumn(label: Text('ردیف')),
                DataColumn(label: Text('نام باغدار')),
                DataColumn(label: Text('شناسه')),
                DataColumn(label: Text('نام زمین')),
                DataColumn(label: Text('جزئیات (چشم)')),
                DataColumn(label: Text('عملیات وضعیت')),
              ],
              rows: activeLands.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final land = entry.value;

                final currentStatus = AppData.histories.any((h) => h.landName == land.name && h.consultantStatus == "انجام شده")
                    ? "انجام شده"
                    : "در حال بررسی";

                return DataRow(cells: [
                  DataCell(Text(idx.toString())),
                  const DataCell(Text('علی احمدی')),
                  DataCell(Text(land.id)),
                  DataCell(Text(land.name)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, color: AppTheme.buttonGreen),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ComprehensiveHistoryScreen(landFilter: land.name)),
                        );
                      },
                    ),
                  ),
                  DataCell(
                    DropdownButton<String>(
                      value: currentStatus,
                      items: ['در حال بررسی', 'انجام شده'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (newStatus) {
                        setState(() {
                          for (var h in AppData.histories.where((h) => h.landName == land.name)) {
                            h.consultantStatus = newStatus!;
                          }
                        });
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
