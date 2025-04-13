import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lucid/src/infrastructure/sheets.dart';
import 'package:lucid/src/theme.dart';

class RectangleButton extends StatelessWidget {
  const RectangleButton({
    super.key,
    this.size,
    this.padding = defaultRectangleButtonPadding,
    this.lightStyle,
    this.darkStyle,
    required this.onPressed,
    required this.child,
  }) : assert(
          size == null || padding == EdgeInsets.zero,
          "You should provide a size OR padding but not both because size implies explicit sizing and padding implies implicit sizing.",
        );

  /// The size of this [RectangleButton], if an explicit size is desired.
  ///
  /// When providing a [size], don't provide a [padding], because padding implies
  /// intrinsic sizing.
  final Size? size;

  /// Padding added between the button boundary and the [child].
  ///
  /// When using a non-zero [padding], don't provide a [size], because size implies
  /// explicit sizing.
  final EdgeInsets padding;

  /// The styles applied to this button in light mode.
  ///
  /// When this style isn't supplied, this button will look for an inherited
  /// [DefaultRectangleButtonStyle]. If no inherited style is available, no
  /// default styles are changed.
  final RectangleButtonStyle? lightStyle;

  /// The styles applied to this button in dark mode.
  ///
  /// When this style isn't supplied, this button will look for an inherited
  /// [DefaultRectangleButtonStyle]. If no inherited style is available, no
  /// default styles are changed.
  final RectangleButtonStyle? darkStyle;

  final VoidCallback onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = _style(context);

    return ButtonSheet(
      padding: EdgeInsets.zero,
      onActivated: onPressed,
      child: Padding(
        padding: padding,
        child: DefaultTextStyle(
          style: _textStyle(style),
          child: IconTheme(
            data: _iconTheme(context, style),
            child: child,
          ),
        ),
      ),
    );
  }

  RectangleButtonStyle _style(BuildContext context) => switch (LucidBrightness.of(context)) {
        Brightness.light =>
          lightStyle ?? DefaultRectangleButtonStyle.of(context)?.light ?? const RectangleButtonStyle(),
        Brightness.dark => darkStyle ?? DefaultRectangleButtonStyle.of(context)?.dark ?? const RectangleButtonStyle(),
      };

  TextStyle _textStyle(RectangleButtonStyle style) {
    return TextStyle(
      color: style.foregroundColor,
    );
  }

  IconThemeData _iconTheme(BuildContext context, RectangleButtonStyle style) {
    return IconTheme.of(context).copyWith(
      color: style.foregroundColor,
    );
  }
}

const defaultRectangleButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

class DefaultRectangleButtonStyle extends InheritedWidget {
  static DefaultRectangleButtonStyle? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DefaultRectangleButtonStyle>();

  const DefaultRectangleButtonStyle({
    super.key,
    this.light,
    this.dark,
    required super.child,
  });

  final RectangleButtonStyle? light;
  final RectangleButtonStyle? dark;

  @override
  bool updateShouldNotify(DefaultRectangleButtonStyle oldWidget) {
    return oldWidget.light != light || oldWidget.dark != dark;
  }
}

class RectangleButtonStyle {
  const RectangleButtonStyle({
    this.foregroundColor,
    this.transitionDuration = Duration.zero,
  });

  final Color? foregroundColor;

  final Duration transitionDuration;

  // Border color and width
  // Fill color
}
