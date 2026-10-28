import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const PistachioApp());
}

class AppTheme {
  static const Color creamBackground = Color(0xFFFBF9F1);
  static const Color pistachioLight = Color(0xFFE8F5E9);
  static const Color darkGreenBorder = Color(0xFF2E7D32);
  static const Color buttonGreen = Color(0xFF388E3C);
  static const Color darkBrownText = Color(0xFF3E2723);
}

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
  String consultantStatus;

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
  double area;
  String selectedUnit;
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  bool isConsultant = false;

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

    if (
