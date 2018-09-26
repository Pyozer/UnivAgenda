class WeekDay {
  final int weekDay;

  const WeekDay._(this.weekDay);

  static final MONDAY = WeekDay._(0);
  static final TUESDAY = WeekDay._(1);
  static final WEDNESDAY = WeekDay._(2);
  static final THURSDAY = WeekDay._(3);
  static final FRIDAY = WeekDay._(4);
  static final SATURDAY = WeekDay._(5);
  static final SUNDAY = WeekDay._(6);

  get value => weekDay;

  static get count => values.length;

  static List<WeekDay> get values =>
      [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY];

  factory WeekDay.fromIndex(int value) => values[value];
}
