import 'package:flutter/material.dart';
import 'package:lucid/lucid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucid Demo',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DayOfYear? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: _buildDatePickerDemo(),
          ),
          Expanded(
            child: LucidBrightness(
              brightness: Brightness.dark,
              child: ColoredBox(
                color: Colors.grey.shade900,
                child: _buildDatePickerDemo(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerDemo() {
    print("Building date picker with selected date: $_selectedDay");
    return Center(
      child: SizedBox(
        width: 300,
        child: DatePicker(
          selectedDate: _selectedDay,
          hint: "Select date",
          onDaySelected: (day) {
            print("onDaySelected(): $day");
            setState(() {
              _selectedDay = day;
            });
          },
        ),
      ),
    );
  }
}
