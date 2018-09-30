class WeekDay {
  final int weekDay;

  const WeekDay._(this.weekDay);

  static final monday = WeekDay._(DateTime.monday);
  static final tuesday = WeekDay._(DateTime.tuesday);
  static final wednesday = WeekDay._(DateTime.wednesday);
  static final thursday = WeekDay._(DateTime.thursday);
  static final friday = WeekDay._(DateTime.friday);
  static final saturday = WeekDay._(DateTime.saturday);
  static final sunday = WeekDay._(DateTime.sunday);

  int get value => weekDay;

  static get count => values.length;

  static List<WeekDay> get values =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  factory WeekDay.fromValue(int value) {
    if (value < 1)
      value = 0;
    else if (value > count) value = count;

    return values[value - 1];
  }

  @override
  bool operator ==(Object other) {
    return (other is WeekDay && other.value == value) ||
        (other is int && other == value);
  }

  @override
  String toString() {
      return value.toString();
    }
}
