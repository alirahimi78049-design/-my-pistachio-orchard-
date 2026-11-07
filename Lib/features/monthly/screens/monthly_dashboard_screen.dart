import 'package:flutter/material.dart';
import '../../../models/land_model.dart';
import '../../../models/monthly_action_model.dart';
import '../../../services/monthly_action_service.dart';

class MonthlyDashboardScreen extends StatefulWidget {
  final LandModel land;
  const MonthlyDashboardScreen({super.key, required this.land});

  @override
  State<MonthlyDashboardScreen> createState() => _MonthlyDashboardScreenState();
}

class _MonthlyDashboardScreenState extends State<MonthlyDashboardScreen> {
  final MonthlyActionService _service = MonthlyActionService();
  final int _currentYear = 1403;
  String _selectedMonth = 'فروردین';

  final _actionController = TextEditingController();
  final _obsController = TextEditingController();
  final _irrigationDateController = TextEditingController();
  List<String> _irrigationDates = [];
  String? _currentRecordId;
  bool _isLoading = false;

  final List<String> _months = const [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  void _loadMonthData() async {
    setState(() => _isLoading = true);
    final record = await _service.getActionForMonth(
      widget.land.id!,
      _currentYear,
      _selectedMonth,
    );

    setState(() {
      _currentRecordId = record?.id;
      _actionController.text = record?.mainActionNote ?? '';
      _obsController.text = record?.treeObservationNote ?? '';
      _irrigationDates = List.from(record?.irrigationDates ?? []);
      _isLoading = false;
    });
  }

  void _saveData() async {
    setState(() => _isLoading = true);
    final model = MonthlyActionModel(
      id: _currentRecordId,
      landId: widget.land.id!,
      solarYear: _currentYear,
      month: _selectedMonth,
      mainActionNote: _actionController.text.trim(),
      treeObservationNote: _obsController.text.trim(),
      irrigationDates: _irrigationDates,
    );

    try {
      await _service.saveAction(model);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('گزارش ماهانه با موفقیت ذخیره شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره اطلاعات: $e')),
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
        title: Text('مدیریت ${widget.land.name}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // انتخاب ماه زراعی
                  DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'انتخاب ماه',
                      border: OutlineInputBorder(),
                    ),
                    items: _months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedMonth = v);
                        _loadMonthData();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // ثبت یادداشت اقدامات انجام شده
                  TextField(
                    controller: _actionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'اقدامات انجام‌شده (کوددهی، محلول‌پاشی و سموم)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // مشاهدات باغدار
                  TextField(
                    controller: _obsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'مشاهدات وضعیت درختان و سرخشکی',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ثبت تاریخ‌های آبیاری طبق مدار آب چاه
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _irrigationDateController,
                          decoration: InputDecoration(
                            labelText: 'ثبت روز آبیاری (مدار ${widget.land.irrigationIntervalDays} روزه)',
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
                          (date) => Chip(
                            label: Text(date),
                            onDeleted: () {
                              setState(() => _irrigationDates.remove(date));
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _saveData,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('ذخیره گزارش در سرور ابری', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}

