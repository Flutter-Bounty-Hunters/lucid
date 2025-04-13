import 'package:flutter/material.dart';
import 'package:lucid/lucid.dart';

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({
    super.key,
  });

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DayOfYear? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: DatePicker(
            selectedDay: _selectedDay,
            hint: "Select a date",
            onDaySelected: (DayOfYear? newValue) {
              setState(() {
                _selectedDay = newValue;
              });
            },
          ),
        ),
      ),
    );
  }
}
