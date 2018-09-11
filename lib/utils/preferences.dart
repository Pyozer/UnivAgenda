import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MyInheritedPreferences extends InheritedWidget {
  _MyInheritedPreferences({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final PreferencesProviderState data;

  @override
  bool updateShouldNotify(_MyInheritedPreferences oldWidget) {
    return (data != oldWidget.data);
  }
}

class PreferencesProvider extends StatefulWidget {
  final Widget child;

  const PreferencesProvider({Key key, this.child}) : super(key: key);

  @override
  PreferencesProviderState createState() => PreferencesProviderState();

  static PreferencesProviderState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_MyInheritedPreferences)
            as _MyInheritedPreferences)
        .data;
  }
}

class PreferencesProviderState extends State<PreferencesProvider> {
  @override
  void initState() {
    super.initState();
    initFromDisk();
  }

  @override
  Widget build(BuildContext context) {
    return _MyInheritedPreferences(data: this, child: widget.child);
  }

  String _university;
  String _campus;
  String _department;
  String _year;
  String _group;
  int _numberWeeks;
  bool _darkTheme;
  int _primaryColor;
  int _accentColor;
  int _noteColor;
  bool _firstBoot;
  String _cachedIcal;
  List<Note> _notes;
  List<Course> _customEvents;
  bool _userLogged;
  bool _horizontalView;
  Map<String, dynamic> _resources;

  String get university => _university;

  setUniversity(String newUniversity, [state = true]) {
    if (university == newUniversity) return;

    changeGroupPref(newUniversity, campus, department, year, group, state);
  }

  String get campus => _campus;

  setCampus(String newCampus, [state = true]) {
    if (campus == newCampus) return;

    changeGroupPref(university, newCampus, department, year, group, state);
  }

  String get department => _department;

  setDepartment(String newDepartment, [state = true]) {
    if (department == newDepartment) return;

    changeGroupPref(university, campus, newDepartment, year, group, state);
  }

  String get year => _year;

  setYear(String newYear, [state = true]) {
    if (year == newYear) return;

    changeGroupPref(university, campus, department, newYear, group, state);
  }

  String get group => _group;

  setGroup(String newGroup, [state = true]) {
    if (group == newGroup) return;

    changeGroupPref(university, campus, department, year, newGroup, state);
  }

  void changeGroupPref(
    String newUniversity,
    String newCampus,
    String newDepartment,
    String newYear,
    String newGroup, [
    state = true,
  ]) {
    // Check if values are correct together
    PrefsCalendar values = checkDataValues(
      university: newUniversity,
      campus: newCampus,
      department: newDepartment,
      year: newYear,
      group: newGroup,
    );

    if (university == values.university &&
        campus == values.campus &&
        department == values.department &&
        year == values.year &&
        group == values.group) return;

    _updatePref(() {
      _university = values.university;
      _campus = values.campus;
      _department = values.department;
      _year = values.year;
      _group = values.group;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(PrefKey.university, values.university);
      prefs.setString(PrefKey.campus, values.campus);
      prefs.setString(PrefKey.department, values.department);
      prefs.setString(PrefKey.year, values.year);
      prefs.setString(PrefKey.group, values.group);
    });
  }

  List<String> getAllUniversity() => _resources.keys.toList();

  List<String> getAllCampus(String university) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];

    return _resources[university]["resources"].keys.toList();
  }

  List<String> getCampusDepartments(String university, String campus) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];
    if (campus == null ||
        !_resources[university]["resources"].containsKey(campus))
      campus = getAllCampus(university)[0];

    return _resources[university]["resources"][campus].keys.toList();
  }

  List<String> getYears(String university, String campus, String department) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];
    if (campus == null ||
        !_resources[university]["resources"].containsKey(campus))
      campus = getAllCampus(university)[0];
    if (department == null ||
        !_resources[university]["resources"][campus].containsKey(department))
      department = getCampusDepartments(university, campus)[0];

    return _resources[university]["resources"][campus][department]
        .keys
        .toList();
  }

  List<String> getGroups(
      String university, String campus, String department, String year) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];
    if (campus == null ||
        !_resources[university]["resources"].containsKey(campus))
      campus = getAllCampus(university)[0];
    if (department == null ||
        !_resources[university]["resources"][campus].containsKey(department))
      department = getCampusDepartments(university, campus)[0];
    if (year == null ||
        !_resources[university]["resources"][campus][department]
            .containsKey(year))
      year = getYears(university, campus, department)[0];
    return _resources[university]["resources"][campus][department][year]
        .keys
        .toList();
  }

  int getGroupRes(String university, String campus, String department,
      String year, String group) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];
    if (campus == null ||
        !_resources[university]["resources"].containsKey(campus))
      campus = getAllCampus(university)[0];
    if (department == null ||
        !_resources[university]["resources"][campus].containsKey(department))
      department = getCampusDepartments(university, campus)[0];
    if (year == null ||
        !_resources[university]["resources"][campus][department]
            .containsKey(year))
      year = getYears(university, campus, department)[0];
    if (group == null ||
        !_resources[university]["resources"][campus][department][year]
            .containsKey(group))
      group = getGroups(university, campus, department, year)[0];

    return _resources[university]["resources"][campus][department][year][group];
  }

  PrefsCalendar checkDataValues({
    String university,
    String campus,
    String department,
    String year,
    String group,
  }) {
    if (university == null || !_resources.containsKey(university))
      university = getAllUniversity()[0];
    if (campus == null || !_resources[university]['resources'].containsKey(campus))
      campus = getAllCampus(university)[0];

    print(university);
    print(campus);
    if (department == null ||
        !_resources[university]["resources"][campus].containsKey(department))
      department = getCampusDepartments(university, campus)[0];
    if (year == null ||
        !_resources[university]["resources"][campus][department].containsKey(year))
      year = getYears(university, campus, department)[0];
    if (group == null ||
        !_resources[university]["resources"][campus][department][year].containsKey(group))
      group = getGroups(university, campus, department, year)[0];

    return PrefsCalendar(
      university: university,
      campus: campus,
      department: department,
      year: year,
      group: group,
    );
  }

  String get loginUrl => _resources[university]['loginUrl'];
  String get agendaUrl => _resources[university]['agendaUrl'];

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  setNumberWeeks(int newNumberWeeks, [state = true]) {
    if (numberWeeks == newNumberWeeks) return;

    int intValue =
        (newNumberWeeks == null || newNumberWeeks < 1 || newNumberWeeks > 20)
            ? PrefKey.defaultNumberWeeks
            : newNumberWeeks;

    _updatePref(() {
      _numberWeeks = intValue;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.numberWeeks, intValue));
  }

  bool get isDarkTheme => _darkTheme ?? PrefKey.defaultDarkTheme;

  setDarkTheme(bool darkTheme, [state = true]) {
    if (isDarkTheme == darkTheme) return;

    _updatePref(() {
      _darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isDarkTheme, darkTheme));
  }

  int get primaryColor => _primaryColor ?? PrefKey.defaultPrimaryColor;

  setPrimaryColor(int newPrimaryColor, [state = true]) {
    if (primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.primaryColor, newPrimaryColor));
  }

  int get accentColor => _accentColor ?? PrefKey.defaultAccentColor;

  setAccentColor(int newAccentColor, [state = true]) {
    if (accentColor == newAccentColor) return;

    _updatePref(() {
      _accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.accentColor, newAccentColor));
  }

  int get noteColor => _noteColor ?? PrefKey.defaultNoteColor;

  setNoteColor(int newNoteColor, [state = true]) {
    if (noteColor == newNoteColor) return;

    _updatePref(() {
      _noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.noteColor, newNoteColor));
  }

  bool get isFirstBoot => _firstBoot ?? true;

  setFirstBoot(bool firstBoot, [state = true]) {
    if (isFirstBoot == firstBoot) return;

    _updatePref(() {
      _firstBoot = firstBoot ?? true;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isFirstBoot, firstBoot));
  }

  String get cachedIcal => _cachedIcal ?? null;

  setCachedIcal(String icalToCache, [state = false]) {
    if (cachedIcal == icalToCache) return;

    _updatePref(() {
      _cachedIcal = icalToCache ?? null;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(PrefKey.cachedIcal, icalToCache));
  }

  List<Note> get notes =>
      _notes?.where((note) => !note.isExpired())?.toList() ?? [];

  List<Note> notesOfCourse(Course course) {
    return notes.where((note) => note.courseUid == course.uid).toList();
  }

  setNotes(List<Note> newNotes, [state = true]) {
    if (notes == newNotes) return;

    newNotes ??= [];
    // Remove expired notes
    newNotes.removeWhere((note) => note.isExpired());

    _updatePref(() {
      _notes = newNotes;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      List<String> notesJSON = [];
      newNotes.forEach((note) {
        notesJSON.add(json.encode(note.toJson()));
      });

      prefs.setStringList(PrefKey.notes, notesJSON);
    });
  }

  void addNote(Note noteToAdd, [state = true]) {
    if (noteToAdd == null) return;
    List<Note> newNotes = notes;
    newNotes.add(noteToAdd);

    setNotes(newNotes, state);
  }

  void removeNote(Note noteToRemove, [state = true]) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => (note == noteToRemove));

    setNotes(newNotes, state);
  }

  List<CustomCourse> get customEvents =>
      _customEvents?.where((event) => !event.isFinish())?.toList() ?? [];

  setCustomEvents(List<CustomCourse> newCustomEvents, [state = true]) {
    if (customEvents == newCustomEvents) return;

    newCustomEvents ??= [];
    newCustomEvents.removeWhere((event) => event.isFinish());

    _updatePref(() {
      _customEvents = newCustomEvents;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      List<String> eventsJSON = [];
      newCustomEvents.forEach((event) {
        if (event != null) eventsJSON.add(json.encode(event.toJson()));
      });

      prefs.setStringList(PrefKey.customEvent, eventsJSON);
    });
  }

  void addCustomEvent(CustomCourse eventToAdd, [state = true]) {
    if (eventToAdd == null) return;

    List<Course> newEvents = customEvents;
    newEvents.add(eventToAdd);

    setCustomEvents(newEvents, state);
  }

  void removeCustomEvent(CustomCourse eventToRemove, [state = true]) {
    if (eventToRemove == null) return;

    List<Course> newEvents = customEvents;
    newEvents.removeWhere((event) => (event == eventToRemove));

    setCustomEvents(newEvents, state);
  }

  void editCustomEvent(CustomCourse eventEdited, [state = true]) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited, false);
    addCustomEvent(eventEdited, state);
  }

  bool get isUserLogged => _userLogged ?? false;

  setUserLogged(bool userLogged, [state = true]) {
    if (isUserLogged == userLogged) return;

    _updatePref(() {
      _userLogged = userLogged ?? false;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isUserLogged, _userLogged));
  }

  bool get isHorizontalView => _horizontalView ?? PrefKey.defaultHorizontalView;

  setHorizontalView(bool horizontalView, [state = true]) {
    if (isHorizontalView == horizontalView) return;

    _updatePref(() {
      _horizontalView = horizontalView ?? PrefKey.defaultHorizontalView;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isHorizontalView, isHorizontalView));
  }

  Map<String, dynamic> get resources => _resources ?? {};

  setResources(Map<String, dynamic> newResources, [state = true]) {
    if (resources == newResources) return;

    _updatePref(() {
      _resources = newResources ?? {};
    }, state);

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setString(PrefKey.resources, json.encode(newResources)));
  }

  Map<String, dynamic> getThemeValues() {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.isDarkTheme] = isDarkTheme;
    dataPrefs[PrefKey.primaryColor] = primaryColor;
    dataPrefs[PrefKey.accentColor] = accentColor;
    dataPrefs[PrefKey.noteColor] = noteColor;
    dataPrefs[PrefKey.isHorizontalView] = isHorizontalView;

    return dataPrefs;
  }

  Map<String, dynamic> getGroupValues() {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.campus] = campus;
    dataPrefs[PrefKey.department] = department;
    dataPrefs[PrefKey.year] = year;
    dataPrefs[PrefKey.group] = group;
    dataPrefs[PrefKey.numberWeeks] = numberWeeks;

    return dataPrefs;
  }

  Map<String, dynamic> getGroupAndThemeValues() {
    Map allPrefs = getGroupValues();
    allPrefs.addAll(getThemeValues());

    return allPrefs;
  }

  Future<Null> initFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Init ressources for agendas
    String resourcesStr = prefs.getString(PrefKey.resources) ?? "{}";
    Map<String, dynamic> actualRes = json.decode(resourcesStr);

    // If no ressources saved, store defaults from JSON
    if (actualRes == null || actualRes.length == 0) {
      String jsonContent = await rootBundle.loadString("res/resources.json");
      actualRes = json.decode(jsonContent);
    }
    setResources(actualRes, false);

    // Init group preferences
    final String university = prefs.getString(PrefKey.university);
    final String campus = prefs.getString(PrefKey.campus);
    final String department = prefs.getString(PrefKey.department);
    final String year = prefs.getString(PrefKey.year);
    final String group = prefs.getString(PrefKey.group);

    // Check values and resave group prefs (useful if issue)
    changeGroupPref(university, campus, department, year, group, false);

    // Init number of weeks to display
    setNumberWeeks(prefs.getInt(PrefKey.numberWeeks), false);

    // Init theme preferences
    setHorizontalView(prefs.getBool(PrefKey.isHorizontalView), false);
    setDarkTheme(prefs.getBool(PrefKey.isDarkTheme), false);
    setPrimaryColor(prefs.getInt(PrefKey.primaryColor), false);
    setAccentColor(prefs.getInt(PrefKey.accentColor), false);
    setNoteColor(prefs.getInt(PrefKey.noteColor), false);

    // Init other prefs
    setCachedIcal(prefs.getString(PrefKey.cachedIcal), false);
    setUserLogged(prefs.getBool(PrefKey.isUserLogged), false);
    setFirstBoot(prefs.getBool(PrefKey.isFirstBoot), false);

    // Init saved notes
    List<Note> actualNotes = [];
    List<String> notesStr = prefs.getStringList(PrefKey.notes) ?? [];
    notesStr.forEach((noteJsonStr) {
      final note = Note.fromJsonStr(noteJsonStr);
      if (!note.isExpired()) actualNotes.add(note);
    });
    setNotes(actualNotes, false);

    List<CustomCourse> actualEvents = [];
    List<String> customEventsStr =
        prefs.getStringList(PrefKey.customEvent) ?? [];
    customEventsStr.forEach((eventJsonStr) {
      final event = CustomCourse.fromJsonStr(eventJsonStr);
      if (!event.isFinish()) actualEvents.add(event);
    });
    setCustomEvents(actualEvents, false);
  }

  void _updatePref(Function f, bool state) {
    if (state)
      setState(f);
    else
      f();
  }

  @override
  bool operator ==(Object other) =>
      other is PreferencesProviderState &&
      campus == other.campus &&
      department == other.department &&
      year == other.year &&
      group == other.group &&
      numberWeeks == other.numberWeeks &&
      isDarkTheme == other.isDarkTheme &&
      primaryColor == other.primaryColor &&
      accentColor == other.accentColor &&
      noteColor == other.noteColor &&
      isFirstBoot == other.isFirstBoot &&
      cachedIcal == other.cachedIcal &&
      notes == other.notes &&
      customEvents == other.customEvents &&
      isUserLogged == other.isUserLogged &&
      isHorizontalView == other.isHorizontalView &&
      resources == other.resources;

  @override
  int get hashCode =>
      _campus.hashCode ^
      _department.hashCode ^
      _year.hashCode ^
      _group.hashCode ^
      _numberWeeks.hashCode ^
      _darkTheme.hashCode ^
      _primaryColor.hashCode ^
      _accentColor.hashCode ^
      _noteColor.hashCode ^
      _firstBoot.hashCode ^
      _cachedIcal.hashCode ^
      _notes.hashCode ^
      _customEvents.hashCode ^
      _userLogged.hashCode ^
      _horizontalView.hashCode ^
      _resources.hashCode;
}
