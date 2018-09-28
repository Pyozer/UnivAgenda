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

  get value => weekDay;

  static get count => values.length;

  static List<WeekDay> get values =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  factory WeekDay.fromIndex(int value) => values[value - 1];
}
