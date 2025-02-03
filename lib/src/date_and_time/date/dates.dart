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

extension Days on DateTime {
  int get daysInMonth {
    var firstDayOfNextMonth = (month < 12) //
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);

    return firstDayOfNextMonth.subtract(Duration(days: 1)).day;
  }
}
