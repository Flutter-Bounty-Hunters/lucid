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
      builder: (context, child) {
        if (child == null) {
          return const SizedBox();
        }

        return child;
        // TODO: Add a handle for ESC - if ESC is unhandled all the way at the
        //       root of the widget tree, and there's a focus, then remove the
        //       focus.
        // return TapToClearFocus(
        //   child: child,
        // );
      },
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
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
  void initState() {
    super.initState();

    print("Initializing Focus listener...");
    print(" - highlight mode: ${FocusManager.instance.highlightMode}");
    print(" - highlight strategy: ${FocusManager.instance.highlightStrategy}");
    FocusManager.instance.addListener(() {
      // print("Focus change: ${FocusManager.instance.primaryFocus}");
      _printFocusPath();
    });
  }

  void _printFocusPath() {
    FocusNode? currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) {
      debugPrint("No widget has focus.");
      return;
    }

    List<String> focusPath = [];
    while (currentFocus != null) {
      focusPath.add(currentFocus.debugLabel ?? "Unnamed FocusNode");
      currentFocus = currentFocus.parent;
    }

    // debugPrint("Focus Path: ${focusPath.reversed.join(" -> ")}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              spacing: 8,
              children: [
                _buildDatePickerDemo(),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    _buildTimePickerDemo(TimeResolution.hour),
                    _buildTimePickerDemo(TimeResolution.minute),
                    _buildTimePickerDemo(TimeResolution.second),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
          Expanded(
            child: LucidBrightness(
              brightness: Brightness.dark,
              child: ColoredBox(
                color: Colors.grey.shade900,
                child: Column(
                  spacing: 8,
                  children: [
                    const SizedBox(height: 48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        _buildTimePickerDemo(TimeResolution.second),
                        _buildTimePickerDemo(TimeResolution.minute),
                        _buildTimePickerDemo(TimeResolution.hour),
                      ],
                    ),
                    Spacer(),
                    _buildDatePickerDemo(),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildTimePickerDemo(TimeResolution resolution) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 54),
      child: _TimePickerDemo(
        resolution: resolution,
      ),
    );
  }
}

class _TimePickerDemo extends StatefulWidget {
  const _TimePickerDemo({
    this.resolution,
  });

  final TimeResolution? resolution;

  @override
  State<_TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<_TimePickerDemo> {
  LocalTime? _time;

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      value: _time,
      timeResolution: widget.resolution ?? TimeResolution.second,
      onNewTimeRequested: (newTime) {
        setState(() {
          _time = newTime;
        });
      },
    );
  }
}
