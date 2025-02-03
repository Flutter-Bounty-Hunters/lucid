import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:intl/intl.dart';
import 'package:lucid/lucid.dart';
import 'package:lucid/src/date_and_time/date/dates.dart';
import 'package:lucid/src/date_and_time/date/monthly_calendar.dart';

/// A widget for selecting a calendar date.
///
/// This widget displays a button. When the user clicks the button, a calendar
/// popover appears, which lets the user select a specific day.
///
/// The button displays the given [selectedDay], [hint] if no date is provided.
///
/// It's the app's job to change [selectedDay] when the user selects a day.
///
/// When the user selects a day, that day is reported to [onDaySelected].
class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    this.focusNode,
    this.selectedDay,
    this.hint,
    required this.onDaySelected,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null` to show a [hint].
  final DayOfYear? selectedDay;

  /// The text shown when [selectedDay] is `null`.
  final String? hint;

  /// Callback that's invoked when the user selects a different day.
  final void Function(DayOfYear?) onDaySelected;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final _buttonLeaderLink = LeaderLink();
  final _overlayController = OverlayPortalController();

  late FocusNode _focusNode;
  final _buttonFocusNode = FocusNode();
  final _calendarFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker");
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker");
    }
  }

  @override
  void dispose() {
    _calendarFocusNode.dispose();
    _buttonFocusNode.dispose();

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _toggleCalendar(ActivationActor actor) {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    } else {
      _overlayController.show();
    }
  }

  void _closeCalendar() {
    _overlayController.hide();
  }

  void _onDaySelected(DayOfYear day) {
    if (day == widget.selectedDay) {
      // The user selected the day that's already selected. De-select it.
      widget.onDaySelected(null);
      return;
    }

    widget.onDaySelected(day);
  }

  @override
  Widget build(BuildContext context) {
    // FIXME: We should be able to use a BuildInOrder here but the BuildInOrder
    //        is maxing out vertical space, similar to a column set to max. File
    //        an issue with repro steps in follow_the_leader.
    return FocusTraversalGroup(
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: false,
        debugLabel: "Date Picker",
        child: OverlayPortal(
          controller: _overlayController,
          overlayChildBuilder: (overlayContext) {
            return Follower.withAligner(
              link: _buttonLeaderLink,
              aligner: FunctionalAligner(
                delegate: (Rect globalLeaderRect, Size followerSize) {
                  if (globalLeaderRect.top > followerSize.height + 8) {
                    return FollowerAlignment(
                      leaderAnchor: Alignment.topCenter,
                      followerAnchor: Alignment.bottomCenter,
                      followerOffset: Offset(0, -8),
                    );
                  } else {
                    return FollowerAlignment(
                      leaderAnchor: Alignment.bottomCenter,
                      followerAnchor: Alignment.topCenter,
                      followerOffset: Offset(0, 8),
                    );
                  }
                },
              ),
              boundary: ScreenFollowerBoundary(
                screenSize: MediaQuery.sizeOf(context),
                devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
              ),
              child: KeyDismissable(
                dismiss: _closeCalendar,
                child: ListenableBuilder(
                    listenable: _buttonLeaderLink,
                    builder: (context, child) {
                      return SizedBox(
                        width: _buttonLeaderLink.leaderSize?.width.clamp(250, 600) ?? 300,
                        child: MonthlyCalendar(
                          focusNode: _calendarFocusNode,
                          selectedDay: widget.selectedDay,
                          autofocus: _focusNode.hasFocus,
                          // ^ Only autofocus a calendar day button if we're currently in
                          //   focus mode, and we have the focus.
                          onDaySelected: _onDaySelected,
                        ),
                      );
                    }),
              ),
            );
          },
          child: Leader(
            link: _buttonLeaderLink,
            child: DatePickerButton(
              focusNode: _buttonFocusNode,
              selectedDate: widget.selectedDay,
              hint: widget.hint,
              toggleCalendar: _toggleCalendar,
            ),
          ),
        ),
      ),
    );
  }
}

class DatePickerButton extends StatefulWidget {
  const DatePickerButton({
    super.key,
    this.focusNode,
    this.selectedDate,
    this.hint,
    required this.toggleCalendar,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null` to show a [hint].
  final DayOfYear? selectedDate;

  /// The text shown when [selectedDate] is `null`.
  final String? hint;

  /// Tells the client that this button wants to toggle the display of the
  /// month calendar popover.
  final void Function(ActivationActor) toggleCalendar;

  @override
  State<DatePickerButton> createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  static final _selectedDateFormat = DateFormat("MMMM d, yyyy");

  var _brightness = Brightness.light;

  late FocusNode _focusNode;
  var _isHovering = false;
  var _isPressed = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Button");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _brightness = LucidBrightness.of(context);
  }

  @override
  void didUpdateWidget(DatePickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Button");
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
    return KeyActivatable(
      activate: () => widget.toggleCalendar(ActivationActor.keyboard),
      child: Focus(
        focusNode: _focusNode,
        debugLabel: "Date Picker Button",
        child: MouseRegion(
          cursor: _isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() {
            _isHovering = true;
          }),
          onExit: (_) => setState(() {
            _isHovering = false;
          }),
          child: GestureDetector(
            onTapDown: (_) => setState(() {
              _isPressed = true;
            }),
            onTapUp: (_) => setState(() {
              _isPressed = false;
              widget.toggleCalendar(ActivationActor.tap);
            }),
            onTapCancel: () => setState(() {
              _isPressed = false;
            }),
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: sheetCornerRadius,
                    border: Border.all(color: _borderColor),
                    color: _backgroundColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: _iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedDateText,
                          style: TextStyle(
                            color: _labelColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color get _iconColor {
    return _brightness == Brightness.light //
        ? Colors.black
        : Colors.white;
  }

  Color get _labelColor {
    return _brightness == Brightness.light //
        ? Colors.black
        : Colors.white;
  }

  Color get _borderColor {
    if (_focusNode.hasFocus) {
      return Colors.lightBlue;
    }

    return _brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.10);
  }

  Color get _backgroundColor {
    if (_isPressed) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.10);
    }

    if (_isHovering) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.03);
    }

    return _brightness == Brightness.light //
        ? Colors.white
        : Colors.grey.shade900;
  }

  String get _selectedDateText => widget.selectedDate != null //
      ? _selectedDateFormat.format(widget.selectedDate!.toDateTime())
      : widget.hint ?? '';
}

enum ActivationActor {
  /// The user tapped to activate.
  tap,

  /// The user activated through a key press.
  keyboard;
}
