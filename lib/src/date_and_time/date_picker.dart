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

    _brightness = LucidBrightness.of(context);
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
    print("Building button with selected date: ${widget.selectedDate}");

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
              borderRadius: _sheetCornerRadius,
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

  var _referenceDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _brightness = LucidBrightness.of(context);
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

  void _goToPreviousMonth() {
    setState(() {
      _referenceDate = DateTime(_referenceDate.year, _referenceDate.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    if (!_canGoToNextMonth) {
      return;
    }

    setState(() {
      _referenceDate = DateTime(_referenceDate.year, _referenceDate.month + 1, 1);
    });
  }

  bool get _canGoToNextMonth {
    final now = DateTime.now();
    return !(_referenceDate.year >= now.year && _referenceDate.month >= now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: _sheetCornerRadius,
        border: Border.all(color: _borderColor),
        color: _backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          DatePickerMonthSelector(
            label: DateFormat("MMMM yyyy").format(_referenceDate),
            onPreviousPressed: _goToPreviousMonth,
            isNextEnabled: _canGoToNextMonth,
            onNextPressed: _goToNextMonth,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DatePickerDayGrid(
              month: _referenceDate,
              onDaySelected: widget.onDaySelected,
            ),
          ),
        ],
      ),
    );
  }

  Color get _borderColor {
    return _brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.10);
  }

  Color get _backgroundColor {
    return _brightness == Brightness.light //
        ? Colors.white
        : Colors.grey.shade900;
  }
}

class DatePickerMonthSelector extends StatelessWidget {
  const DatePickerMonthSelector({
    super.key,
    required this.label,
    required this.onPreviousPressed,
    this.isNextEnabled = true,
    required this.onNextPressed,
  });

  final String label;

  final VoidCallback onPreviousPressed;

  final bool isNextEnabled;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          DatePickerArrowButton.previous(
            onPressed: onPreviousPressed,
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: brightness == Brightness.light //
                      ? Colors.grey.shade900
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DatePickerArrowButton.next(
            isEnabled: isNextEnabled,
            onPressed: onNextPressed,
          ),
        ],
      ),
    );
  }
}

class DatePickerArrowButton extends StatefulWidget {
  const DatePickerArrowButton.previous({
    super.key,
    this.focusNode,
    this.isEnabled = true,
    required this.onPressed,
  }) : arrow = Icons.arrow_back_ios_new;

  const DatePickerArrowButton.next({
    super.key,
    this.focusNode,
    this.isEnabled = true,
    required this.onPressed,
  }) : arrow = Icons.arrow_forward_ios;

  final FocusNode? focusNode;
  final IconData arrow;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  State<DatePickerArrowButton> createState() => _DatePickerArrowButtonState();
}

class _DatePickerArrowButtonState extends State<DatePickerArrowButton> {
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

    _brightness = LucidBrightness.of(context);
  }

  @override
  void didUpdateWidget(DatePickerArrowButton oldWidget) {
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
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _isPressed = true;
      }),
      onTapUp: (_) => setState(() {
        _isPressed = false;

        if (widget.isEnabled) {
          widget.onPressed();
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
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: _sheetCornerRadius,
            border: Border.all(color: _borderColor),
            color: _backgroundColor,
          ),
          child: Center(
            child: Icon(
              widget.arrow,
              size: 16,
              color: _iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Color get _iconColor {
    return _brightness == Brightness.light //
        ? widget.isEnabled
            ? Colors.black
            : Colors.black.withValues(alpha: 0.10)
        : widget.isEnabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.10);
  }

  Color get _borderColor {
    return _brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.10);
  }

  Color get _backgroundColor {
    if (_isPressed && widget.isEnabled) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.10);
    }

    if (_isHovering && widget.isEnabled) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.03);
    }

    return Colors.transparent;
  }
}

class DatePickerDayGrid extends StatefulWidget {
  const DatePickerDayGrid({
    super.key,
    required this.month,
    required this.onDaySelected,
  });

  final DateTime month;

  final void Function(DayOfYear day) onDaySelected;

  @override
  State<DatePickerDayGrid> createState() => _DatePickerDayGridState();
}

class _DatePickerDayGridState extends State<DatePickerDayGrid> {
  @override
  Widget build(BuildContext context) {
    final referenceDate = widget.month;
    var monthStart = DateTime(referenceDate.year, referenceDate.month, 1);

    final rows = <List<Widget>>[];
    var day = monthStart.subtract(Duration(days: monthStart.weekday));
    for (int i = 0; i < 35; i += 1) {
      final row = i ~/ 7;
      if (row >= rows.length) {
        rows.add(<Widget>[]);
      }

      final buttonDay = day;
      rows[row].add(
        DatePickerDayGridButton(
          date: "${buttonDay.day}",
          isEnabled: buttonDay.month == referenceDate.month,
          onPressed: () {
            print("Day picker grid button pressed. Calling widget onDaySelected");
            widget.onDaySelected(
              DayOfYear.ymd(buttonDay.year, buttonDay.month, buttonDay.day),
            );
          },
        ),
      );

      day = day.add(const Duration(hours: 24));
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: DayAbbreviation.su()),
            Expanded(child: DayAbbreviation.mo()),
            Expanded(child: DayAbbreviation.tu()),
            Expanded(child: DayAbbreviation.we()),
            Expanded(child: DayAbbreviation.th()),
            Expanded(child: DayAbbreviation.fr()),
            Expanded(child: DayAbbreviation.sa()),
          ],
        ),
        for (final row in rows) //
          Row(
            children: [
              for (final day in row) //
                Expanded(child: day),
            ],
          ),
      ],
    );
  }
}

class DayAbbreviation extends StatelessWidget {
  const DayAbbreviation.su({
    super.key,
  }) : abbreviation = "Su";

  const DayAbbreviation.mo({
    super.key,
  }) : abbreviation = "Mo";

  const DayAbbreviation.tu({
    super.key,
  }) : abbreviation = "Tu";

  const DayAbbreviation.we({
    super.key,
  }) : abbreviation = "We";

  const DayAbbreviation.th({
    super.key,
  }) : abbreviation = "Th";

  const DayAbbreviation.fr({
    super.key,
  }) : abbreviation = "Fr";

  const DayAbbreviation.sa({
    super.key,
  }) : abbreviation = "Sa";

  const DayAbbreviation({
    super.key,
    required this.abbreviation,
  });

  final String abbreviation;

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return Text(
      abbreviation,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: brightness == Brightness.light //
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.5),
        fontSize: 14,
      ),
    );
  }
}

class DatePickerDayGridButton extends StatefulWidget {
  const DatePickerDayGridButton({
    super.key,
    this.focusNode,
    required this.date,
    this.isEnabled = true,
    this.onPressed,
  });

  final FocusNode? focusNode;
  final String date;
  final bool isEnabled;
  final VoidCallback? onPressed;

  @override
  State<DatePickerDayGridButton> createState() => _DatePickerDayGridButtonState();
}

class _DatePickerDayGridButtonState extends State<DatePickerDayGridButton> {
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

    _brightness = LucidBrightness.of(context);
  }

  @override
  void didUpdateWidget(DatePickerDayGridButton oldWidget) {
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
    return GestureDetector(
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
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: _sheetCornerRadius,
            color: _backgroundColor,
          ),
          child: Center(
            child: Text(
              widget.date,
              style: TextStyle(
                color: _textColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _textColor {
    return _brightness == Brightness.light //
        ? widget.isEnabled
            ? Colors.black
            : Colors.black.withValues(alpha: 0.2)
        : widget.isEnabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2);
  }

  Color get _backgroundColor {
    if (_isPressed && widget.isEnabled) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.10);
    }

    if (_isHovering && widget.isEnabled) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.03);
    }

    return Colors.transparent;
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

final _sheetCornerRadius = BorderRadius.circular(4);
