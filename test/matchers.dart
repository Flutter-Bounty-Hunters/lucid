import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher isAbove(Finder widgetAbove, [Matcher? byAmount]) {
  return IsAbove(widgetAbove, byAmount: byAmount);
}

class IsAbove extends Matcher {
  static const _errorKey = "error";

  const IsAbove(
    this.widgetBelow, {
    this.byAmount,
  });

  final Finder widgetBelow;
  final Matcher? byAmount;

  @override
  Description describe(Description description) {
    return description..add("A widget to be above another widget");
  }

  @override
  bool matches(widgetAbove, Map<dynamic, dynamic> matchState) {
    // ---- Widget Above ----
    if (widgetAbove is! Finder) {
      matchState[_errorKey] = "Expected a Finder for the 'widget above'. Actual type was: ${widgetAbove.runtimeType}";
      return false;
    }

    final aboveElements = widgetAbove.evaluate();
    if (aboveElements.length != 1) {
      matchState[_errorKey] = "Expected to find exactly 1 'widget above'. Actually found: ${aboveElements.length}";
      return false;
    }

    final aboveElement = aboveElements.first;
    final aboveBox = aboveElement.renderObject;
    if (aboveBox == null) {
      matchState[_errorKey] = "Expected to find to find a RenderBox for 'widget above' but its render object was null.";
      return false;
    }
    if (aboveBox is! RenderBox) {
      matchState[_errorKey] =
          "Expected to find to find a RenderBox for 'widget above'. Actual found: ${aboveBox.runtimeType}";
      return false;
    }

    final aboveRect = aboveBox.localToGlobal(Offset.zero) & aboveBox.size;

    // ---- Widget Below ----
    final belowElements = widgetBelow.evaluate();
    if (belowElements.length != 1) {
      matchState[_errorKey] = "Expected to find exactly 1 'widget below'. Actually found: ${belowElements.length}";
      return false;
    }

    final belowElement = belowElements.first;
    final belowBox = belowElement.renderObject;
    if (belowBox == null) {
      matchState[_errorKey] = "Expected to find to find a RenderBox for 'widget below' but its render object was null.";
      return false;
    }
    if (belowBox is! RenderBox) {
      matchState[_errorKey] =
          "Expected to find to find a RenderBox for 'widget below'. Actual found: ${belowBox.runtimeType}";
      return false;
    }

    final belowRect = belowBox.localToGlobal(Offset.zero) & belowBox.size;

    final delta = belowRect.top - aboveRect.bottom;
    if (delta < 0) {
      matchState[_errorKey] =
          "Expected ${aboveElement.widget} to be above ${belowElement.widget}. Above widget (${aboveElement.widget}) was ${delta.abs()}px below the top of the below widget (${belowElement.widget})";
      return false;
    }

    if (byAmount != null) {
      final mismatchState = <dynamic, dynamic>{};
      final matches = byAmount!.matches(delta, mismatchState);
      if (!matches) {
        final amountDescription = StringDescription();
        byAmount!.describe(amountDescription);
        matchState[_errorKey] =
            "Expected ${aboveElement.widget} to be above ${belowElement.widget} by an '${amountDescription.toString()}'. Actual delta: $delta";
        return false;
      }
    }

    // The above widget is above the below widget.
    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription //
      ..add(matchState[_errorKey]);
  }
}

Matcher isBelow(Finder widgetAbove, [Matcher? byAmount]) {
  return IsBelow(widgetAbove, byAmount: byAmount);
}

class IsBelow extends Matcher {
  static const _errorKey = "error";

  const IsBelow(
    this.widgetAbove, {
    this.byAmount,
  });

  final Finder widgetAbove;
  final Matcher? byAmount;

  @override
  Description describe(Description description) {
    return description..add("A widget to be below another widget");
  }

  @override
  bool matches(widgetBelow, Map<dynamic, dynamic> matchState) {
    // ---- Widget Below ----
    if (widgetBelow is! Finder) {
      matchState[_errorKey] = "Expected a Finder for the 'widget below'. Actual type was: ${widgetBelow.runtimeType}";
      return false;
    }

    final belowElements = widgetBelow.evaluate();
    if (belowElements.length != 1) {
      matchState[_errorKey] = "Expected to find exactly 1 'widget below'. Actually found: ${belowElements.length}";
      return false;
    }

    final belowElement = belowElements.first;
    final belowBox = belowElement.renderObject;
    if (belowBox == null) {
      matchState[_errorKey] = "Expected to find to find a RenderBox for 'widget below' but its render object was null.";
      return false;
    }
    if (belowBox is! RenderBox) {
      matchState[_errorKey] =
          "Expected to find to find a RenderBox for 'widget below'. Actual found: ${belowBox.runtimeType}";
      return false;
    }

    final belowRect = belowBox.localToGlobal(Offset.zero) & belowBox.size;

    // ---- Widget Above ----
    final aboveElements = widgetAbove.evaluate();
    if (aboveElements.length != 1) {
      matchState[_errorKey] = "Expected to find exactly 1 'widget above'. Actually found: ${aboveElements.length}";
      return false;
    }

    final aboveElement = aboveElements.first;
    final aboveBox = aboveElement.renderObject;
    if (aboveBox == null) {
      matchState[_errorKey] = "Expected to find to find a RenderBox for 'widget above' but its render object was null.";
      return false;
    }
    if (aboveBox is! RenderBox) {
      matchState[_errorKey] =
          "Expected to find to find a RenderBox for 'widget above'. Actual found: ${aboveBox.runtimeType}";
      return false;
    }

    final aboveRect = aboveBox.localToGlobal(Offset.zero) & aboveBox.size;

    final delta = belowRect.top - aboveRect.bottom;
    if (delta < 0) {
      matchState[_errorKey] =
          "Expected ${belowElement.widget} to be below ${aboveElement.widget}. The top of ${belowElement.widget} was ${delta.abs()}px above the bottom of ${aboveElement.widget}.";
      return false;
    }

    if (byAmount != null) {
      final mismatchState = <dynamic, dynamic>{};
      final matches = byAmount!.matches(delta, mismatchState);
      if (!matches) {
        final amountDescription = StringDescription();
        byAmount!.describe(amountDescription);
        matchState[_errorKey] =
            "Expected ${belowElement.widget} to be below ${aboveElement.widget} by an '${amountDescription.toString()}'. Actual delta: $delta";
        return false;
      }
    }

    // The above widget is above the below widget.
    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription //
      ..add(matchState[_errorKey]);
  }
}

Matcher byAmount(double amount, {double epsilon = 0.00001}) {
  return ByAmount(amount, epsilon: epsilon);
}

class ByAmount extends Matcher {
  const ByAmount(this.expectedAmount, {double epsilon = 0.00001}) : closeEnoughEpsilon = epsilon;

  final double expectedAmount;
  final double closeEnoughEpsilon;

  @override
  Description describe(Description description) {
    description.add("Amount equal to $expectedAmount, +/- $closeEnoughEpsilon");
    return description;
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! num) {
      // We don't know how to match against this.
      return false;
    }

    return expectedAmount - closeEnoughEpsilon <= item && item <= expectedAmount + closeEnoughEpsilon;
  }

  @override
  Description describeMismatch(Object? item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is! num) {
      mismatchDescription.add("Expected a num. The actual type is: $item");
      return mismatchDescription;
    }

    mismatchDescription
      ..add("is the wrong amount\n\n")
      ..add("Expected amount: $expectedAmount +/- $closeEnoughEpsilon\n")
      ..add("Actual amount: $item");
    return mismatchDescription;
  }
}

Matcher isSameWidthAs(Finder target) {
  return IsSameWidthAs(target);
}

class IsSameWidthAs extends Matcher {
  static const _errorKey = "error";

  const IsSameWidthAs(this.target);

  final Finder target;

  @override
  Description describe(Description description) {
    return description //
      ..add("Widgets of equal width");
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! Finder) {
      return false;
    }

    final (primaryElement, primaryBox) = _findRenderBox(target, matchState, _errorKey);
    if (primaryBox == null) {
      return false;
    }

    final (comparisonElement, comparisonBox) = _findRenderBox(item, matchState, _errorKey);
    if (comparisonBox == null) {
      return false;
    }

    if (primaryBox.size.width != comparisonBox.size.width) {
      matchState[_errorKey] =
          "Widget width mismatch. ${primaryElement!.widget} width: ${primaryBox.size.width}px. ${comparisonElement!.widget} width: ${comparisonBox.size.width}";
      return false;
    }

    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription..add(matchState[_errorKey]);
  }
}

Matcher hasWidth(double expectedWidth) {
  return HasWidth(expectedWidth);
}

class HasWidth extends Matcher {
  static const _errorKey = "error";

  const HasWidth(this.expectedWidth);

  final double expectedWidth;

  @override
  Description describe(Description description) {
    return description //
      ..add("Widget with a width of ${expectedWidth}px");
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! Finder) {
      return false;
    }

    final (element, renderBox) = _findRenderBox(item, matchState, _errorKey);
    if (renderBox == null) {
      return false;
    }

    if (renderBox.size.width != expectedWidth) {
      matchState[_errorKey] =
          "Expected ${element!.widget} to have a width of ${expectedWidth}px. Actual: ${renderBox.size.width}px";
      return false;
    }

    return true;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription..add(matchState[_errorKey]);
  }
}

(Element?, RenderBox?) _findRenderBox(Finder finder, Map<dynamic, dynamic> matchState, String errorKey) {
  final elements = finder.evaluate();
  if (elements.length != 1) {
    matchState[errorKey] = "Expected to find exactly 1 widget with Finder ($finder). Found: ${elements.length}";
    return (null, null);
  }

  final renderObject = elements.first.renderObject;
  if (renderObject is! RenderBox) {
    matchState[errorKey] = "Expected to find a RenderBox with Finder ($finder). Actual: $renderObject.";
    return (null, null);
  }

  return (elements.first, renderObject);
}
