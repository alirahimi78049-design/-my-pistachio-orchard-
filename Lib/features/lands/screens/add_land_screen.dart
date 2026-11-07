import 'package:flutter/material.dart';
import '../../../models/land_model.dart';
import '../../../services/land_service.dart';

class AddLandScreen extends StatefulWidget {
  final String userPhone;
  const AddLandScreen({super.key, required this.userPhone});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _varietiesController = TextEditingController();
  final _intervalController = TextEditingController(text: '13');
  String _unit = 'هکتار';
  bool _isLoading = false;

  void _saveLand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final land = LandModel(
      userPhone: widget.userPhone,
      name: _nameController.text.trim(),
      areaValue: double.parse(_areaController.text.trim()),
      unit: _unit,
      treeVarieties: _varietiesController.text
          .split('،')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      irrigationIntervalDays: int.tryParse(_intervalController.text.trim()) ?? 13,
    );

    try {
      await LandService().insertLand(land);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ثبت زمین: $e')),
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
        title: const Text('افزودن قطعه زمین جدید'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'نام زمین یا قطعه (مثال: باغ بالا)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'نام زمین را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مساحت',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'مساحت را وارد کنید' : null,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _varietiesController,
                decoration: const InputDecoration(
                  labelText: 'ارقام پسته (با کاما جدا کنید، مثال: اکبری، کله‌قوچی)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'مدار گردش آب چاه (روز)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _saveLand,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('ثبت و ذخیره زمین', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

