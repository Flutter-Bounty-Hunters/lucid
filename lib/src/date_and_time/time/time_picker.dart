import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lucid/src/infrastructure/sheets.dart';
import 'package:lucid/src/infrastructure/shortcuts.dart';
import 'package:lucid/src/theme.dart';

class TimePicker extends StatefulWidget {
  static const hourKey = ValueKey("hour_component");
  static const minuteKey = ValueKey("minute_component");
  static const secondKey = ValueKey("second_component");
  static const periodKey = ValueKey("period_component");

  const TimePicker({
    super.key,
    this.value,
    this.timeResolution = TimeResolution.second,
    this.height = defaultTimePickerHeight,
    this.timeComponentWidth = defaultTimeComponentWidth,
    this.showPeriodSelector = true,
    required this.onNewTimeRequested,
  });

  final LocalTime? value;
  final TimeResolution timeResolution;
  final double height;
  final double timeComponentWidth;
  final bool showPeriodSelector;

  final void Function(LocalTime?) onNewTimeRequested;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

const defaultTimePickerHeight = 40.0;
const defaultTimeComponentWidth = 54.0;

class _TimePickerState extends State<TimePicker> {
  // We maintain a copy of the time value so that we can reduce its time
  // resolution without needing to report back to the client.
  //
  // For example: Imagine we're given the time "11:45:15" but our time resolution
  // is set to "hours". The value we're given should actually be "11". If we
  // try to enforce this with the client, then we face two problems:
  //
  //   1. We'll need to call back with a new value during didUpdateWidget(), which
  //      would likely result in an illegal setState() call from the client.
  //   2. If the client doesn't update the value, we'll be stuck in an endless loop.
  //
  // This value should never be written from within this State object, other than
  // to reduce resolution, as requested.
  LocalTime? _value;

  @override
  void initState() {
    super.initState();

    _value = widget.value;
    _forgetExtraResolution();
  }

  @override
  void didUpdateWidget(TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _value = widget.value;
      _forgetExtraResolution();
    }
    if (widget.timeResolution != oldWidget.timeResolution) {
      _forgetExtraResolution();
    }
  }

  void _forgetExtraResolution() {
    _value = _value?.enforceResolution(widget.timeResolution);
  }

  void _updateHours(int? newHours) {
    final newValue = widget.value != null //
        ? widget.value!.copyWith(hour: newHours)
        : LocalTime(newHours);

    widget.onNewTimeRequested(newValue);
  }

  void _updateMinutes(int? newMinutes) {
    final newValue = widget.value != null //
        ? widget.value!.copyWith(minute: newMinutes)
        : LocalTime(null, newMinutes);

    widget.onNewTimeRequested(newValue);
  }

  void _updateSeconds(int? newSeconds) {
    final newValue = widget.value != null //
        ? widget.value!.copyWith(second: newSeconds)
        : LocalTime(null, null, newSeconds);

    widget.onNewTimeRequested(newValue);
  }

  void _updatePeriod(TimePeriod newPeriod) {
    final newValue = widget.value != null //
        ? widget.value!.copyWith(period: newPeriod)
        : LocalTime(null, null, null, newPeriod);

    widget.onNewTimeRequested(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 4,
        children: [
          _TimeComponent(
            key: TimePicker.hourKey,
            value: widget.value?.hour,
            // TODO: make 12 vs 24 hour configurable
            maxValue: 12,
            minValue: 1,
            shortLabel: "hr",
            width: widget.timeComponentWidth,
            height: widget.height,
            onChangeRequested: _updateHours,
          ),
          if (widget.timeResolution >= TimeResolution.minute) //
            _TimeComponent(
              key: TimePicker.minuteKey,
              value: widget.value?.minute,
              maxValue: 59,
              shortLabel: "m",
              width: widget.timeComponentWidth,
              height: widget.height,
              onChangeRequested: _updateMinutes,
            ),
          if (widget.timeResolution >= TimeResolution.second) //
            _TimeComponent(
              key: TimePicker.secondKey,
              value: widget.value?.second,
              maxValue: 59,
              shortLabel: "s",
              width: widget.timeComponentWidth,
              height: widget.height,
              onChangeRequested: _updateSeconds,
            ),
          if (widget.showPeriodSelector) //
            _PeriodSelector(
              key: TimePicker.periodKey,
              timePeriod: widget.value?.period ?? TimePeriod.pm,
              height: widget.height,
              onPeriodChangeRequested: _updatePeriod,
            ),
        ],
      ),
    );
  }
}

class _TimeComponent extends StatefulWidget {
  const _TimeComponent({
    super.key,
    // ignore: unused_element
    this.focusNode,
    // ignore: unused_element
    this.focusNodeDebugLabel,
    this.value,
    required this.maxValue,
    this.minValue = 0,
    required this.shortLabel,
    required this.width,
    required this.height,
    required this.onChangeRequested,
  });

  final FocusNode? focusNode;
  final String? focusNodeDebugLabel;

  final int? value;
  final int maxValue;
  final int minValue;

  final String shortLabel;

  final double width;
  final double height;

  final void Function(int? newValue) onChangeRequested;

  @override
  State<_TimeComponent> createState() => _TimeComponentState();
}

class _TimeComponentState extends State<_TimeComponent> with TextInputClient {
  late FocusNode _focusNode;

  final _caretBlinkController = BlinkController.withTimer();
  TextInputConnection? _imeConnection;

  @override
  void initState() {
    super.initState();

    _focusNode = (widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel))..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_TimeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = (widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel))..addListener(_onFocusChange);

      // Ensure our focus-related decisions are up to date with the new node.
      _onFocusChange();
    }

    if (widget.value != oldWidget.value) {
      // Update the IME value, if we're currently connected.
      _sendValueToIme();

      // Reset the caret to fully opaque. This way, every time the user
      // types a digit, or increments/decrements the value, there's a little
      // visual indication that a change occurred.
      _caretBlinkController.jumpToOpaque();
    }
  }

  @override
  void dispose() {
    _caretBlinkController.dispose();

    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _onPressed() {
    _focusNode.requestFocus();
  }

  void _incrementTime() {
    late final int newValue;
    if (widget.value == null) {
      newValue = widget.minValue;
    } else {
      newValue = max(
        (widget.value! + 1) % (widget.maxValue + 1),
        widget.minValue,
      );
    }

    widget.onChangeRequested(newValue);
  }

  void _decrementTime() {
    late final int newValue;
    if (widget.value == null) {
      newValue = widget.maxValue;
    } else if (widget.value == widget.minValue) {
      newValue = widget.maxValue;
    } else {
      newValue = max(
        (widget.value! - 1) % (widget.maxValue + 1),
        widget.minValue,
      );
    }

    widget.onChangeRequested(newValue);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _imeConnection == null) {
      _imeConnection = TextInput.attach(
          this,
          TextInputConfiguration(
            inputType: TextInputType.number,
            autocorrect: false,
            enableSuggestions: false,
            enableInteractiveSelection: false,
            keyboardAppearance: LucidBrightness.of(context),
            enableIMEPersonalizedLearning: false,
          ));
      _imeConnection!
        ..show()
        ..setEditingState(currentTextEditingValue);
    } else if (!_focusNode.hasFocus && _imeConnection != null) {
      _imeConnection!.close();
      _imeConnection = null;
    }
  }

  @override
  TextEditingValue get currentTextEditingValue => TextEditingValue(
        text: _valueAsText,
        selection: TextSelection.collapsed(offset: _valueAsText.length),
      );
  String get _valueAsText => widget.value != null ? "${widget.value!}" : "";

  @override
  void updateEditingValue(TextEditingValue value) {
    final imeText = value.text;
    final onlyDigits = imeText.replaceAll(RegExp(r"[^0-9]"), "");
    final onlyDigitsMaxTwo = onlyDigits.length > 2 ? onlyDigits.substring(onlyDigits.length - 2) : onlyDigits;
    final newValue = int.tryParse(onlyDigitsMaxTwo);

    _sendValueToIme();

    widget.onChangeRequested(newValue);
  }

  void _doImeBackspace() {
    if (_imeConnection == null) {
      return;
    }

    final imeText = currentTextEditingValue.text;
    if (imeText.isEmpty) {
      return;
    }
    if (imeText.length == 1) {
      // The user deleted the only number in the field. Nullify the value.
      widget.onChangeRequested(null);
      return;
    }

    // The user deleted one of two digits.
    widget.onChangeRequested(int.parse(imeText.substring(0, imeText.length - 1)));
  }

  void _sendValueToIme() {
    if (_imeConnection == null) {
      return;
    }

    _imeConnection!.setEditingState(currentTextEditingValue);
  }

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void performAction(TextInputAction action) {
    // TODO: implement performAction
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void connectionClosed() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return TapRegion(
      onTapOutside: (_) => _focusNode.unfocus(),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ListenableBuilder(
          listenable: _focusNode,
          builder: (context, child) {
            return Shortcuts(
              shortcuts: {
                if (_focusNode.hasFocus) ...{
                  LogicalKeySet(LogicalKeyboardKey.arrowUp): const IncrementIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowDown): const DecrementIntent(),
                  LogicalKeySet(LogicalKeyboardKey.backspace): const DeleteCharacterIntent(forward: false),
                }
              },
              child: Actions(
                actions: {
                  if (_focusNode.hasFocus) ...{
                    DismissIntent: CallbackAction<DismissIntent>(
                      onInvoke: (intent) => _focusNode.unfocus(),
                    ),
                    IncrementIntent: CallbackAction<IncrementIntent>(
                      onInvoke: (intent) => _incrementTime(),
                    ),
                    DecrementIntent: CallbackAction<DecrementIntent>(
                      onInvoke: (intent) => _decrementTime(),
                    ),
                    DeleteCharacterIntent: CallbackAction<DeleteCharacterIntent>(
                      onInvoke: (intent) => _doImeBackspace(),
                    ),
                  }
                },
                child: FieldSheet(
                  focusNode: _focusNode,
                  onPressed: _onPressed,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text.rich(
                          _styledTimeText(brightness),
                        ),
                        Baseline(
                          baseline: _valueFontSize * _valueLineHeight,
                          baselineType: TextBaseline.alphabetic,
                          child: BlinkingCaret(
                            blinkController: _caretBlinkController,
                            blink: _focusNode.hasFocus,
                            width: 2,
                            height: 18,
                            color: _caretColor(brightness),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.shortLabel,
                          style: TextStyle(
                            color: _textColor(brightness),
                            fontSize: 10,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TextSpan _styledTimeText(Brightness brightness) {
    final hintTextSpan = TextSpan(
      text: widget.value == null //
          ? "00"
          : widget.value.toString().length == 1 //
              ? "0"
              : "",
      style: TextStyle(
        color: _hintTextColor(brightness),
      ),
    );

    final valueTextSpan = TextSpan(
      text: widget.value != null ? "${widget.value}" : "",
      style: TextStyle(
        color: _textColor(brightness),
      ),
    );

    return TextSpan(
      children: [
        hintTextSpan,
        valueTextSpan,
      ],
      style: TextStyle(
        fontSize: _valueFontSize,
        height: _valueLineHeight,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  double get _valueFontSize => 18;
  double get _valueLineHeight => 1.0;

  Color _textColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.black
        : Colors.white;
  }

  Color _hintTextColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.grey.shade400
        : Colors.grey.shade800;
  }

  Color _caretColor(Brightness brightness) {
    if (!_focusNode.hasFocus) {
      return Colors.transparent;
    }

    return brightness == Brightness.light //
        ? BrightTheme.borderFocusColor
        : DarkTheme.borderFocusColor;
  }
}

class BlinkingCaret extends StatefulWidget {
  const BlinkingCaret({
    super.key,
    this.blinkController,
    this.blink = true,
    required this.width,
    required this.height,
    required this.color,
  });

  final BlinkController? blinkController;
  final bool blink;

  final double width;
  final double height;

  final Color color;

  @override
  State<BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<BlinkingCaret> {
  late BlinkController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = widget.blinkController ?? BlinkController.withTimer();

    if (widget.blink) {
      _blinkController.startBlinking();
    }
  }

  @override
  void didUpdateWidget(BlinkingCaret oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.blinkController != oldWidget.blinkController) {
      _blinkController.stopBlinking();
      _blinkController = widget.blinkController ?? BlinkController.withTimer();

      if (widget.blink) {
        _blinkController.startBlinking();
      }
    } else if (widget.blink != oldWidget.blink) {
      if (widget.blink) {
        _blinkController.startBlinking();
      } else {
        _blinkController.stopBlinking();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _blinkController,
      builder: (context, child) {
        return Opacity(
          opacity: _blinkController.opacity,
          child: child!,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        color: widget.color,
      ),
    );
  }
}

class BlinkController with ChangeNotifier {
  // Controls whether or not all BlinkControllers animate. This is intended
  // to be used by tests to disable animations so that pumpAndSettle() doesn't
  // time out.
  @visibleForTesting
  static bool indeterminateAnimationsEnabled = true;

  BlinkController({
    Duration flashPeriod = const Duration(milliseconds: 500),
  })  : _isUsingTicker = true,
        _flashPeriod = flashPeriod;

  BlinkController.withTimer({
    Duration flashPeriod = const Duration(milliseconds: 500),
  })  : _isUsingTicker = false,
        _flashPeriod = flashPeriod;

  void attach(TickerProvider tickerProvider) {
    _ticker = tickerProvider.createTicker(_onTick);
  }

  void detach() {
    _ticker?.dispose();
    _ticker = null;
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  late final bool _isUsingTicker;
  Ticker? _ticker;
  Duration _lastBlinkTime = Duration.zero;

  Timer? _timer;

  final Duration _flashPeriod;

  /// Duration to switch between visible and invisible.
  Duration get flashPeriod => _flashPeriod;

  /// Returns `true` if this controller is currently animating a blinking
  /// signal, or `false` if it's not.
  bool get isBlinking =>
      (_ticker != null || _timer != null) && (_ticker != null ? _ticker!.isTicking : _timer?.isActive ?? false);

  bool _isBlinkingEnabled = true;
  set isBlinkingEnabled(bool newValue) {
    if (newValue == _isBlinkingEnabled) {
      return;
    }

    _isBlinkingEnabled = newValue;
    if (!_isBlinkingEnabled) {
      stopBlinking();
    }
    notifyListeners();
  }

  bool _isVisible = true;
  double get opacity => _isVisible ? 1.0 : 0.0;

  void startBlinking() {
    if (!indeterminateAnimationsEnabled) {
      // Never animate a blink when the app/test wants to avoid
      // indeterminate animations.
      return;
    }

    if (_isUsingTicker) {
      // We're using a Ticker to blink. Restart it.
      _ticker?.stop();
      _ticker?.start();
    } else {
      // We're using a Timer to blink. Restart it.
      _timer?.cancel();
      _timer = Timer(_flashPeriod, _blink);
    }

    _lastBlinkTime = Duration.zero;
    notifyListeners();
  }

  void stopBlinking() {
    _isVisible = true; // If we're not blinking then we need to be visible

    if (_isUsingTicker) {
      // We're using a Ticker to blink. Stop it.
      _ticker?.stop();
      _ticker = null;
    } else {
      // We're using a Timer to blink. Stop it.
      _timer?.cancel();
      _timer = null;
    }

    notifyListeners();
  }

  /// Make the object completely opaque, and restart the blink timer.
  void jumpToOpaque() {
    final wasBlinking = isBlinking;
    stopBlinking();

    if (!_isBlinkingEnabled) {
      return;
    }

    if (wasBlinking) {
      startBlinking();
    }
  }

  void _onTick(Duration elapsedTime) {
    if (elapsedTime - _lastBlinkTime >= _flashPeriod) {
      _blink();
      _lastBlinkTime = elapsedTime;
    }
  }

  void _blink() {
    _isVisible = !_isVisible;
    notifyListeners();

    if (_timer != null && _isBlinkingEnabled) {
      _timer = Timer(_flashPeriod, _blink);
    }
  }
}

class FieldSheet extends StatefulWidget {
  const FieldSheet({
    super.key,
    this.focusNode,
    this.focusNodeDebugLabel,
    this.isEnabled = true,
    this.onPressed,
    required this.child,
  });

  final FocusNode? focusNode;
  final String? focusNodeDebugLabel;

  final bool isEnabled;

  final VoidCallback? onPressed;

  final Widget child;

  @override
  State<FieldSheet> createState() => _FieldSheetState();
}

class _FieldSheetState extends State<FieldSheet> {
  late FocusNode _focusNode;

  var _isHovering = false;
  var _isPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.focusNodeDebugLabel);
  }

  @override
  void didUpdateWidget(FieldSheet oldWidget) {
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

    return Focus(
      focusNode: _focusNode,
      debugLabel: widget.focusNodeDebugLabel,
      child: GestureDetector(
        onTapDown: (_) => setState(() {
          _isPressed = true;
        }),
        onTapUp: (_) => setState(() {
          _isPressed = false;

          if (widget.isEnabled) {
            widget.onPressed?.call();
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
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: _backgroundColor(brightness),
                  border: Border.all(color: _borderColor(brightness)),
                  borderRadius: sheetCornerRadius,
                ),
                child: widget.child,
              );
            },
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

class _PeriodSelector extends StatefulWidget {
  const _PeriodSelector({
    super.key,
    // ignore: unused_element
    this.focusNode,
    required this.timePeriod,
    required this.height,
    required this.onPeriodChangeRequested,
  });

  final FocusNode? focusNode;

  final TimePeriod timePeriod;
  final double height;

  final void Function(TimePeriod) onPeriodChangeRequested;

  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;

  late final Ticker _ticker;
  Simulation? _slideSimulation;
  double _slideOffset = 0;
  double _currentVelocity = 0;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    _ticker = createTicker(_onSlideTick);
    _slideToPeriod();
  }

  @override
  void didUpdateWidget(_PeriodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }

    if (widget.timePeriod != oldWidget.timePeriod || widget.height != oldWidget.height) {
      _slideToPeriod();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _slideToPeriod() {
    _ticker.stop();

    final endSlideOffset = widget.timePeriod == TimePeriod.pm ? 0.0 : -widget.height;
    if (endSlideOffset == _slideOffset) {
      // We're already at the destination.
      return;
    }

    _slideSimulation = SpringSimulation(
      const SpringDescription(
        mass: 0.5,
        stiffness: 300,
        damping: 45,
      ),
      _slideOffset, // Start value
      endSlideOffset, // End value
      _currentVelocity, // Initial velocity
    );

    _ticker.start();
  }

  void _onSlideTick(Duration elapsedTime) {
    if (_slideSimulation == null) {
      _ticker.stop();
      return;
    }

    setState(() {
      _slideOffset = _slideSimulation!.x(elapsedTime.inMilliseconds / 1000);
      _currentVelocity = _slideSimulation!.dx(elapsedTime.inMilliseconds / 1000);
    });

    if (_slideSimulation!.isDone(elapsedTime.inMilliseconds / 1000)) {
      _ticker.stop();
      _slideSimulation = null;
      _currentVelocity = 0;
    }
  }

  void onPressed() {
    widget.onPeriodChangeRequested(
      widget.timePeriod == TimePeriod.pm ? TimePeriod.am : TimePeriod.pm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return SizedBox(
      height: widget.height,
      child: ListenableBuilder(
          listenable: _focusNode,
          builder: (context, child) {
            return Actions(
              actions: {
                if (_focusNode.hasFocus) ...{
                  DismissIntent: CallbackAction<DismissIntent>(
                    onInvoke: (intent) => _focusNode.unfocus(),
                  ),
                }
              },
              child: InvisibleSelectableButtonSheet(
                focusNode: _focusNode,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onActivated: onPressed,
                child: IgnorePointer(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 1),
                          Colors.white.withValues(alpha: 1),
                          Colors.white.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.4, 0.6, 1],
                      ).createShader(rect);
                    },
                    child: ClipRect(
                      child: OverflowBox(
                        maxHeight: 2 * widget.height,
                        alignment: Alignment.topCenter,
                        fit: OverflowBoxFit.deferToChild,
                        child: Transform.translate(
                          offset: Offset(0, _slideOffset),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPm(brightness),
                              _buildAm(brightness),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildAm(Brightness brightness) {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: Text(
          "AM",
          style: TextStyle(
            color: _textColor(brightness),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPm(Brightness brightness) {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: Text(
          "PM",
          style: TextStyle(
            color: _textColor(brightness),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _textColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.black
        : Colors.white;
  }
}

/// A local time, e.g., a time of day without knowledge of any timezone.
class LocalTime {
  const LocalTime([this.hour, this.minute, this.second, this.period])
      : assert(hour == null || (0 <= hour && hour <= 24)),
        assert(minute == null || (0 <= minute && minute < 60)),
        assert(second == null || (0 <= second && second < 60));

  final int? hour;
  final int? minute;
  final int? second;
  final TimePeriod? period;

  /// Applies this local time to a given [DateTime], which includes the day,
  /// month, year, and timezone.
  DateTime applyToDateTime(DateTime dateTime) {
    late final int militaryHour;
    if (period != null) {
      switch (period!) {
        case TimePeriod.am:
          // Note: It's possible that we've been given an hour value that's
          //       greater than the max value for a period time (12). We don't
          //       know what was intended by that. As a sane resolution, mod the
          //       value by the max period time.
          militaryHour = (hour ?? 0) % 12;
        case TimePeriod.pm:
          // Note: It's possible that we've been given an hour value that's
          //       greater than the max value for a period time (12). We don't
          //       know what was intended by that. As a sane resolution, mod the
          //       value by the max period time.
          militaryHour = ((hour ?? 0) % 12) + 12;
      }
    } else {
      militaryHour = hour ?? 0;
    }

    return dateTime.copyWith(
      hour: militaryHour,
      minute: minute ?? 0,
      second: second ?? 0,
    );
  }

  /// Returns a copy of this [LocalTime] with `null` values for any time
  /// component that exceeds the given [resolution].
  LocalTime enforceResolution(TimeResolution resolution) {
    switch (resolution) {
      case TimeResolution.hour:
        return LocalTime(hour, null, null, period);
      case TimeResolution.minute:
        return LocalTime(hour, minute, null, period);
      case TimeResolution.second:
        return this;
    }
  }

  LocalTime copyWith({
    int? hour,
    int? minute,
    int? second,
    TimePeriod? period,
  }) {
    return LocalTime(
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      period ?? this.period,
    );
  }
}

enum TimeResolution {
  hour,
  minute,
  second;

  operator >(TimeResolution other) {
    if (this == other) {
      return false;
    }

    switch (this) {
      case TimeResolution.hour:
        // Hours aren't higher resolution than anything.
        return false;
      case TimeResolution.minute:
        // Only hours are lower resolution than minutes.
        return other == TimeResolution.hour;
      case TimeResolution.second:
        // Seconds are higher resolution than everything.
        return true;
    }
  }

  operator >=(TimeResolution other) {
    return this == other || this > other;
  }

  operator <(TimeResolution other) {
    if (this == other) {
      return false;
    }

    switch (this) {
      case TimeResolution.hour:
        // Hours are lower resolution than everything.
        return true;
      case TimeResolution.minute:
        // Only seconds are higher resolution than minutes.
        return other == TimeResolution.second;
      case TimeResolution.second:
        // Seconds is higher resolution than everything.
        return false;
    }
  }

  operator <=(TimeResolution other) {
    return this == other || this < other;
  }
}

enum TimePeriod {
  am,
  pm;
}
