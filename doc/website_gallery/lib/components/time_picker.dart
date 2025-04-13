import 'package:flutter/material.dart';
import 'package:lucid/lucid.dart';

class TimePickerDemo extends StatefulWidget {
  const TimePickerDemo({
    super.key,
  });

  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  LocalTime? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: TimePicker(
            value: _selectedTime,
            onNewTimeRequested: (newValue) {
              setState(() {
                _selectedTime = newValue;
              });
            },
          ),
        ),
      ),
    );
  }
}
