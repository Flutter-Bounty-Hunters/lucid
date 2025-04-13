import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucid/src/theme.dart';

class Divider extends StatelessWidget {
  const Divider.horizontal({super.key}) : direction = DividerDirection.horizontal;

  const Divider.vertical({super.key}) : direction = DividerDirection.vertical;

  final DividerDirection direction;

  @override
  Widget build(BuildContext context) {
    print("Divider color: ${_color(context)}");

    return switch (direction) {
      DividerDirection.horizontal => AnimatedContainer(
          height: 1,
          color: _color(context),
          duration: const Duration(milliseconds: 250),
        ),
      DividerDirection.vertical => AnimatedContainer(
          width: 1,
          color: _color(context),
          duration: const Duration(milliseconds: 250),
        ),
    };
  }

  Color _color(BuildContext context) {
    return switch (LucidBrightness.of(context)) {
      Brightness.light => BrightTheme.borderIdleColor,
      Brightness.dark => DarkTheme.borderIdleColor,
    };
  }
}

enum DividerDirection {
  horizontal,
  vertical;
}
