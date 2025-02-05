import 'package:flutter/material.dart';

/// An inherited widget that reports a desired visual brightness for its subtree.
class LucidBrightness extends InheritedWidget {
  static Brightness of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LucidBrightness>()?.brightness ?? Brightness.light;

  const LucidBrightness({
    super.key,
    required this.brightness,
    required super.child,
  });

  final Brightness brightness;

  @override
  bool updateShouldNotify(LucidBrightness oldWidget) {
    return brightness != oldWidget.brightness;
  }
}

/// The border radius for a standard rectangle in Lucid, e.g., button background,
/// popover background, etc.
final sheetCornerRadius = BorderRadius.circular(4);

class BrightTheme {
  static final borderIdleColor = Colors.black.withValues(alpha: 0.10);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.white;
  static final backgroundHoverColor = Colors.black.withValues(alpha: 0.03);
  static final backgroundPressedColor = Colors.black.withValues(alpha: 0.10);

  const BrightTheme._();
}

class DarkTheme {
  static final borderIdleColor = Colors.white.withValues(alpha: 0.10);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.grey.shade900;
  static final backgroundHoverColor = Colors.white.withValues(alpha: 0.03);
  static final backgroundPressedColor = Colors.white.withValues(alpha: 0.10);

  const DarkTheme._();
}
