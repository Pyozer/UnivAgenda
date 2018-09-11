class PrefsCalendar {
  String university;
  String campus;
  String department;
  String year;
  String group;

  PrefsCalendar({
    this.university,
    this.campus,
    this.department,
    this.year,
    this.group,
  });

  Map<String, String> getValues() {
    return {
      'university': university,
      'campus': campus,
      'department': department,
      'year': year,
      'group': group
    };
  }
}
