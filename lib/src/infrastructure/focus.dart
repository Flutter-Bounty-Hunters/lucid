import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that, when something in the app has primary focus, adds a tap handler
/// that clears all focus when tapped.
///
/// This widget should typically be placed above all other visual widgets in the
/// widget tree.
class TapToClearFocus extends StatefulWidget {
  const TapToClearFocus({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TapToClearFocus> createState() => _TapToClearFocusState();
}

class _TapToClearFocusState extends State<TapToClearFocus> {
  final _focusScopeNode = FocusScopeNode(debugLabel: "TapToClearFocus");

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _removeFocus() {
    // Move primary focus to this scope node, which thereby removes focus from
    // all subtree widgets.
    _focusScopeNode.requestScopeFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      debugLabel: "TapToClearFocus",
      child: ListenableBuilder(
        listenable: _focusScopeNode,
        builder: (context, child) {
          return Listener(
            onPointerUp: _focusScopeNode.hasFocus && !_focusScopeNode.hasPrimaryFocus //
                ? (_) => _removeFocus()
                : null,
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// A logical widget that listens for a given [activateKey] to be pressed and then
/// calls [activate].
///
/// This widget intercepts the key press by using a [Shortcuts] and [Actions]
/// widget pair.
class KeyActivatable extends StatelessWidget {
  const KeyActivatable({
    super.key,
    this.activateKey = LogicalKeyboardKey.enter,
    this.activate,
    required this.child,
  });

  final LogicalKeyboardKey? activateKey;
  final VoidCallback? activate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        if (activate != null && activateKey != null) //
          LogicalKeySet(activateKey!): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          if (activate != null) //
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) => activate?.call(),
            ),
        },
        child: child,
      ),
    );
  }
}

/// A logical widget that listens for a given [dismissKey] to be pressed and then
/// calls [dismiss].
///
/// This widget intercepts the key press by using a [Shortcuts] and [Actions]
/// widget pair.
class KeyDismissable extends StatelessWidget {
  const KeyDismissable({
    super.key,
    this.dismissKey = LogicalKeyboardKey.escape,
    this.dismiss,
    required this.child,
  });

  final LogicalKeyboardKey dismissKey;
  final VoidCallback? dismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        if (dismiss != null) //
          LogicalKeySet(dismissKey): const DismissIntent(),
      },
      child: Actions(
        actions: {
          if (dismiss != null) //
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) => dismiss?.call(),
            ),
        },
        child: child,
      ),
    );
  }
}
