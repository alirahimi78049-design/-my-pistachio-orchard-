import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PersianDateTimeHelper {
  static const List<String> monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  static const List<String> weekDays = [
    'شنبه', 'یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'
  ];

  static String getLiveHeaderDateTime() {
    final now = DateTime.now();
    final j = Jalali.fromDateTime(now);
    String wDay = weekDays[j.weekDay - 1];
    String mName = monthNames[j.month - 1];
    String hour = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
    String minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    String second = now.second < 10 ? '0${now.second}' : '${now.second}';
    return '$wDay ${j.day} $mName ${j.year}  |  $hour:$minute:$second';
  }

  static String formatJalali(Jalali j) {
    String m = j.month < 10 ? '0${j.month}' : '${j.month}';
    String d = j.day < 10 ? '0${j.day}' : '${j.day}';
    return '${j.year}/$m/$d';
  }
}

class LiveClockBanner extends StatefulWidget {
  const LiveClockBanner({super.key});

  @override
  State<LiveClockBanner> createState() => _LiveClockBannerState();
}

class _LiveClockBannerState extends State<LiveClockBanner> {
  late Timer _timer;
  String _currentTime = PersianDateTimeHelper.getLiveHeaderDateTime();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = PersianDateTimeHelper.getLiveHeaderDateTime();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: const Color(0xFF1B5E20).withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 15, color: Color(0xFF1B5E20)),
          const SizedBox(width: 6),
          Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showJalaliDatePicker(BuildContext context, {int? initialYear, int? initialMonth}) async {
  final now = Jalali.now();
  int selectedYear = initialYear ?? now.year;
  int selectedMonth = initialMonth ?? now.month;
  int selectedDay = now.day;

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
                                  child: Text(PersianDateTimeHelper.monthNames[m - 1]),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedMonth = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final today = Jalali.now();
                      setDialogState(() {
                        selectedYear = today.year;
                        selectedMonth = today.month;
                        selectedDay = today.day;
                      });
                    },
                    child: const Text('پرش به امروز (تاریخ گوشی)', style: TextStyle(fontSize: 12)),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () {
                  final j = Jalali(selectedYear, selectedMonth, selectedDay);
                  Navigator.pop(context, PersianDateTimeHelper.formatJalali(j));
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

