class PrefsCalendar {
  String campus;
  String department;
  String year;
  String group;

  PrefsCalendar({
    this.campus,
    this.department,
    this.year,
    this.group,
  });

  String toString() {
    return "$campus, $department, $year, $group";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrefsCalendar &&
          runtimeType == other.runtimeType &&
          campus == other.campus &&
          department == other.department &&
          year == other.year &&
          group == other.group;

  @override
  int get hashCode =>
      campus.hashCode ^ department.hashCode ^ year.hashCode ^ group.hashCode;
}
