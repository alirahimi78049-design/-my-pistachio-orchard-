import 'package:flutter/material.dart';
import '../../../models/lab_test_model.dart';
import '../../../models/land_model.dart';
import '../../../services/lab_test_service.dart';

class LabTestScreen extends StatefulWidget {
  final LandModel land;
  const LabTestScreen({super.key, required this.land});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  final LabTestService _service = LabTestService();
  final int _currentYear = 1403;
  String? _testId;
  bool _isLoading = false;

  final _soilDateController = TextEditingController();
  final _soilEcController = TextEditingController();
  final _soilPhController = TextEditingController();

  final _waterDateController = TextEditingController();
  final _waterEcController = TextEditingController();

  final _leafDateController = TextEditingController();
  final _leafPotassiumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  void _loadTestData() async {
    setState(() => _isLoading = true);
    final data = await _service.getTestForYear(widget.land.id!, _currentYear);
    if (data != null) {
      _testId = data.id;
      _soilDateController.text = data.soilTestDate ?? '';
      _soilEcController.text = data.soilElements['ec']?.toString() ?? '';
      _soilPhController.text = data.soilElements['ph']?.toString() ?? '';

      _waterDateController.text = data.waterTestDate ?? '';
      _waterEcController.text = data.waterElements['ec']?.toString() ?? '';

      _leafDateController.text = data.leafTestDate ?? '';
      _leafPotassiumController.text = data.leafElements['potassium']?.toString() ?? '';
    }
    setState(() => _isLoading = false);
  }

  void _saveTestData() async {
    setState(() => _isLoading = true);
    final test = LabTestModel(
      id: _testId,
      landId: widget.land.id!,
      solarYear: _currentYear,
      soilTestDate: _soilDateController.text.trim(),
      soilElements: {
        'ec': _soilEcController.text.trim(),
        'ph': _soilPhController.text.trim(),
      },
      waterTestDate: _waterDateController.text.trim(),
      waterElements: {
        'ec': _waterEcController.text.trim(),
      },
      leafTestDate: _leafDateController.text.trim(),
      leafElements: {
        'potassium': _leafPotassiumController.text.trim(),
      },
    );

    try {
      await _service.saveLabTest(test);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('برگه آزمایش با موفقیت در فضای ابری ذخیره شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره آزمایش: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتایج پایش آزمایشگاهی: ${widget.land.name}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionCard(
                    title: 'آزمایش خاک',
                    dateController: _soilDateController,
                    firstLabel: 'میزان EC خاک (شوره‌زایی)',
                    firstController: _soilEcController,
                    secondLabel: 'میزان pH خاک (اسیدیته)',
                    secondController: _soilPhController,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'آزمایش آب چاه',
                    dateController: _waterDateController,
                    firstLabel: 'شوری آب (EC چاه)',
                    firstController: _waterEcController,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'آنالیز برگ پسته',
                    dateController: _leafDateController,
                    firstLabel: 'درصد پتاسیم برگ (K)',
                    firstController: _leafPotassiumController,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saveTestData,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('ثبت نهایی آزمایشات', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required TextEditingController dateController,
    required String firstLabel,
    required TextEditingController firstController,
    String? secondLabel,
    TextEditingController? secondController,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'تاریخ نمونه‌برداری (مثال: ۱۴۰۳/۰۴/۱۰)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: firstController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: firstLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            if (secondLabel != null && secondController != null) ...[
              const SizedBox(height: 10),
              TextField(
                controller: secondController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: secondLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

