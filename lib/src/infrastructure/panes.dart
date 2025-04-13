import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lucid/src/theme.dart';

class Pane extends StatelessWidget {
  const Pane.top({
    super.key,
    required this.child,
  }) : level = PaneLevel.top;

  const Pane.higher({
    super.key,
    required this.child,
  }) : level = PaneLevel.higher;

  const Pane({
    super.key,
    required this.child,
  }) : level = PaneLevel.middle;

  const Pane.lower({
    super.key,
    required this.child,
  }) : level = PaneLevel.lower;

  const Pane.bottom({
    super.key,
    required this.child,
  }) : level = PaneLevel.bottom;

  final PaneLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return AnimatedContainer(
      color: _backgroundColor(brightness),
      duration: const Duration(milliseconds: 250),
      child: child,
    );
  }

  Color _backgroundColor(Brightness brightness) {
    switch (level) {
      case PaneLevel.top:
        return brightness == Brightness.light //
            ? BrightTheme.paneTopBackgroundColor
            : DarkTheme.paneTopBackgroundColor;
      case PaneLevel.higher:
        return brightness == Brightness.light //
            ? BrightTheme.paneHigherBackgroundColor
            : DarkTheme.paneHigherBackgroundColor;
      case PaneLevel.middle:
        return brightness == Brightness.light //
            ? BrightTheme.paneMiddleBackgroundColor
            : DarkTheme.paneMiddleBackgroundColor;
      case PaneLevel.lower:
        return brightness == Brightness.light //
            ? BrightTheme.paneLowerBackgroundColor
            : DarkTheme.paneLowerBackgroundColor;
      case PaneLevel.bottom:
        return brightness == Brightness.light //
            ? BrightTheme.paneBottomBackgroundColor
            : DarkTheme.paneBottomBackgroundColor;
    }
  }
}

enum PaneLevel {
  top,
  higher,
  middle,
  lower,
  bottom;
}
