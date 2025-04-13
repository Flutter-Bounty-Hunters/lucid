import 'package:flutter/material.dart';
import 'package:lucid/src/infrastructure/panes.dart';

/// An inherited widget that reports a desired visual brightness for its subtree.
class LucidBrightness extends StatefulWidget {
  static Brightness of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedLucidBrightness>()?.brightness ?? Brightness.light;

  const LucidBrightness({
    super.key,
    required this.brightness,
    required this.child,
  });

  final Brightness brightness;
  final Widget child;

  @override
  State<LucidBrightness> createState() => _LucidBrightnessState();
}

class _LucidBrightnessState extends State<LucidBrightness> {
  @override
  Widget build(BuildContext context) {
    return InheritedLucidBrightness(
      brightness: widget.brightness,
      child: DefaultTextStyle(
        style: TextStyle(
          color: _textColor(widget.brightness),
        ),
        child: widget.child,
      ),
    );
  }

  Color _textColor(Brightness brightness) {
    return switch (brightness) {
      Brightness.light => Colors.black,
      Brightness.dark => Colors.white,
    };
  }
}

/// An inherited widget that reports a desired visual brightness for its subtree.
class InheritedLucidBrightness extends InheritedWidget {
  const InheritedLucidBrightness({
    super.key,
    required this.brightness,
    required super.child,
  });

  final Brightness brightness;

  @override
  bool updateShouldNotify(InheritedLucidBrightness oldWidget) {
    return brightness != oldWidget.brightness;
  }
}

/// The border radius for a standard rectangle in Lucid, e.g., button background,
/// popover background, etc.
final sheetCornerRadius = BorderRadius.circular(4);

// TODO: implement this and make it available to widget trees
abstract interface class LucidMetrics {
  // Sheets
  BorderRadius get sheetCornerRadius;
  EdgeInsets get sheetPadding;
}

// TODO: implement this and make it available to widget trees
abstract interface class LucidCorePalette {
  Color get textColor;
  Color get hintColor;

  Color get accentColor;
}

abstract interface class LucidSheetPalette {
  Color get sheetBackgroundIdleColor;
  Color get sheetBackgroundHoverColor;
  Color get sheetBackgroundPressedColor;

  Color get sheetBorderIdleColor;
  Color get sheetBorderHoverColor;
  Color get sheetBorderFocusColor;
}

abstract interface class LucidPanePalette {
  Color paneBackgroundColor(PaneLevel level);

  Color get paneBorderColor;
}

class BrightTheme {
  static final borderIdleColor = Colors.black.withValues(alpha: 0.05);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.black.withValues(alpha: 0.03);
  static final backgroundHoverColor = Colors.black.withValues(alpha: 0.06);
  static final backgroundPressedColor = Colors.black.withValues(alpha: 0.10);

  static final paneTopBackgroundColor = Colors.white;
  static final paneHigherBackgroundColor = Colors.white;
  static final paneMiddleBackgroundColor = Colors.white;
  static final paneLowerBackgroundColor = Colors.grey.shade200;
  static final paneBottomBackgroundColor = Colors.grey.shade400;

  static final textColor = Colors.black;
  static final hintColor = Colors.black.withValues(alpha: 0.5);

  const BrightTheme._();
}

class DarkTheme {
  static final borderIdleColor = Colors.white.withValues(alpha: 0.10);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.white.withValues(alpha: 0.10); //Color(0xFF292D30);
  static final backgroundHoverColor = Colors.white.withValues(alpha: 0.06);
  static final backgroundPressedColor = Colors.white.withValues(alpha: 0.03);

  static final paneTopBackgroundColor = Color(0xFF43494d);
  static final paneHigherBackgroundColor = Color(0xFF33373b);
  static final paneMiddleBackgroundColor = Color(0xFF292D30);
  static final paneLowerBackgroundColor = Color(0xFF1a1d1f);
  static final paneBottomBackgroundColor = Color(0xFF0f1112);

  static final textColor = Colors.white;
  static final hintColor = Colors.white.withValues(alpha: 0.5);

  const DarkTheme._();
}

// const panelHighColor = Color(0xFF292D30);
// const panelLowColor = Color(0xFF1C2022);
// const dividerColor = Color(0xFF1C2022);
//
// const popoverBackgroundColor = Color(0xFF202224);
// const popoverBorderColor = Color(0xFF34353A);
