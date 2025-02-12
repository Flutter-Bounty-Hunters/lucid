import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucid/src/infrastructure/focus.dart';

import 'package:lucid/src/theme.dart';

/// A rectangular widget intended to server as the background of a button.
///
/// This sheet always displays a background color and a border.
///
/// Features:
///  * Configures itself based on the app brightness.
///  * Visually responds to hover (when [isEnabled] is `true`).
///  * Visually responds to press (when [isEnabled] is `true`).
///  * Visually shows a focused state.
///  * Reports activation when pressed (when [isEnabled] is `true`).
///  * Reports activation when [activationKey] is pressed (when [isEnabled] is `true`).
class ButtonSheet extends StatefulWidget {
  const ButtonSheet({
    super.key,
    this.focusNode,
    this.focusNodeDebugLabel,
    this.padding = defaultSheetPadding,
    this.isEnabled = true,
    this.activationKey = LogicalKeyboardKey.enter,
    this.onActivated,
    required this.child,
  });

  final FocusNode? focusNode;
  final String? focusNodeDebugLabel;

  final EdgeInsets padding;

  /// Whether this sheet should visually respond to hover and press, and
  /// report [onActivated] when pressed.
  final bool isEnabled;

  /// An (optional) key that, when pressed, calls [onActivated].
  final LogicalKeyboardKey? activationKey;

  /// Callback that's invoked when the user activates this sheet, either by
  /// tapping on it, or by pressing the [activationKey] when focused.
  final VoidCallback? onActivated;

  final Widget child;

  @override
  State<ButtonSheet> createState() => _ButtonSheetState();
}

class _ButtonSheetState extends State<ButtonSheet> {
  late FocusNode _focusNode;
  var _isHovering = false;
  var _isPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel);
  }

  @override
  void didUpdateWidget(ButtonSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return KeyActivatable(
      // ^ Must be ancestor to Focus.
      activate: widget.isEnabled ? widget.onActivated : null,
      activateKey: widget.activationKey,
      child: Focus(
        focusNode: widget.isEnabled ? _focusNode : null,
        debugLabel: widget.focusNodeDebugLabel,
        child: GestureDetector(
          onTapDown: (_) => setState(() {
            _isPressed = true;
          }),
          onTapUp: (_) => setState(() {
            _isPressed = false;

            if (widget.isEnabled) {
              widget.onActivated?.call();
            }
          }),
          onTapCancel: () => setState(() {
            _isPressed = false;
          }),
          child: MouseRegion(
            cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) => setState(() {
              _isHovering = true;
            }),
            onExit: (_) => setState(() {
              _isHovering = false;
            }),
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: sheetCornerRadius,
                    border: Border.all(color: _borderColor(brightness)),
                    color: _backgroundColor(brightness),
                  ),
                  padding: widget.padding,
                  child: widget.child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(Brightness brightness) {
    if (_focusNode.hasFocus) {
      return brightness == Brightness.light //
          ? BrightTheme.borderFocusColor
          : DarkTheme.borderFocusColor;
    }

    return brightness == Brightness.light //
        ? BrightTheme.borderIdleColor
        : DarkTheme.borderIdleColor;
  }

  Color _backgroundColor(Brightness brightness) {
    if (_isPressed && widget.isEnabled) {
      return brightness == Brightness.light //
          ? BrightTheme.backgroundPressedColor
          : DarkTheme.backgroundPressedColor;
    }

    if (_isHovering && widget.isEnabled) {
      return brightness == Brightness.light //
          ? BrightTheme.backgroundHoverColor
          : DarkTheme.backgroundHoverColor;
    }

    return brightness == Brightness.light //
        ? BrightTheme.backgroundIdleColor
        : DarkTheme.backgroundIdleColor;
  }
}

/// A rectangular widget, which is invisible when idle, intended to serve
/// as the background of a selectable button.
///
/// When this button isn't being hovered, or pressed, and it isn't focused,
/// or selected, this sheet doesn't display anything. I.e., this sheet is
/// invisible unless the user is interacting with it.
///
/// This button allows for a background and foreground color override. When
/// the background override is provided, instead of displaying a transparent
/// rectangle, the given background color is used instead. If you want a
/// standalone sheet with a background, consider using [ButtonSheet]. A background
/// override is made available for cases like a monthly calendar, where the
/// button for "today" might be decorated with a special background, but all
/// the other day buttons have invisible backgrounds.
///
/// Features:
///  * Configures itself based on the app brightness.
///  * Visually shows a focused state.
///  * Visually shows a selected state.
///  * Allows for a background color override, which paints a background when idle.
///  * Visually responds to hover (when [isEnabled] is `true`).
///  * Visually responds to press (when [isEnabled] is `true`).
///  * Reports activation when pressed (when [isEnabled] is `true`).
///  * Reports activation when [activationKey] is pressed (when [isEnabled] is `true`).
class InvisibleSelectableButtonSheet extends StatefulWidget {
  const InvisibleSelectableButtonSheet({
    super.key,
    this.focusNode,
    this.focusNodeDebugLabel,
    this.padding = defaultSheetPadding,
    this.isEnabled = true,
    this.isSelected = false,
    this.backgroundColorOverride,
    this.activationKey = LogicalKeyboardKey.enter,
    this.onActivated,
    required this.child,
  });

  final FocusNode? focusNode;
  final String? focusNodeDebugLabel;

  final EdgeInsets padding;

  /// Whether this sheet should visually respond to hover and press, and
  /// report [onActivated] when pressed.
  final bool isEnabled;

  /// Whether this sheet should display in a selected state, such as when
  /// this button sheet is one within a toggle group.
  final bool isSelected;

  /// A background color, which is displayed when idle.
  ///
  /// This color overrides the normal transparent background.
  final Color? backgroundColorOverride;

  /// An (optional) key that, when pressed, calls [onActivated].
  final LogicalKeyboardKey? activationKey;

  /// Callback that's invoked when the user activates this sheet, either by
  /// tapping on it, or by pressing the [activationKey] when focused.
  final VoidCallback? onActivated;

  final Widget child;

  @override
  State<InvisibleSelectableButtonSheet> createState() => _InvisibleSelectableButtonSheetState();
}

class _InvisibleSelectableButtonSheetState extends State<InvisibleSelectableButtonSheet> {
  late FocusNode _focusNode;
  var _isHovering = false;
  var _isPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Button");
  }

  @override
  void didUpdateWidget(InvisibleSelectableButtonSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return KeyActivatable(
      // ^ Must be ancestor to Focus.
      activate: widget.isEnabled ? widget.onActivated : null,
      activateKey: widget.activationKey,
      child: Focus(
        focusNode: widget.isEnabled ? _focusNode : null,
        debugLabel: widget.focusNodeDebugLabel,
        child: GestureDetector(
          onTapDown: (_) => setState(() {
            _isPressed = true;
          }),
          onTapUp: (_) => setState(() {
            _isPressed = false;

            if (widget.isEnabled) {
              widget.onActivated?.call();
            }
          }),
          onTapCancel: () => setState(() {
            _isPressed = false;
          }),
          child: MouseRegion(
            cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) => setState(() {
              _isHovering = true;
            }),
            onExit: (_) => setState(() {
              _isHovering = false;
            }),
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: sheetCornerRadius,
                    border: Border.all(color: _borderColor(brightness)),
                    color: _backgroundColor(brightness),
                  ),
                  padding: widget.padding,
                  child: widget.child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(Brightness brightness) {
    if (_focusNode.hasFocus) {
      return Colors.lightBlue;
    }

    return Colors.transparent;
  }

  Color _backgroundColor(Brightness brightness) {
    if (widget.isSelected) {
      if (_isPressed) {
        return brightness == Brightness.light //
            ? Colors.black.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.90);
      }

      if (_isHovering) {
        return brightness == Brightness.light //
            ? Colors.black.withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.75);
      }

      return brightness == Brightness.light //
          ? Colors.black
          : Colors.white;
    }

    if (_isPressed && widget.isEnabled) {
      return brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.10);
    }

    if (_isHovering && widget.isEnabled) {
      return brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.03);
    }

    if (widget.backgroundColorOverride != null) {
      return widget.backgroundColorOverride!;
    }

    return Colors.transparent;
  }
}

/// A rounded rectangle widget with a background color and a border, which adapts
/// to the current app brightness.
class Sheet extends StatelessWidget {
  const Sheet({
    super.key,
    this.padding = defaultSheetPadding,
    required this.child,
  });

  final EdgeInsets padding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: sheetCornerRadius,
        border: Border.all(color: _borderColor(brightness)),
        color: _backgroundColor(brightness),
      ),
      padding: padding,
      child: child,
    );
  }

  Color _borderColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.10);
  }

  Color _backgroundColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.white
        : Colors.grey.shade900;
  }
}

const defaultSheetPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

class Pane extends StatelessWidget {
  const Pane({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return Container(
      color: _backgroundColor(brightness),
      child: child,
    );
  }

  Color _backgroundColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.white
        : Colors.grey.shade900;
  }
}

class Divider extends StatelessWidget {
  const Divider.horizontal({super.key}) : direction = DividerDirection.horizontal;

  const Divider.vertical({super.key}) : direction = DividerDirection.vertical;

  final DividerDirection direction;

  @override
  Widget build(BuildContext context) {
    return switch (direction) {
      DividerDirection.horizontal => Container(height: 1, color: _color(context)),
      DividerDirection.vertical => Container(width: 1, color: _color(context)),
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
