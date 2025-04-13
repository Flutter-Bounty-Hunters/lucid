import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DayOfYear? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          spacing: 8,
          children: [
            Spacer(),
            _buildDatePickerDemo(),
            const SizedBox(height: 100),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerDemo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 54),
      child: DatePicker(
        selectedDay: _selectedDay,
        hint: "Select date",
        onDaySelected: (day) {
          print("onDaySelected(): $day");
          setState(() {
            _selectedDay = day;
          });
        },
      ),
    );
  }
}
