class PrefsCalendar {
  String campus;
  String department;
  String year;
  String group;

  PrefsCalendar({this.campus, this.department, this.year, this.group});

  Map<String, String> getValues() {
    return {
      'campus': campus,
      'department': department,
      'year': year,
      'group': group
    };
  }
}
