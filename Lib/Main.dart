import 'package:flutter/material.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LandsListScreen(),
    );
  }
}

// مدل زمین
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
}

// ۱. صفحه لیست قطعات زمین
class LandsListScreen extends StatefulWidget {
  const LandsListScreen({super.key});

  @override
  State<LandsListScreen> createState() => _LandsListScreenState();
}

class _LandsListScreenState extends State<LandsListScreen> {
  final List<LandItem> _lands = [
    LandItem(
      id: '1',
      name: 'باغ اصلی (قطعه ۱)',
      area: 8.5,
      unit: 'هکتار',
      varieties: 'اکبری، کله‌قوچی',
      irrigationInterval: 13,
    ),
    LandItem(
      id: '2',
      name: 'باغ موتور بالا',
      area: 4.0,
      unit: 'هکتار',
      varieties: 'احمدآقایی',
      irrigationInterval: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت قطعات باغ پسته'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newLand = await Navigator.push<LandItem>(
            context,
            MaterialPageRoute(builder: (c) => const AddLandScreen()),
          );
          if (newLand != null) {
            setState(() => _lands.add(newLand));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('افزودن زمین'),
      ),
      body: _lands.isEmpty
          ? const Center(child: Text('هنوز زمینی ثبت نشده است'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _lands.length,
              itemBuilder: (context, index) {
                final land = _lands[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.park, color: Colors.white),
                    ),
                    title: Text(
                      land.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'مساحت: ${land.area} ${land.unit} | مدار آب: ${land.irrigationInterval} روزه\nارقام: ${land.varieties}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => MonthlyDashboardScreen(land: land),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ۲. صفحه افزودن زمین جدید
class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _varietiesController = TextEditingController();
  final _intervalController = TextEditingController(text: '13');
  String _unit = 'هکتار';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن قطعه زمین')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام زمین یا قطعه',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'مساحت',
                      border: OutlineInputBorder(),
                    ),
                  ),
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
            TextField(
              controller: _varietiesController,
              decoration: const InputDecoration(
                labelText: 'ارقام پیوند (مثال: اکبری، کله‌قوچی)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مدار گردش آب چاه (روز)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    LandItem(
                      id: DateTime.now().toString(),
                      name: _nameController.text.trim(),
                      area: double.tryParse(_areaController.text) ?? 0,
                      unit: _unit,
                      varieties: _varietiesController.text.trim(),
                      irrigationInterval:
                          int.tryParse(_intervalController.text) ?? 13,
                    ),
                  );
                }
              },
              child: const Text('ذخیره زمین'),
            ),
          ],
        ),
      ),
    );
  }
}

// ۳. داشبورد پرونده اقدامات ماهانه و آبیاری
class MonthlyDashboardScreen extends StatefulWidget {
  final LandItem land;
  const MonthlyDashboardScreen({super.key, required this.land});

  @override
  State<MonthlyDashboardScreen> createState() => _MonthlyDashboardScreenState();
}

class _MonthlyDashboardScreenState extends State<MonthlyDashboardScreen> {
  String _selectedMonth = 'فروردین';
  final _actionController = TextEditingController();
  final _obsController = TextEditingController();
  final _irrigationDateController = TextEditingController();
  final List<String> _irrigationDates = [];

  final List<String> _months = const [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('پرونده: ${widget.land.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'آزمایشات خاک، برگ و آب',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => LabTestScreen(landName: widget.land.name),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'ماه زراعی',
                border: OutlineInputBorder(),
              ),
              items: _months
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMonth = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _actionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'اقدامات انجام‌شده (کود سولوپتاس، محلول‌پاشی، سم ابامکتین...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'مشاهدات (وضعیت رشد، پسته ارزنی، سرخشکی شاخه)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _irrigationDateController,
                    decoration: InputDecoration(
                      labelText: 'نوبت آبیاری (مدار ${widget.land.irrigationInterval} روزه)',
                      hintText: 'مثال: ۱۴۰۳/۰۲/۱۵',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_irrigationDateController.text.isNotEmpty) {
                      setState(() {
                        _irrigationDates.add(_irrigationDateController.text.trim());
                        _irrigationDateController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _irrigationDates
                  .map(
                    (d) => Chip(
                      label: Text(d),
                      onDeleted: () => setState(() => _irrigationDates.remove(d)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('اطلاعات با موفقیت ثبت شد')),
                );
              },
              child: const Text('ثبت موقت گزارش ماه'),
            ),
          ],
        ),
      ),
    );
  }
}

// ۴. صفحه پایش آزمایشات آب، خاک و برگ
class LabTestScreen extends StatefulWidget {
  final String landName;
  const LabTestScreen({super.key, required this.landName});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  final _soilEc = TextEditingController(text: '4.2');
  final _soilPh = TextEditingController(text: '7.8');
  final _waterEc = TextEditingController(text: '3800');
  final _leafK = TextEditingController(text: '1.45');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نتایج آزمایشات: ${widget.landName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard('آزمایش خاک', [
              TextField(
                controller: _soilEc,
                decoration: const InputDecoration(
                  labelText: 'میزان EC خاک (شوره‌زایی)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _soilPh,
                decoration: const InputDecoration(
                  labelText: 'میزان pH خاک (اسیدیته)',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _buildCard('آزمایش آب چاه', [
              TextField(
                controller: _waterEc,
                decoration: const InputDecoration(
                  labelText: 'EC آب چاه (میکروموس/سانتی‌متر)',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _buildCard('آنالیز برگ پسته', [
              TextField(
                controller: _leafK,
                decoration: const InputDecoration(
                  labelText: 'درصد پتاسیم برگ (K)',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('نتایج آزمایش با موفقیت ثبت شد')),
                );
              },
              child: const Text('تایید و ذخیره آزمایشات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
