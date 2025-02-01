import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:intl/intl.dart';
import 'package:lucid/lucid.dart';

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
                        child: DatePickerCalendar(
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

class DatePickerCalendar extends StatefulWidget {
  const DatePickerCalendar({
    super.key,
    this.focusNode,
    this.selectedDay,
    this.autofocus = false,
    required this.onDaySelected,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null`.
  final DayOfYear? selectedDay;

  /// Whether to immediately give focus to a day button upon widget initialization.
  ///
  /// When `false`, no focus will be automatically given to anything in this calendar.
  final bool autofocus;

  /// Callback that's invoked when the user selects a different day.
  final void Function(DayOfYear) onDaySelected;

  @override
  State<DatePickerCalendar> createState() => _DatePickerCalendarState();
}

class _DatePickerCalendarState extends State<DatePickerCalendar> {
  var _brightness = Brightness.light;

  late FocusNode _focusNode;
  DayOfYear? _focusedDay;

  late DateTime _referenceDate;

  @override
  void initState() {
    super.initState();

    _referenceDate = widget.selectedDay != null //
        ? widget.selectedDay!.toDateTime()
        : DateTime.now();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Calendar");
    if (widget.autofocus) {
      // We were given a FocusNode and it's already focused. Ensure that
      // we begin with the selected day button focused.
      _focusedDay = DayOfYear.fromDateTime(_referenceDate);
    }
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
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Calendar");
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
    return FocusScope(
      child: FocusTraversalGroup(
        child: Focus(
          focusNode: _focusNode,
          debugLabel: "Date Picker Calendar",
          child: Container(
            decoration: BoxDecoration(
              borderRadius: _sheetCornerRadius,
              border: Border.all(color: _borderColor),
              color: _backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DatePickerMonthSelector(
                  label: DateFormat("MMMM yyyy").format(_referenceDate),
                  onPreviousPressed: _goToPreviousMonth,
                  isNextEnabled: _canGoToNextMonth,
                  onNextPressed: _goToNextMonth,
                ),
                const SizedBox(height: 8),
                DatePickerDayGrid(
                  month: _referenceDate,
                  selectedDay: widget.selectedDay,
                  autofocusDay: _focusedDay,
                  onDaySelected: widget.onDaySelected,
                ),
              ],
            ),
          ),
        ),
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

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Arrow");
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
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Arrow");
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
      activate: widget.isEnabled ? widget.onPressed : null,
      child: GestureDetector(
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
          child: Focus(
            focusNode: _focusNode,
            child: ListenableBuilder(
                listenable: _focusNode,
                builder: (context, child) {
                  return Container(
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
                  );
                }),
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
    if (_focusNode.hasPrimaryFocus) {
      return Colors.lightBlue;
    }

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
    this.selectedDay,
    this.autofocusDay,
    required this.onDaySelected,
  });

  final DateTime month;

  final DayOfYear? selectedDay;

  final DayOfYear? autofocusDay;

  final void Function(DayOfYear day) onDaySelected;

  @override
  State<DatePickerDayGrid> createState() => _DatePickerDayGridState();
}

class _DatePickerDayGridState extends State<DatePickerDayGrid> {
  @override
  Widget build(BuildContext context) {
    final referenceDate = widget.month;
    var monthStart = DateTime(referenceDate.year, referenceDate.month, 1, 12);
    // ^ Use the middle of the day to prevent any edge effects as we repeatedly
    //   add day after day.

    final rows = <List<Widget>>[];
    final daysBeforeMonthStart = monthStart.weekday % 7;
    final calendarRowCount = ((daysBeforeMonthStart + monthStart.daysInMonth) / 7).ceil();
    final dayCount = calendarRowCount * 7;

    final today = DayOfYear.today();
    var day = monthStart.subtract(Duration(days: monthStart.weekday % 7));
    for (int i = 0; i < dayCount; i += 1) {
      final row = i ~/ 7;
      if (row >= rows.length) {
        rows.add(<Widget>[]);
      }

      final buttonDate = day;
      final buttonDay = DayOfYear.fromDateTime(buttonDate);
      rows[row].add(
        DatePickerDayGridButton(
          date: "${buttonDate.day}",
          isEnabled: buttonDate.month == referenceDate.month,
          isSelected: buttonDay == widget.selectedDay,
          isToday: buttonDay == today,
          autofocus: buttonDay == widget.autofocusDay,
          onPressed: () {
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
    this.isSelected = false,
    this.isToday = false,
    this.autofocus = false,
    this.onPressed,
  });

  final FocusNode? focusNode;
  final String date;
  final bool isEnabled;
  final bool isSelected;
  final bool isToday;
  final bool autofocus;
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

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Day (${widget.date})");

    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
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
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Day");
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
      activate: widget.onPressed,
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
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.isEnabled,
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, child) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: _sheetCornerRadius,
                    border: Border.all(color: _borderColor),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color get _textColor {
    if (widget.isSelected) {
      return _brightness == Brightness.light //
          ? Colors.white
          : Colors.black;
    }

    return _brightness == Brightness.light //
        ? widget.isEnabled
            ? Colors.black
            : Colors.black.withValues(alpha: 0.2)
        : widget.isEnabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2);
  }

  Color get _borderColor {
    if (_focusNode.hasPrimaryFocus) {
      return Colors.lightBlue;
    }

    return Colors.transparent;
  }

  Color get _backgroundColor {
    if (widget.isSelected) {
      if (_isPressed) {
        return _brightness == Brightness.light //
            ? Colors.black.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.90);
      }

      if (_isHovering) {
        return _brightness == Brightness.light //
            ? Colors.black.withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.75);
      }

      return _brightness == Brightness.light //
          ? Colors.black
          : Colors.white;
    }

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

    if (widget.isToday) {
      return _brightness == Brightness.light //
          ? Colors.black.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.1);
    }

    return Colors.transparent;
  }
}

/// A day of a year, as specified by a [year], [month], and [day].
class DayOfYear {
  factory DayOfYear.fromDateTime(DateTime dateTime) {
    return DayOfYear.ymd(dateTime.year, dateTime.month, dateTime.day);
  }

  factory DayOfYear.today() {
    return DayOfYear.fromDateTime(DateTime.now());
  }

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

enum ActivationActor {
  /// The user tapped to activate.
  tap,

  /// The user activated through a key press.
  keyboard;
}

extension on DateTime {
  int get daysInMonth {
    var firstDayOfNextMonth = (month < 12) //
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);

    return firstDayOfNextMonth.subtract(Duration(days: 1)).day;
  }
}
