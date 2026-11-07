import 'package:flutter/material.dart';
import '../../../models/land_model.dart';
import '../../../services/land_service.dart';
import 'add_land_screen.dart';

class LandsListScreen extends StatefulWidget {
  final String userPhone;
  const LandsListScreen({super.key, required this.userPhone});

  @override
  State<LandsListScreen> createState() => _LandsListScreenState();
}

class _LandsListScreenState extends State<LandsListScreen> {
  final LandService _service = LandService();
  late Future<List<LandModel>> _landsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _landsFuture = _service.getLands(widget.userPhone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت زمین‌های باغ'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => AddLandScreen(userPhone: widget.userPhone),
            ),
          );
          if (res == true) _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('زمین جدید'),
      ),
      body: FutureBuilder<List<LandModel>>(
        future: _landsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در دریافت اطلاعات: ${snapshot.error}'));
          }

          final lands = snapshot.data ?? [];
          if (lands.isEmpty) {
            return const Center(
              child: Text(
                'هنوز قطعه زمینی ثبت نشده است.\nبا زدن دکمه پایین اولین زمین را ثبت کنید.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lands.length,
            itemBuilder: (context, index) {
              final land = lands[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.park),
                  ),
                  title: Text(
                    land.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'مساحت: ${land.areaValue} ${land.unit} | مدار آب: ${land.irrigationIntervalDays} روزه',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // در مرحله بعد: باز کردن پرونده اقدامات ماهانه و آزمایش‌های این زمین
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

