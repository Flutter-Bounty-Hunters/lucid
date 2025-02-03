import 'dart:ui';

import 'package:flutter/widgets.dart';

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
