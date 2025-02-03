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
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildDatePickerDemo(),
            ),
          ),
          Expanded(
            child: LucidBrightness(
              brightness: Brightness.dark,
              child: ColoredBox(
                color: Colors.grey.shade900,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildDatePickerDemo(),
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
}
