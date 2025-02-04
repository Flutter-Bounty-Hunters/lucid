import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucid/src/date_and_time/date/dates.dart';
import 'package:lucid/src/infrastructure/logging.dart';
import 'package:lucid/src/infrastructure/sheets.dart';
import 'package:lucid/src/theme.dart';

/// A calendar for a single month, which displays the name and year of the month,
/// shows a grid of buttons for each day in the month, and provides "previous" and
/// "next" buttons to change the month.
class MonthlyCalendar extends StatefulWidget {
  const MonthlyCalendar({
    super.key,
    this.focusNode,
    this.selectedDay,
    this.autofocus = false,
    required this.onDaySelected,
  });

  final FocusNode? focusNode;

  /// The day of the year that's currently selected, or `null`.
  final DayOfYear? selectedDay;

  // TODO: monthRange

  /// Whether to immediately give focus to a day button upon widget initialization.
  ///
  /// When `false`, no focus will be automatically given to anything in this calendar.
  final bool autofocus;

  // TODO: onMonthChanged

  /// Callback that's invoked when the user selects a different day.
  final void Function(DayOfYear) onDaySelected;

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late FocusNode _focusNode;
  DayOfYear? _focusedDay;

  late DateTime _referenceDate;

  final _previousMonthButtonFocusNode = FocusNode();
  final _nextMonthButtonFocusNode = FocusNode();

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
  void didUpdateWidget(MonthlyCalendar oldWidget) {
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
      _updateFocusOnMonthChange();
    });
  }

  void _goToNextMonth() {
    if (!_canGoToNextMonth) {
      return;
    }

    setState(() {
      _referenceDate = DateTime(_referenceDate.year, _referenceDate.month + 1, 1);
      _updateFocusOnMonthChange();
    });
  }

  bool get _canGoToNextMonth {
    final now = DateTime.now();
    return !(_referenceDate.year >= now.year && _referenceDate.month >= now.month);
  }

  void _updateFocusOnMonthChange() {
    if (_focusNode.hasFocus) {
      final primaryFocus = FocusManager.instance.primaryFocus!;
      if (primaryFocus != _previousMonthButtonFocusNode && primaryFocus != _nextMonthButtonFocusNode) {
        // We're changing months and one of our day buttons has focus. This can
        // cause problems when a given day in the grid goes from focusable in one
        // month to non-focusable in the next month. To avoid surprising focus changes,
        // give up focus entirely.
        primaryFocus.unfocus(disposition: UnfocusDisposition.scope);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MonthlyCalendarFocusModelProvider(
      child: FocusScope(
        child: FocusTraversalGroup(
          policy: const MonthlyCalendarFocusTraversalPolicy(),
          child: Focus(
            focusNode: _focusNode,
            debugLabel: "Date Picker Calendar",
            child: Sheet(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MonthlyCalendarHeader(
                    label: DateFormat("MMMM yyyy").format(_referenceDate),
                    previousFocusNode: _previousMonthButtonFocusNode,
                    onPreviousPressed: _goToPreviousMonth,
                    nextFocusNode: _nextMonthButtonFocusNode,
                    isNextEnabled: _canGoToNextMonth,
                    onNextPressed: _goToNextMonth,
                  ),
                  const SizedBox(height: 8),
                  MonthlyCalendarDayGrid(
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
      ),
    );
  }
}

class MonthlyCalendarFocusModelProvider extends StatefulWidget {
  static MonthlyCalendarFocusModel of(BuildContext context) =>
      context.findAncestorStateOfType<_MonthlyCalendarFocusModelProviderState>()!._focusModel;

  const MonthlyCalendarFocusModelProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MonthlyCalendarFocusModelProvider> createState() => _MonthlyCalendarFocusModelProviderState();
}

class _MonthlyCalendarFocusModelProviderState extends State<MonthlyCalendarFocusModelProvider> {
  final _focusModel = MonthlyCalendarFocusModel();

  @override
  void dispose() {
    _focusModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MonthlyCalendarFocusModel {
  MonthlyCalendarFocusModel();

  void dispose() {
    _dayGrid.clear();
    _focusNodeIndex.clear();
  }

  FocusNode? previousButton;
  FocusNode? nextButton;

  late final List<List<FocusNode?>> _dayGrid = [];
  final _focusNodeIndex = <FocusNode, (int row, int col)>{};

  /// Returns the `FocusNode` that belongs to the first day of the month in
  /// the grid.
  ///
  /// This day may not be (and probably isn't) the first day in the grid. The
  /// grid begins on Sunday. The first day of most months isn't a Sunday.
  FocusNode? get firstDay {
    for (int row = 0; row < _dayGrid.length; row += 1) {
      for (int column = 0; column < _dayGrid[row].length; column += 1) {
        final day = _dayGrid[row][column];
        if (day != null) {
          return day;
        }
      }
    }

    return null;
  }

  int get lastRow => _dayGrid.length - 1;

  bool isDayFocusNode(FocusNode focusNode) => _focusNodeIndex.containsKey(focusNode);

  (int row, int column)? gridLocationForDay(FocusNode focusNode) => _focusNodeIndex[focusNode];

  /// Returns the `FocusNode` for the day at [row] and [column], or the nearest
  /// day within the same [row].
  FocusNode? getDayAtOrNearestInRow({
    required int row,
    required int column,
  }) {
    var day = dayFocusNodeAt(row: row, column: column);
    if (day != null) {
      return day;
    }

    var left = column - 1;
    var right = column + 1;
    while (left >= 0 || right <= 6) {
      if (left >= 0) {
        day = dayFocusNodeAt(row: row, column: left);
        if (day != null) {
          return day;
        }
      }
      if (right <= 6) {
        day = dayFocusNodeAt(row: row, column: right);
        if (day != null) {
          return day;
        }
      }

      left -= 1;
      right += 1;
    }

    return null;
  }

  FocusNode? dayFocusNodeAt({
    required int row,
    required int column,
  }) {
    if (row >= _dayGrid.length) {
      return null;
    }
    if (column >= _dayGrid[row].length) {
      return null;
    }

    return _dayGrid[row][column];
  }

  void putDayFocusNodeAt(
    FocusNode focusNode, {
    required int row,
    required int column,
  }) {
    // Expand the size of our grid to make sure we have a place to
    // put the focus node.
    while (row >= _dayGrid.length) {
      _dayGrid.add(<FocusNode?>[]);
    }
    while (column >= _dayGrid[row].length) {
      _dayGrid[row].add(null);
    }

    // Place the focus node in the grid, and create an index to that position.
    _dayGrid[row][column] = focusNode;
    _focusNodeIndex[focusNode] = (row, column);
  }

  void removeDayFocusNode(FocusNode focusNode) {
    if (!_focusNodeIndex.containsKey(focusNode)) {
      return;
    }

    final (row, col) = _focusNodeIndex[focusNode]!;
    _dayGrid[row][col] = null;
    _focusNodeIndex.remove(focusNode);
  }
}

class MonthlyCalendarFocusTraversalPolicy extends FocusTraversalPolicy {
  const MonthlyCalendarFocusTraversalPolicy({
    super.requestFocusCallback,
  });

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    if (currentNode.context == null) {
      LucidLogs.monthlyCalendar.warning(
        "WARNING: Tried to find first focus node in direction ($direction) but the currentNode has no BuildContext - $currentNode",
      );
      return null;
    }
    final model = MonthlyCalendarFocusModelProvider.of(currentNode.context!);

    // TODO: implement findFirstFocusInDirection
    return model.firstDay;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (currentNode.context == null) {
      LucidLogs.monthlyCalendar.warning(
        "WARNING: Tried to find next focus node in direction ($direction), but the currentNode has no BuildContext - $currentNode",
      );
      return false;
    }
    final model = MonthlyCalendarFocusModelProvider.of(currentNode.context!);

    if (currentNode == model.previousButton) {
      switch (direction) {
        case TraversalDirection.up:
        case TraversalDirection.left:
          return false;
        case TraversalDirection.right:
          final nextButton = model.nextButton;
          if (nextButton == null) {
            return false;
          }

          nextButton.requestFocus();
          return true;
        case TraversalDirection.down:
          // TODO: Restore the previously selected day button

          // Try to find a button in the first row on the left half of the calendar
          // display.
          var dayBelow = model.getDayAtOrNearestInRow(row: 0, column: 0);
          if (dayBelow != null) {
            final (_, column) = model.gridLocationForDay(dayBelow)!;
            if (column <= 3) {
              // We found a day in the first row on the left half of the calendar.
              // Move focus there.
              dayBelow.requestFocus();
              return true;
            }
          }

          // None of the 1st row buttons were on the left half. Find one in the
          // 2nd row.
          dayBelow = model.getDayAtOrNearestInRow(row: 1, column: 0);
          if (dayBelow != null) {
            final (_, column) = model.gridLocationForDay(dayBelow)!;
            if (column <= 3) {
              // We found a day in the 2nd row on the left half of the calendar.
              // Move focus there.
              dayBelow.requestFocus();
              return true;
            }
          }

          // We couldn't find a left-half day in the 1st or 2nd rows. Not sure what's
          // going on here. As a fallback, move to the first day of the month.
          final firstDay = model.firstDay;
          if (firstDay != null) {
            firstDay.requestFocus();
            return true;
          }

          return false;
      }
    }

    if (currentNode == model.nextButton) {
      switch (direction) {
        case TraversalDirection.up:
        case TraversalDirection.right:
          return false;
        case TraversalDirection.left:
          final previousButton = model.previousButton;
          if (previousButton == null) {
            return false;
          }

          previousButton.requestFocus();
          return true;
        case TraversalDirection.down:
          // TODO: Restore the previously selected day button

          // Try to find a button in the first row on the right half of the calendar
          // display.
          var dayBelow = model.getDayAtOrNearestInRow(row: 0, column: 6);
          if (dayBelow != null) {
            final (_, column) = model.gridLocationForDay(dayBelow)!;
            if (column >= 3) {
              // We found a day in the first row on the right half of the calendar.
              // Move focus there.
              dayBelow.requestFocus();
              return true;
            }
          }

          // None of the 1st row buttons were on the right half. Find one in the
          // 2nd row.
          dayBelow = model.getDayAtOrNearestInRow(row: 1, column: 6);
          if (dayBelow != null) {
            final (_, column) = model.gridLocationForDay(dayBelow)!;
            if (column >= 3) {
              // We found a day in the 2nd row on the right half of the calendar.
              // Move focus there.
              dayBelow.requestFocus();
              return true;
            }
          }

          // We couldn't find a right-half day in the 1st or 2nd rows. Not sure what's
          // going on here. As a fallback, move to the first day of the month.
          final firstDay = model.firstDay;
          if (firstDay != null) {
            firstDay.requestFocus();
            return true;
          }

          return false;
      }
    }

    final isDay = model.isDayFocusNode(currentNode);
    if (!isDay) {
      // This FocusNode doesn't belong to the calendar's nav buttons or
      // its days. We don't know what this is.
      return false;
    }

    final gridLocation = model.gridLocationForDay(currentNode);
    if (gridLocation == null) {
      // This FocusNode doesn't belong to the calendar's nav buttons or
      // its days. We don't know what this is.
      return false;
    }

    final (row, column) = gridLocation;
    switch (direction) {
      case TraversalDirection.up:
        final previousButton = model.previousButton;
        final nextButton = model.nextButton;

        if (row == 0) {
          if (column <= 3) {
            // The current day selection is on the left half of the row. Try
            // to give focus to the previous button. If we can't, then give it
            // to the next button.
            if (previousButton != null) {
              previousButton.requestFocus();
              return true;
            }
            if (nextButton != null) {
              nextButton.requestFocus();
              return true;
            }
          } else {
            // The current day selection is on the right half of the row. Try
            // to give focus to the next button. If we can't, then give it
            // to the previous button.
            if (nextButton != null) {
              nextButton.requestFocus();
              return true;
            }
            if (previousButton != null) {
              previousButton.requestFocus();
              return true;
            }
          }

          // No nav buttons are available. Don't go anywhere.
          return false;
        }

        // Try to find a day directly above us.
        var dayAbove = model.dayFocusNodeAt(row: row - 1, column: column);
        if (dayAbove != null) {
          dayAbove.requestFocus();
          return true;
        }

        // There wasn't a day directly above us. This can happen if we're in the 2nd
        // row and the day above us belongs to the previous month. If that's the case,
        // hop the row and go up to the navigation buttons.
        if (row == 1) {
          if (column <= 3) {
            // The current day selection is on the left half of the row. Try
            // to give focus to the previous button. If we can't, then give it
            // to the next button.
            if (previousButton != null) {
              previousButton.requestFocus();
              return true;
            }
            if (nextButton != null) {
              nextButton.requestFocus();
              return true;
            }

            // Nav buttons don't exist. Do nothing.
            return false;
          } else {
            // The current day selection is on the right half of the row. Try
            // to give focus to the next button. If we can't, then give it
            // to the previous button.
            if (nextButton != null) {
              nextButton.requestFocus();
              return true;
            }
            if (previousButton != null) {
              previousButton.requestFocus();
              return true;
            }

            // Nav buttons don't exist. Do nothing.
            return false;
          }
        }

        // We couldn't find a day directly above us, and we're not in the 2nd row. It's
        // not clear why this happened, but see if we can find any day in the row above us
        // and move there.
        dayAbove = model.getDayAtOrNearestInRow(row: row - 1, column: column);
        if (dayAbove != null) {
          dayAbove.requestFocus();
          return true;
        }

        // Couldn't find a day in the row above us.
        return false;
      case TraversalDirection.down:
        if (row == model.lastRow) {
          var dayAtTop = model.dayFocusNodeAt(row: 0, column: column);
          if (dayAtTop != null) {
            // We found a day in the top row directly above the current selection.
            // Move focus there.
            dayAtTop.requestFocus();
            return true;
          }

          // We couldn't find a day in the first row directly above us. One reason
          // this can happen is if the month doesn't start on the first day of the
          // week. In that case, find the same column in the 2nd row.
          dayAtTop = model.dayFocusNodeAt(row: 1, column: column);
          if (dayAtTop != null) {
            // We found a day in the second row directly above the current selection.
            // Move focus there.
            dayAtTop.requestFocus();
            return true;
          }

          // We couldn't find a selectable day directly above us in the first or second
          // row. We don't know why this happened, but play it safe by selecting the first
          // day of the month.
          dayAtTop = model.firstDay;
          if (dayAtTop != null) {
            dayAtTop.requestFocus();
            return true;
          }

          // We couldn't find the first day of the month. Something is very wrong. Do nothing.
          return false;
        }

        // Current selection is above the bottom row. Move one row down.
        final dayBelow = model.dayFocusNodeAt(row: row + 1, column: column);
        if (dayBelow != null) {
          dayBelow.requestFocus();
          return true;
        }

        // We're not in the last row, but we couldn't find a day below us. This can
        // happen when the last day of the month doesn't fall on the last day of the
        // week, which results in some number of non-selectable days in the bottom
        // row. In this case, flip back up to the top.
        var dayAtTop = model.dayFocusNodeAt(row: 0, column: column);
        if (dayAtTop != null) {
          // We found a day in the top row directly above the current selection.
          // Move focus there.
          dayAtTop.requestFocus();
          return true;
        }

        // We couldn't find a day in the first row directly above us. One reason
        // this can happen is if the month doesn't start on the first day of the
        // week. In that case, find the same column in the 2nd row.
        dayAtTop = model.dayFocusNodeAt(row: 1, column: column);
        if (dayAtTop != null) {
          // We found a day in the second row directly above the current selection.
          // Move focus there.
          dayAtTop.requestFocus();
          return true;
        }

        // Couldn't find a day in the row below us, or a day directly above us in the
        // first or second row.
        return false;
      case TraversalDirection.left:
        if (column <= 0) {
          final dayOnRightSide = model.getDayAtOrNearestInRow(row: row, column: 6);
          if (dayOnRightSide != null && dayOnRightSide != currentNode) {
            dayOnRightSide.requestFocus();
            return true;
          }

          // Couldn't find a day to the right.
          return false;
        }

        final dayOnLeft = model.dayFocusNodeAt(row: row, column: column - 1);
        if (dayOnLeft != null) {
          dayOnLeft.requestFocus();
          return true;
        }

        // Couldn't find the day to the left.
        return false;
      case TraversalDirection.right:
        if (column >= 6) {
          final dayOnLeftSide = model.getDayAtOrNearestInRow(row: row, column: 0);
          if (dayOnLeftSide != null && dayOnLeftSide != currentNode) {
            dayOnLeftSide.requestFocus();
            return true;
          }

          // Couldn't find a day to the left.
          return false;
        }

        final dayOnRight = model.dayFocusNodeAt(row: row, column: column + 1);
        if (dayOnRight != null) {
          dayOnRight.requestFocus();
          return true;
        }

        // Couldn't find the day to the right.
        return false;
    }
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    if (currentNode.context == null) {
      // We can't access our traversal model. We don't know what to do.
      LucidLogs.monthlyCalendar.warning(
        "ERROR: Tried to sortDescendants for traversal but the currentNode has no BuildContext: $currentNode",
      );
      return descendants;
    }

    final model = MonthlyCalendarFocusModelProvider.of(currentNode.context!);
    return descendants.toList()
      ..sort((a, b) {
        if (a == model.previousButton) {
          // The previous button is always stop 1.
          return -1;
        }

        if (b == model.previousButton) {
          // The previous button is always stop 1.
          return 1;
        }

        if (a == model.nextButton) {
          // The next button is always stop 2.
          return -1;
        }

        if (b == model.nextButton) {
          // The next button is always stop 2.
          return 1;
        }

        // `a` and `b` are both day buttons (or something else).
        final positionA = model.gridLocationForDay(a);
        final positionB = model.gridLocationForDay(b);
        if (positionA == null && positionB == null) {
          // Neither of this are day buttons. They're equal.
          return 0;
        }
        if (positionB == null) {
          // `a` is a day button and `b` isn't. `a` comes first.
          return -1;
        }
        if (positionA == null) {
          // `b` if a day button and `a` isn't. `b` comes first.
          return 1;
        }

        // Both `a` and `b` are definitely day buttons. Order by
        // day in month.
        final (rowA, columnA) = positionA;
        final (rowB, columnB) = positionB;
        if (rowA == rowB) {
          // Lesser column index comes first.
          return columnA - columnB;
        }

        // Lesser row index comes first.
        return rowA - rowB;
      });
  }
}

/// The header within a monthly calendar, which displays the current month and
/// year, along with back and forward buttons to change the month.
class MonthlyCalendarHeader extends StatefulWidget {
  const MonthlyCalendarHeader({
    super.key,
    required this.label,
    this.previousFocusNode,
    required this.onPreviousPressed,
    this.nextFocusNode,
    this.isNextEnabled = true,
    required this.onNextPressed,
  });

  final String label;

  final FocusNode? previousFocusNode;
  final VoidCallback onPreviousPressed;

  final FocusNode? nextFocusNode;
  final bool isNextEnabled;
  final VoidCallback onNextPressed;

  @override
  State<MonthlyCalendarHeader> createState() => _MonthlyCalendarHeaderState();
}

class _MonthlyCalendarHeaderState extends State<MonthlyCalendarHeader> {
  late FocusNode _previousFocusNode;
  late FocusNode _nextFocusNode;

  @override
  void initState() {
    super.initState();

    _previousFocusNode = widget.previousFocusNode ?? FocusNode();
    _nextFocusNode = widget.nextFocusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _registerFocusNodesWithTraversalModel();
  }

  @override
  void didUpdateWidget(MonthlyCalendarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.previousFocusNode != oldWidget.previousFocusNode) {
      if (oldWidget.previousFocusNode == null) {
        _previousFocusNode.dispose();
      }
      _previousFocusNode = widget.previousFocusNode ?? FocusNode();
    }
    if (widget.nextFocusNode != oldWidget.nextFocusNode) {
      if (oldWidget.nextFocusNode == null) {
        _nextFocusNode.dispose();
      }
      _nextFocusNode = widget.nextFocusNode ?? FocusNode();
    }
    _registerFocusNodesWithTraversalModel();
  }

  @override
  void dispose() {
    if (widget.previousFocusNode == null) {
      _previousFocusNode.dispose();
    }
    if (widget.nextFocusNode == null) {
      _nextFocusNode.dispose();
    }

    super.dispose();
  }

  void _registerFocusNodesWithTraversalModel() {
    final model = MonthlyCalendarFocusModelProvider.of(context);

    model.previousButton = _previousFocusNode;

    model.nextButton = widget.isNextEnabled ? _nextFocusNode : null;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          MonthlyCalendarArrowButton.previous(
            focusNode: _previousFocusNode,
            onPressed: widget.onPreviousPressed,
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: brightness == Brightness.light //
                      ? Colors.grey.shade900
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          MonthlyCalendarArrowButton.next(
            focusNode: _nextFocusNode,
            isEnabled: widget.isNextEnabled,
            onPressed: widget.onNextPressed,
          ),
        ],
      ),
    );
  }
}

/// A button that displays an arrow pointing backward or forward, which is intended
/// to be displayed in a monthly calendar to change the month.
class MonthlyCalendarArrowButton extends StatefulWidget {
  const MonthlyCalendarArrowButton.previous({
    super.key,
    this.focusNode,
    this.isEnabled = true,
    required this.onPressed,
  }) : arrow = Icons.arrow_back_ios_new;

  const MonthlyCalendarArrowButton.next({
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
  State<MonthlyCalendarArrowButton> createState() => _MonthlyCalendarArrowButtonState();
}

class _MonthlyCalendarArrowButtonState extends State<MonthlyCalendarArrowButton> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Arrow");
  }

  @override
  void didUpdateWidget(MonthlyCalendarArrowButton oldWidget) {
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
    final brightness = LucidBrightness.of(context);

    return ButtonSheet(
      focusNode: _focusNode,
      focusNodeDebugLabel: "Date Picker Arrow",
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      isEnabled: widget.isEnabled,
      onActivated: widget.onPressed,
      child: Center(
        child: Icon(
          widget.arrow,
          size: 16,
          color: _iconColor(brightness),
        ),
      ),
    );
  }

  Color _iconColor(Brightness brightness) {
    return brightness == Brightness.light //
        ? widget.isEnabled
            ? Colors.black
            : Colors.black.withValues(alpha: 0.10)
        : widget.isEnabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.10);
  }
}

/// A grid of days within a given month.
///
/// This grid also displays some days from the previous month and the next month
/// to ensure the grid is completely filled.
class MonthlyCalendarDayGrid extends StatefulWidget {
  const MonthlyCalendarDayGrid({
    super.key,
    required this.month,
    this.selectedDay,
    this.autofocusDay,
    required this.onDaySelected,
  });

  /// The month whose days are shown in this grid.
  final DateTime month;

  /// The currently selected day, which is displayed with a different decoration
  /// than other days.
  final DayOfYear? selectedDay;

  /// Whether to focus a day button upon widget initialization, which then allows
  /// keyboard traversal to other days in the grid.
  final DayOfYear? autofocusDay;

  /// Callback invoked when the user taps or activates a day button.
  final void Function(DayOfYear day) onDaySelected;

  @override
  State<MonthlyCalendarDayGrid> createState() => _MonthlyCalendarDayGridState();
}

class _MonthlyCalendarDayGridState extends State<MonthlyCalendarDayGrid> {
  @override
  Widget build(BuildContext context) {
    final focusTraversalModel = MonthlyCalendarFocusModelProvider.of(context);

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
      final column = i % 7;
      if (row >= rows.length) {
        rows.add(<Widget>[]);
      }

      final buttonDate = day;
      final buttonDay = DayOfYear.fromDateTime(buttonDate);

      // Add/remove the day's FocusNode to/from the traversal model, depending on
      // whether this day is enabled or disabled.
      final isEnabled = buttonDate.month == referenceDate.month;
      final dayFocusNode = focusTraversalModel.dayFocusNodeAt(row: row, column: column) ?? FocusNode();
      if (isEnabled) {
        focusTraversalModel.putDayFocusNodeAt(
          dayFocusNode,
          row: row,
          column: column,
        );
      } else {
        focusTraversalModel.removeDayFocusNode(dayFocusNode);
      }

      // Create and add the day button's widget to our child widget grid.
      rows[row].add(
        MonthlyCalendarDayGridButton(
          focusNode: dayFocusNode,
          date: "${buttonDate.day}",
          isEnabled: isEnabled,
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

/// Widget that displays the abbreviation for a given day of the week.
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

class MonthlyCalendarDayGridButton extends StatefulWidget {
  const MonthlyCalendarDayGridButton({
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

  /// The date number of this day within the month, e.g., "15" for the 15th
  /// day of the month.
  final String date;

  /// Whether this day button is allowed to be selected by the user.
  final bool isEnabled;

  /// Whether this day button is currently selected by the user.
  final bool isSelected;

  /// Whether this day button represents today.
  final bool isToday;

  /// Whether this button should immediately be given focus upon initialization.
  final bool autofocus;

  /// Callback that's invoked when the user presses on this button, if `isEnabled`
  /// is `true`.
  ///
  /// If `isEnabled` is false, this callback is never invoked.
  ///
  /// This callback is nullable for buttons that might be permanently disabled,
  /// for which there's no reasonable pressed action.
  final VoidCallback? onPressed;

  @override
  State<MonthlyCalendarDayGridButton> createState() => _MonthlyCalendarDayGridButtonState();
}

class _MonthlyCalendarDayGridButtonState extends State<MonthlyCalendarDayGridButton> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode(debugLabel: "Date Picker Day (${widget.date})");

    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(MonthlyCalendarDayGridButton oldWidget) {
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
    final brightness = LucidBrightness.of(context);

    return SizedBox.square(
      dimension: 32,
      child: InvisibleSelectableButtonSheet(
        focusNode: _focusNode,
        padding: EdgeInsets.zero,
        isEnabled: widget.isEnabled,
        isSelected: widget.isSelected,
        backgroundColorOverride: widget.isToday //
            ? _todayBackground(brightness)
            : null,
        onActivated: widget.onPressed,
        child: Center(
          child: Text(
            widget.date,
            style: TextStyle(
              color: _textColor(brightness),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Color _textColor(Brightness brightness) {
    if (widget.isSelected) {
      return brightness == Brightness.light //
          ? Colors.white
          : Colors.black;
    }

    return brightness == Brightness.light //
        ? widget.isEnabled
            ? Colors.black
            : Colors.black.withValues(alpha: 0.2)
        : widget.isEnabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2);
  }

  Color _todayBackground(Brightness brightness) {
    return brightness == Brightness.light //
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.1);
  }
}
