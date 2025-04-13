import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class RectangleButtonDemo extends StatefulWidget {
  const RectangleButtonDemo({super.key});

  @override
  State<RectangleButtonDemo> createState() => _RectangleButtonDemoState();
}

class _RectangleButtonDemoState extends State<RectangleButtonDemo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: RectangleButton(
          onPressed: () {},
          child: Text("Press Me!"),
        ),
      ),
    );
  }
}
