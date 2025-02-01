import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:intl/intl.dart';
import 'package:lucid/lucid.dart';

/// A widget for selecting a calendar date.
///
/// This widget displays a button. When the user clicks the button, a calendar
/// popover appears, which lets the user select a specific day.
///
/// The button displays the given [selectedDate], [hint] if no date is provided.
///
/// It's the app's job to change [selectedDate] when the user selects a day.
///
/// When the user selects a day, that day is reported to [onDaySelected].
class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    this.selectedDate,
    this.hint,
    required this.onDaySelected,
  });

  /// The day of the year that's currently selected, or `null` to show a [hint].
  final DayOfYear? selectedDate;

  /// The text shown when [selectedDate] is `null`.
  final String? hint;

  /// Callback that's invoked when the user selects a different day.
  final void Function(DayOfYear) onDaySelected;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final _buttonLeaderLink = LeaderLink();
  final _overlayController = OverlayPortalController();

  void _toggleCalendar() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    } else {
      _overlayController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXME: We should be able to use a BuildInOrder here but the BuildInOrder
    //        is maxing out vertical space, similar to a column set to max. File
    //        an issue with repro steps in follow_the_leader.
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (overlayContext) {
        return Follower.withOffset(
          link: _buttonLeaderLink,
          offset: Offset(0, -8),
          leaderAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          child: DatePickerCalendar(
            selectedDate: widget.selectedDate,
            onDaySelected: widget.onDaySelected,
          ),
        );
      },
      child: Leader(
        link: _buttonLeaderLink,
        child: DatePickerButton(
          selectedDate: widget.selectedDate,
          hint: widget.hint,
          onPressed: _toggleCalendar,
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
    required this.onPressed,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null` to show a [hint].
  final DayOfYear? selectedDate;

  /// The text shown when [selectedDate] is `null`.
  final String? hint;

  final VoidCallback onPressed;

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

    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _brightness = LucidBrightness.maybeOf(context) ?? Brightness.light;
  }

  @override
  void didUpdateWidget(DatePickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
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
    return Focus(
      focusNode: _focusNode,
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
            widget.onPressed();
          }),
          onTapCancel: () => setState(() {
            _isPressed = false;
          }),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
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
                  ),
                ),
              ],
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
    if (_focusNode.hasPrimaryFocus) {
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

    return Colors.transparent;
  }

  String get _selectedDateText => widget.selectedDate != null //
      ? _selectedDateFormat.format(widget.selectedDate!.toDateTime())
      : widget.hint ?? '';
}

class DatePickerCalendar extends StatefulWidget {
  const DatePickerCalendar({
    super.key,
    this.focusNode,
    this.selectedDate,
    required this.onDaySelected,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null`.
  final DayOfYear? selectedDate;

  /// Callback that's invoked when the user selects a different day.
  final void Function(DayOfYear) onDaySelected;

  @override
  State<DatePickerCalendar> createState() => _DatePickerCalendarState();
}

class _DatePickerCalendarState extends State<DatePickerCalendar> {
  var _brightness = Brightness.light;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _brightness = LucidBrightness.maybeOf(context) ?? Brightness.light;
  }

  @override
  void didUpdateWidget(DatePickerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
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
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _borderColor),
        color: Colors.grey.shade900,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Color get _borderColor {
    return _brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.10);
  }
}

/// A day of a year, as specified by a [year], [month], and [day].
class DayOfYear {
  const DayOfYear.ymd(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Returns `true` if the given combination of year, month, and day represents
  /// a date that exists.
  ///
  /// For example, February 30 is NOT valid because February doesn't have 30 days.
  bool get isValid {
    final dateTime = DateTime(year, month, day);
    return year == dateTime.year && month == dateTime.month && day == dateTime.day;
  }

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayOfYear &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
