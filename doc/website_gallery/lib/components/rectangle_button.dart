import 'package:flutter/material.dart';
import 'package:lucid/lucid.dart';

class RectangleButtonDemo extends StatefulWidget {
  const RectangleButtonDemo({
    super.key,
  });

  @override
  State<RectangleButtonDemo> createState() => _RectangleButtonDemoState();
}

class _RectangleButtonDemoState extends State<RectangleButtonDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: RectangleButton(
            onPressed: () {},
            child: Text("Click Me!"),
          ),
        ),
      ),
    );
  }
}
