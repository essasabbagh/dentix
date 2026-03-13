import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.date,
    required this.datePicker,
  });
  final String label;
  final DateTime? date;
  final void Function(DateTime date) datePicker;

  @override
  Widget build(BuildContext context) {
    Future<void> pickDate(void Function(DateTime) setter) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2025),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) setter(picked);
    }

    return InkWell(
      onTap: () => pickDate(datePicker),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: false,
          fillColor: Colors.transparent,
        ),
        child: Text(
          date != null
              ? '${date!.year}/${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}'
              : 'mm / dd / yyyy',
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
