class WeekDay {
  final int value;

  const WeekDay._(this.value);

  static const monday = WeekDay._(DateTime.monday);
  static const tuesday = WeekDay._(DateTime.tuesday);
  static const wednesday = WeekDay._(DateTime.wednesday);
  static const thursday = WeekDay._(DateTime.thursday);
  static const friday = WeekDay._(DateTime.friday);
  static const saturday = WeekDay._(DateTime.saturday);
  static const sunday = WeekDay._(DateTime.sunday);

  static get count => values.length;

  static List<WeekDay> get values =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  factory WeekDay.fromValue(int value) {
    if (value < 1) {
      value = 0;
    } else if (value > count) {
      value = count;
    }

    return values[value - 1];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekDay &&
          runtimeType == other.runtimeType &&
          value == other.value) ||
      (other is int && other == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }
}
