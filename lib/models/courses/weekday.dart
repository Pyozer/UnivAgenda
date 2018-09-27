class WeekDay {
  final int weekDay;

  const WeekDay._(this.weekDay);

  static final MONDAY = WeekDay._(DateTime.monday);
  static final TUESDAY = WeekDay._(DateTime.tuesday);
  static final WEDNESDAY = WeekDay._(DateTime.wednesday);
  static final THURSDAY = WeekDay._(DateTime.thursday);
  static final FRIDAY = WeekDay._(DateTime.friday);
  static final SATURDAY = WeekDay._(DateTime.saturday);
  static final SUNDAY = WeekDay._(DateTime.sunday);

  get value => weekDay;

  static get count => values.length;

  static List<WeekDay> get values =>
      [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY];

  factory WeekDay.fromIndex(int value) => values[value - 1];
}
