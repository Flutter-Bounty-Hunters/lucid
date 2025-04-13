import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class SlidingIconDemo extends StatefulWidget {
  const SlidingIconDemo({super.key});

  @override
  State<SlidingIconDemo> createState() => _SlidingIconDemoState();
}

class _SlidingIconDemoState extends State<SlidingIconDemo> {
  bool _showTop = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          width: 72,
          height: 72,
          child: ButtonSheet(
            onActivated: () => setState(() {
              _showTop = !_showTop;
            }),
            child: SlidingIcon.verticalWithFade(
              top: Icon(
                Icons.star_border,
                color: _iconColor(context),
              ),
              bottom: Icon(
                Icons.star,
                color: _iconColor(context),
              ),
              showTop: _showTop,
            ),
          ),
        ),
      ),
    );
  }

  Color _iconColor(BuildContext context) {
    return switch (LucidBrightness.of(context)) {
      Brightness.light => Colors.black,
      Brightness.dark => Colors.white,
    };
  }
}
