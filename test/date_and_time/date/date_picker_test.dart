import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:lucid/lucid.dart';

import '../../matchers.dart';

void main() {
  group("Date Picker >", () {
    group("calendar position and size >", () {
      testWidgetsOnArbitraryDesktop("calendar displays above by default", (tester) async {
        // Display the date picker button at the center of the screen, giving
        // it plenty of space above and below.
        await _pumpWithButtonAtCenter(
          tester,
          datePicker: DatePicker(
            onDaySelected: (_) {},
          ),
        );

        // Open the calendar popover.
        await tester.tap(find.byType(DatePickerButton));
        await tester.pump();

        // Ensure the calendar popover is above the button.
        expect(find.byType(MonthlyCalendar), findsOne);
        expect(find.byType(MonthlyCalendar), isAbove(find.byType(DatePickerButton), byAmount(8)));
      });

      testWidgetsOnArbitraryDesktop("calendar displays below when requested", (tester) async {
        // Display the date picker button at the center of the screen, giving
        // it plenty of space above and below.
        await _pumpWithButtonAtCenter(
          tester,
          datePicker: DatePicker(
            calendarPreferredSide: DatePickerCalendarSide.below,
            onDaySelected: (_) {},
          ),
        );

        // Open the calendar popover.
        await tester.tap(find.byType(DatePickerButton));
        await tester.pump();

        // Ensure the calendar popover is below the button.
        expect(find.byType(MonthlyCalendar), findsOne);
        expect(find.byType(MonthlyCalendar), isBelow(find.byType(DatePickerButton), byAmount(8)));
      });

      testWidgetsOnArbitraryDesktop("calendar displays below when not enough space", (tester) async {
        // Display the date picker button at the top of the screen, forcing
        // the calendar below it.
        await _pumpWithButtonNearTop(
          tester,
          datePicker: DatePicker(
            onDaySelected: (_) {},
          ),
        );

        // Open the calendar popover.
        await tester.tap(find.byType(DatePickerButton));
        await tester.pump();

        // Ensure the calendar popover is below the button.
        expect(find.byType(MonthlyCalendar), findsOne);
        expect(find.byType(MonthlyCalendar), isBelow(find.byType(DatePickerButton), byAmount(8)));
      });

      testWidgetsOnArbitraryDesktop("calendar displays above when not enough space", (tester) async {
        // Display the date picker button at the bottom of the screen, forcing
        // the calendar above it.
        await _pumpWithButtonNearBottom(
          tester,
          datePicker: DatePicker(
            calendarPreferredSide: DatePickerCalendarSide.below,
            onDaySelected: (_) {},
          ),
        );

        // Open the calendar popover.
        await tester.tap(find.byType(DatePickerButton));
        await tester.pump();

        // Ensure the calendar popover is above the button.
        expect(find.byType(MonthlyCalendar), findsOne);
        expect(find.byType(MonthlyCalendar), isAbove(find.byType(DatePickerButton), byAmount(8)));
      });

      group("calendar width >", () {
        testWidgetsOnArbitraryDesktop("matches button width in typical case", (tester) async {
          await _pumpWithButtonAtCenter(
            tester,
            datePicker: DatePicker(
              onDaySelected: (_) {},
            ),
          );

          // Open the calendar popover.
          await tester.tap(find.byType(DatePickerButton));
          await tester.pump();

          // Ensure the calendar has the same width as the button.
          expect(find.byType(MonthlyCalendar), findsOne);
          expect(find.byType(MonthlyCalendar), isSameWidthAs(find.byType(DatePickerButton)));
        });

        testWidgetsOnArbitraryDesktop("maxes out when button is very wide", (tester) async {
          await _pumpWithButtonAtCenter(
            tester,
            windowWidth: 1000,
            datePicker: DatePicker(
              onDaySelected: (_) {},
            ),
          );

          // Open the calendar popover.
          await tester.tap(find.byType(DatePickerButton));
          await tester.pump();

          // Ensure the calendar has the same width as the button.
          expect(find.byType(MonthlyCalendar), findsOne);
          expect(find.byType(MonthlyCalendar), hasWidth(600));
        });

        testWidgetsOnArbitraryDesktop("stops shrinking when button is very narrow", (tester) async {
          await _pumpWithButtonAtCenter(
            tester,
            datePicker: SizedBox(
              width: 100,
              child: DatePicker(
                onDaySelected: (_) {},
              ),
            ),
          );

          // Open the calendar popover.
          await tester.tap(find.byType(DatePickerButton));
          await tester.pump();

          // Ensure the calendar has the same width as the button.
          expect(find.byType(MonthlyCalendar), findsOne);
          expect(find.byType(MonthlyCalendar), hasWidth(250));
        });
      });
    });
  });
}

Future<void> _pumpWithButtonNearTop(
  WidgetTester tester, {
  required Widget datePicker,
  double windowWidth = 600,
}) async {
  await _pumpScaffold(
    tester,
    windowWidth: windowWidth,
    child: Align(
      alignment: Alignment.topCenter,
      child: datePicker,
    ),
  );
}

Future<void> _pumpWithButtonAtCenter(
  WidgetTester tester, {
  required Widget datePicker,
  double windowWidth = 600,
}) async {
  await _pumpScaffold(
    tester,
    windowWidth: windowWidth,
    child: Center(
      child: datePicker,
    ),
  );
}

Future<void> _pumpWithButtonNearBottom(
  WidgetTester tester, {
  required Widget datePicker,
  double windowWidth = 600,
}) async {
  await _pumpScaffold(
    tester,
    windowWidth: windowWidth,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: datePicker,
    ),
  );
}

Future<void> _pumpScaffold(
  WidgetTester tester, {
  double windowWidth = 600,
  required Widget child,
}) async {
  tester.view.physicalSize = Size(windowWidth, 1000);
  addTearDown(() => tester.view.resetPhysicalSize());

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(48),
          child: child,
        ),
      ),
    ),
  );
}
