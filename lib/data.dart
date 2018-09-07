import 'package:myagenda/models/prefs_calendar.dart';

class Data {
  static Map<String, dynamic> allData = {};

  static List<String> getAllCampus() => allData.keys.toList();

  static List<String> getCampusDepartments(String campus) {
    if (campus == null || !allData.containsKey(campus))
      campus = getAllCampus()[0];

    return allData[campus].keys.toList();
  }

  static List<String> getYears(String campus, String department) {
    if (campus == null || !allData.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !allData[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];

    return allData[campus][department].keys.toList();
  }

  static List<String> getGroups(String campus, String department, String year) {
    if (campus == null || !allData.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !allData[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !allData[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    return allData[campus][department][year].keys.toList();
  }

  static int getGroupRes(
      String campus, String department, String year, String group) {
    if (campus == null || !allData.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !allData[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !allData[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    if (group == null || !allData[campus][department][year].containsKey(group))
      group = getGroups(campus, department, year)[0];

    return allData[campus][department][year][group];
  }

  static PrefsCalendar checkDataValues(
      {String campus, String department, String year, String group}) {
    if (campus == null || !allData.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !allData[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !allData[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    if (group == null || !allData[campus][department][year].containsKey(group))
      group = getGroups(campus, department, year)[0];

    return PrefsCalendar(
        campus: campus, department: department, year: year, group: group);
  }
}
