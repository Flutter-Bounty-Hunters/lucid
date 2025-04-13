import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class TriStateIconButtonDemo extends StatefulWidget {
  const TriStateIconButtonDemo({super.key});

  @override
  State<TriStateIconButtonDemo> createState() => _TriStateIconButtonDemoState();
}

class _TriStateIconButtonDemoState extends State<TriStateIconButtonDemo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: Icons.add,
            iconSize: 18,
            iconColor: Colors.white,
            onPressed: () {},
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
