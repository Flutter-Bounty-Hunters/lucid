import 'package:flutter/material.dart';

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

class BrightTheme {
  static final borderIdleColor = Colors.black.withValues(alpha: 0.10);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.white;
  static final backgroundHoverColor = Colors.black.withValues(alpha: 0.03);
  static final backgroundPressedColor = Colors.black.withValues(alpha: 0.10);

  static final textColor = Colors.black;
  static final hintColor = Colors.black.withValues(alpha: 0.5);

  const BrightTheme._();
}

class DarkTheme {
  static final borderIdleColor = Colors.white.withValues(alpha: 0.10);
  static const borderFocusColor = Colors.lightBlue;

  static final backgroundIdleColor = Colors.grey.shade900;
  static final backgroundHoverColor = Colors.white.withValues(alpha: 0.03);
  static final backgroundPressedColor = Colors.white.withValues(alpha: 0.10);

  static final textColor = Colors.white;
  static final hintColor = Colors.white.withValues(alpha: 0.5);

  const DarkTheme._();
}
