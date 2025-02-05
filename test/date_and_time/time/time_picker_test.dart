import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_bricks/golden_bricks.dart';
import 'package:lucid/lucid.dart';

void main() {
  group("Time Picker >", () {
    group("time resolution configurations >", () {
      testWidgets("hour, minute, second", (tester) async {
        await _pumpScaffold(
          tester,
          child: Center(
            child: TimePicker(
              timeResolution: TimeResolution.second,
              onNewTimeRequested: (_) {},
            ),
          ),
        );

        expect(find.byKey(TimePicker.hourKey), findsOne);
        expect(find.byKey(TimePicker.minuteKey), findsOne);
        expect(find.byKey(TimePicker.secondKey), findsOne);
      });

      testWidgets("hour, minute", (tester) async {
        await _pumpScaffold(
          tester,
          child: TimePicker(
            timeResolution: TimeResolution.minute,
            onNewTimeRequested: (_) {},
          ),
        );

        expect(find.byKey(TimePicker.hourKey), findsOne);
        expect(find.byKey(TimePicker.minuteKey), findsOne);
        expect(find.byKey(TimePicker.secondKey), findsNothing);
      });

      testWidgets("hour", (tester) async {
        await _pumpScaffold(
          tester,
          child: TimePicker(
            timeResolution: TimeResolution.hour,
            onNewTimeRequested: (_) {},
          ),
        );

        expect(find.byKey(TimePicker.hourKey), findsOne);
        expect(find.byKey(TimePicker.minuteKey), findsNothing);
        expect(find.byKey(TimePicker.secondKey), findsNothing);
      });
    });

    group("focus >", () {
      testWidgets("TAB and SHIFT+TAB move through components", (tester) async {
        await _pumpScaffold(
          tester,
          child: Center(
            child: TimePicker(
              onNewTimeRequested: (_) {},
            ),
          ),
        );

        // Ensure nothing has focus yet.
        // TODO:

        // Ensure the hours component has focus.
        // TODO:

        // Ensure the minutes component has focus.
        // TODO:

        // Ensure the seconds component has focus.
        // TODO:

        // Ensure the period has focus.
        // TODO:

        // ---- REVERSE DIRECTION ----

        // Ensure the seconds component has focus.
        // TODO:

        // Ensure the minutes component has focus.
        // TODO:

        // Ensure the hours component has focus.
        // TODO:
      });

      testWidgets("ESC removes focus", (tester) async {
        await _pumpScaffold(
          tester,
          child: Center(
            child: TimePicker(
              onNewTimeRequested: (_) {},
            ),
          ),
        );

        // Ensure nothing has focus yet.
        // TODO:

        // Give focus to the hours component.
        // TODO:

        // TODO: press ESC

        // Ensure nothing has focus.
        // TODO:

        // Give focus to the minutes component.
        // TODO:

        // TODO: press ESC

        // Ensure nothing has focus.
        // TODO:

        // Give focus to the seconds component.
        // TODO:

        // TODO: press ESC

        // Ensure nothing has focus.
        // TODO:

        // Give focus to the period component.
        // TODO:

        // TODO: press ESC

        // Ensure nothing has focus.
        // TODO:
      });
    });
  });
}

Future<void> _pumpScaffold(
  WidgetTester tester, {
  required Widget child,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DefaultTextStyle(
          style: TextStyle(
            fontFamily: goldenBricks,
          ),
          child: child,
        ),
      ),
    ),
  );
}
