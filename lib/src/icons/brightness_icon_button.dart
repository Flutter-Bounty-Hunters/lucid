import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, Colors;
import 'package:flutter/widgets.dart';
import 'package:lucid/src/icons/sliding_icons.dart';

class BrightnessIconButton extends StatefulWidget {
  const BrightnessIconButton({
    super.key,
    required this.brightness,
    required this.onChange,
  });

  final Brightness brightness;
  final void Function(Brightness newValue) onChange;

  @override
  State<BrightnessIconButton> createState() => _BrightnessIconButtonState();
}

class _BrightnessIconButtonState extends State<BrightnessIconButton> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          switch (widget.brightness) {
            case Brightness.light:
              widget.onChange(Brightness.dark);
            case Brightness.dark:
              widget.onChange(Brightness.light);
          }
        },
        child: Container(
          width: 64,
          color: Colors.transparent,
          // ^ Apply a clear color for hit tests.
          child: SlidingIcon.verticalWithFade(
            top: Icon(
              Icons.light_mode,
              color: widget.brightness == Brightness.light ? Colors.black : Colors.white,
              size: 18,
            ),
            bottom: Icon(
              Icons.dark_mode,
              color: widget.brightness == Brightness.light ? Colors.black : Colors.white,
              size: 18,
            ),
            showTop: widget.brightness == Brightness.light,
          ),
          // child: SlidingIcon.horizontalWithFade(
          //   left: Icon(
          //     Icons.light_mode,
          //     color: widget.brightness == Brightness.light ? Colors.black : Colors.white,
          //   ),
          //   right: Icon(
          //     Icons.dark_mode,
          //     color: widget.brightness == Brightness.light ? Colors.black : Colors.white,
          //   ),
          //   showLeft: widget.brightness == Brightness.light,
          // ),
        ),
      ),
    );
  }
}
