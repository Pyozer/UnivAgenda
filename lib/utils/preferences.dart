import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/preferences/prefs_calendar.dart';
import 'package:myagenda/models/preferences/prefs_theme.dart';
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
  Widget build(BuildContext context) {
    return _MyInheritedPreferences(data: this, child: widget.child);
  }

  PrefsTheme _prefsTheme = PrefsTheme(
    darkTheme: PrefKey.defaultDarkTheme,
    primaryColor: PrefKey.defaultPrimaryColor,
    accentColor: PrefKey.defaultAccentColor,
    noteColor: PrefKey.defaultNoteColor,
  );
  PrefsCalendar _prefsCalendar = PrefsCalendar();
  int _numberWeeks;
  bool _firstBoot;
  String _cachedIcal;
  List<Note> _notes;
  List<Course> _customEvents;
  bool _userLogged;
  bool _horizontalView;
  Map<String, dynamic> _resources;
  DateTime _resourcesDate;

  PrefsCalendar get calendar => _prefsCalendar;

  setUniversity(String newUniversity, [state = true]) {
    if (calendar.university == newUniversity) return;

    changeGroupPref(newUniversity, calendar.campus, calendar.department,
        calendar.year, calendar.group, state);
  }

  setCampus(String newCampus, [state = true]) {
    if (calendar.campus == newCampus) return;

    changeGroupPref(calendar.university, newCampus, calendar.department,
        calendar.year, calendar.group, state);
  }

  setDepartment(String newDepartment, [state = true]) {
    if (calendar.department == newDepartment) return;

    changeGroupPref(calendar.university, calendar.campus, newDepartment,
        calendar.year, calendar.group, state);
  }

  setYear(String newYear, [state = true]) {
    if (calendar.year == newYear) return;

    changeGroupPref(calendar.university, calendar.campus, calendar.department,
        newYear, calendar.group, state);
  }

  setGroup(String newGroup, [state = true]) {
    if (calendar.group == newGroup) return;

    changeGroupPref(calendar.university, calendar.campus, calendar.department,
        calendar.year, newGroup, state);
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

    if (_prefsCalendar == values) return;

    _updatePref(() {
      _prefsCalendar = values;
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
    if (campus == null ||
        !_resources[university]['resources'].containsKey(campus))
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

    return PrefsCalendar(
      university: university,
      campus: campus,
      department: department,
      year: year,
      group: group,
    );
  }

  String get loginUrl => _resources[calendar.university]['loginUrl'];

  String get agendaUrl => _resources[calendar.university]['agendaUrl'];

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

  PrefsTheme get theme => _prefsTheme;

  setDarkTheme(bool darkTheme, [state = true]) {
    if (theme.darkTheme == darkTheme) return;

    _updatePref(() {
      _prefsTheme.darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isDarkTheme, darkTheme));
  }

  setPrimaryColor(int newPrimaryColor, [state = true]) {
    if (theme.primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _prefsTheme.primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.primaryColor, newPrimaryColor));
  }

  setAccentColor(int newAccentColor, [state = true]) {
    if (theme.accentColor == newAccentColor) return;

    _updatePref(() {
      _prefsTheme.accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.accentColor, newAccentColor));
  }

  setNoteColor(int newNoteColor, [state = true]) {
    if (theme.noteColor == newNoteColor) return;

    _updatePref(() {
      _prefsTheme.noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
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

  Map<String, dynamic> get resources => _resources ?? PrefKey.defaultResources;

  setResources(Map<String, dynamic> newResources, [state = true]) {
    if (resources == newResources) return;

    _updatePref(() {
      _resources = newResources ?? PrefKey.defaultResources;
    }, state);

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setString(PrefKey.resources, json.encode(newResources)));
  }

  DateTime get resourcesDate => _resourcesDate ?? DateTime(1970);

  setResourcesDate([newResDate, state = false]) {
    newResDate ??= DateTime.now();

    _updatePref(() {
      _resourcesDate = newResDate;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(PrefKey.resourcesDate, newResDate.millisecondsSinceEpoch);
    });
  }

  Future<Null> initFromDisk([state = false]) async {
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

    final int resourcesDate = prefs.getInt(PrefKey.resourcesDate) ?? 0;
    setResourcesDate(DateTime.fromMillisecondsSinceEpoch(resourcesDate));

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

    // Set update state true/false on last to force rebuild
    setCustomEvents(actualEvents, state);
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
      calendar == other.calendar &&
      numberWeeks == other.numberWeeks &&
      theme == other.theme &&
      isFirstBoot == other.isFirstBoot &&
      cachedIcal == other.cachedIcal &&
      notes == other.notes &&
      customEvents == other.customEvents &&
      isUserLogged == other.isUserLogged &&
      isHorizontalView == other.isHorizontalView &&
      resources == other.resources;

  @override
  int get hashCode =>
      _prefsCalendar.hashCode ^
      _numberWeeks.hashCode ^
      _prefsTheme.hashCode ^
      _firstBoot.hashCode ^
      _cachedIcal.hashCode ^
      _notes.hashCode ^
      _customEvents.hashCode ^
      _userLogged.hashCode ^
      _horizontalView.hashCode ^
      _resources.hashCode;
}
