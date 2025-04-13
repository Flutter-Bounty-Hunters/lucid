import 'package:example/buttons/icon_button_demo.dart';
import 'package:example/buttons/rectangle_button_demo.dart';
import 'package:example/date_and_time/date_picker_demo.dart';
import 'package:example/date_and_time/time_picker_with_components_demo.dart';
import 'package:example/icons/sliding_icon_demo.dart';
import 'package:flutter/material.dart' hide Divider;
import 'package:lucid/lucid.dart';

void main() {
  // timeDilation = 5;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EscapeToClearFocus(
      child: MaterialApp(
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
      ),
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
  Brightness _brightness = Brightness.dark;

  static const _demos = [
    "Date Picker",
    "Time Picker",
    "Dropdown List",
    "Sliding Icon",
    "Tri-State Icon Button",
    "Rectangle Button",
  ];

  String? _selectedDemo = "Date Picker";

  DayOfYear? _selectedDay;

  late final NotebookTabController _tabController;

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

    _tabController = NotebookTabController(
      initialTabs: List.from(_tabs),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
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
    return LucidBrightness(
      brightness: _brightness,
      child: DefaultRectangleButtonStyle(
        light: RectangleButtonStyle(
          foregroundColor: Colors.black,
        ),
        dark: RectangleButtonStyle(
          foregroundColor: Colors.white,
        ),
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Pane.lower(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 48,
                  color: switch (_brightness) {
                    Brightness.light => Colors.red,
                    Brightness.dark => Colors.black.withValues(alpha: 0.15),
                  },
                  padding: const EdgeInsets.only(left: 100),
                  child: NotebookTabBar(
                    controller: _tabController,
                    paddingEnd: 16,
                    maxTabWidth: 400,
                    lightStyle: NotebookTabBarStyle(
                      background: Colors.transparent,
                      tabStyle: NotebookTabStyle(
                        background: BrightTheme.paneMiddleBackgroundColor,
                        activeTabTextColor: Colors.black,
                        activeTabContentIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.black,
                        ),
                        activeTabCloseIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.black,
                        ),
                        inactiveTabTextColor: Colors.white,
                        inactiveTabContentIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                        inactiveTabCloseIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      dividerColor: Colors.white.withValues(alpha: 0.4),
                      newTabIconTheme: IconTheme.of(context).copyWith(
                        color: Colors.black,
                      ),
                    ),
                    darkStyle: NotebookTabBarStyle(
                      background: Colors.transparent,
                      tabStyle: NotebookTabStyle(
                        background: DarkTheme.paneMiddleBackgroundColor,
                        activeTabTextColor: Colors.white,
                        activeTabContentIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                        activeTabCloseIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                        inactiveTabTextColor: Colors.white,
                        inactiveTabContentIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                        inactiveTabCloseIconTheme: IconTheme.of(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      dividerColor: Colors.white.withValues(alpha: 0.1),
                      newTabIconTheme: IconTheme.of(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onAddTabPressed: () {},
                  ),
                ),
                _buildAppBar(),
                Divider.horizontal(),
                Expanded(
                  child: _buildPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _tabs = <TabDescriptor>[
    TabDescriptor(
      id: "flutter",
      image: AssetImage("assets/images/flutter_icon.png"),
      title: "Flutter is a portable UI toolkit",
    ),
    TabDescriptor(
      id: "dart",
      image: AssetImage("assets/images/dart_icon.png"),
      title: "Dart is a general purpose programming language",
    ),
    TabDescriptor(
      id: "tab_kit",
      icon: Icons.account_tree_rounded,
      title: "tab_kit provides a selection of tab bars",
    ),
    TabDescriptor(
      id: "chrome_tab_bar",
      image: AssetImage("assets/images/chrome_icon.png"),
      title: "ChromeTabBar is a tab bar similar to Chrome",
    ),
    TabDescriptor(
      id: "obsidian_tab_bar",
      image: AssetImage("assets/images/obsidian_icon.png"),
      title: "ObsidianTabBar is a tab bar similar to Obsidian",
    ),
  ];

  Color get _backgroundColor => switch (_brightness) {
        Brightness.light => BrightTheme.backgroundIdleColor,
        Brightness.dark => DarkTheme.backgroundIdleColor,
      };

  Widget _buildAppBar() {
    return SizedBox(
      height: 54,
      child: Pane(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Mac traffic lights spacer.
                  const SizedBox(width: 90),
                  Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: sheetCornerRadius,
                      color: Colors.pinkAccent,
                    ),
                    child: Center(
                      child: Text(
                        "L",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // _buildDropdown(),
            _buildDropdownList(),
            Expanded(
              child: Row(
                children: [
                  Spacer(),
                  BrightnessIconButton(
                    brightness: _brightness,
                    onChange: (newValue) {
                      setState(() {
                        _brightness = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Dropdown(
            popoverBuilder: (context) {
              return Sheet(
                child: const SizedBox(width: 400, height: 250),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Date Picker",
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownList() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: SizedBox(
        height: 30,
        child: DropdownList<String>(
          selectedItem: _selectedDemo,
          items: _demos,
          closeOnItemSelection: true,
          buttonBuilder: (context, String? selectedItem) {
            return DropdownButton(
              label: selectedItem ?? "",
              hint: "Select a demo...",
            );
          },
          listItemBuilder: (context, String item, String? selectedItem, DropdownItemSelector<String?> selectItem) {
            return TextButton(
              label: item,
              onPressed: () => selectItem(item),
            );
          },
          divider: Divider.horizontal(),
          onItemSelectionRequested: (String? selectedItem) {
            setState(() {
              _selectedDemo = selectedItem;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPage() {
    return _buildDemo();
  }

  Widget _buildDemo() {
    switch (_selectedDemo) {
      case "Date Picker":
        return DatePickerDemo();
      case "Time Picker":
        return TimePickerWithComponentsDemo();
      case "Tri-State Icon Button":
        return TriStateIconButtonDemo();
      case "Sliding Icon":
        return SlidingIconDemo();
      case "Rectangle Button":
        return RectangleButtonDemo();
      case "Dropdown List":
      case "Dropdown":
      case "Sheet":
      default:
        return const SizedBox();
    }
  }
}

class DropdownButton extends StatelessWidget {
  const DropdownButton({
    super.key,
    required this.label,
    this.hint,
  });

  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label.isNotEmpty ? label : hint ?? "",
              style: TextStyle(
                color: _textColor(context),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.arrow_drop_down_outlined,
              color: _iconColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Color _textColor(BuildContext context) {
    if (label.isEmpty) {
      return switch (LucidBrightness.of(context)) {
        Brightness.light => BrightTheme.hintColor,
        Brightness.dark => DarkTheme.hintColor,
      };
    }

    return switch (LucidBrightness.of(context)) {
      Brightness.light => BrightTheme.textColor,
      Brightness.dark => DarkTheme.textColor,
    };
  }

  Color _iconColor(BuildContext context) {
    return switch (LucidBrightness.of(context)) {
      Brightness.light => Colors.black.withValues(alpha: 0.5),
      Brightness.dark => Colors.white.withValues(alpha: 0.5),
    };
  }
}

class TextButton extends StatefulWidget {
  const TextButton({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    required this.label,
    required this.onPressed,
  });

  final EdgeInsets padding;
  final String label;
  final VoidCallback onPressed;

  @override
  State<TextButton> createState() => _TextButtonState();
}

class _TextButtonState extends State<TextButton> {
  @override
  Widget build(BuildContext context) {
    return InvisibleSelectableButtonSheet(
      padding: widget.padding,
      onActivated: widget.onPressed,
      child: Text(
        widget.label,
        style: TextStyle(
          color: _textColor(context),
        ),
      ),
    );
  }

  Color _textColor(BuildContext context) {
    return switch (LucidBrightness.of(context)) {
      Brightness.light => BrightTheme.textColor,
      Brightness.dark => DarkTheme.textColor,
    };
  }
}
