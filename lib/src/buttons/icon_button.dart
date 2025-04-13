import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucid/src/infrastructure/sheets.dart';

class IconButton extends StatefulWidget {
  const IconButton({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    this.isEnabled = true,
    this.isActive = false,
    required this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final Color iconColor;

  final bool isEnabled;
  final bool isActive;

  final VoidCallback onPressed;

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ActivatableButtonSheet(
        isEnabled: widget.isEnabled,
        isActive: widget.isActive,
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
