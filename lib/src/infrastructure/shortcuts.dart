import 'package:flutter/widgets.dart';

/// An [Intent] that wants to increment something, e.g., increase from `5` to `6`
/// when the up arrow is pressed.
class IncrementIntent extends Intent {
  const IncrementIntent();
}

/// An [Intent] that wants to decrement something, e.g., decrease from `6` to `5`
/// when the down arrow is pressed.
class DecrementIntent extends Intent {
  const DecrementIntent();
}
