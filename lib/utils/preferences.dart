import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/preferences/prefs_calendar.dart';
import 'package:myagenda/models/preferences/prefs_theme.dart';
import 'package:myagenda/models/preferences/university.dart';
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

  /// List of all university
  List<University> _listUniversity;

  /// Actual University
  University _university;

  /// Agenda preferences (campus, department, year, group)
  PrefsCalendar _prefsCalendar = PrefsCalendar();

  /// Number of weeks to display
  int _numberWeeks;

  /// Is app has been already launched
  bool _firstBoot;

  /// Is the user if logged
  bool _userLogged;

  /// If agenda is in horizontal mode
  bool _horizontalView;

  /// Last ical loaded
  String _cachedIcal;

  /// List of notes for events
  List<Note> _notes;

  /// List of all custom events
  List<Course> _customEvents;

  /// Resources (contain all agenda with their ID)
  Map<String, dynamic> _resources;

  /// Last date that the resources has ben updated
  DateTime _resourcesDate;

  PrefsCalendar get calendar => _prefsCalendar;

  setCampus(String newCampus, [state = true]) {
    if (calendar.campus == newCampus) return;

    changeGroupPref(
        newCampus, calendar.department, calendar.year, calendar.group, state);
  }

  setDepartment(String newDepartment, [state = true]) {
    if (calendar.department == newDepartment) return;

    changeGroupPref(
        calendar.campus, newDepartment, calendar.year, calendar.group, state);
  }

  setYear(String newYear, [state = true]) {
    if (calendar.year == newYear) return;

    changeGroupPref(
        calendar.campus, calendar.department, newYear, calendar.group, state);
  }

  setGroup(String newGroup, [state = true]) {
    if (calendar.group == newGroup) return;

    changeGroupPref(
        calendar.campus, calendar.department, calendar.year, newGroup, state);
  }

  void changeGroupPref(
    String newCampus,
    String newDepartment,
    String newYear,
    String newGroup, [
    state = true,
  ]) {
    // Check if values are correct together
    PrefsCalendar values = checkDataValues(
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
      prefs.setString(PrefKey.campus, values.campus);
      prefs.setString(PrefKey.department, values.department);
      prefs.setString(PrefKey.year, values.year);
      prefs.setString(PrefKey.group, values.group);
    });
  }

  List<String> getAllUniversity() {
    return _listUniversity.map((univ) => univ.name).toList();
  }

  University findUniversity(String university) {
    return listUniversity.firstWhere((univ) => univ.name == university,
        orElse: () => null);
  }

  List<String> getAllCampus() {
    return _resources.keys.toList();
  }

  List<String> getCampusDepartments(String campus) {
    if (campus == null || !_resources.containsKey(campus))
      campus = getAllCampus()[0];

    return _resources[campus].keys.toList();
  }

  List<String> getYears(String campus, String department) {
    if (campus == null || !_resources.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !_resources[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];

    return _resources[campus][department].keys.toList();
  }

  List<String> getGroups(String campus, String department, String year) {
    if (campus == null || !_resources.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !_resources[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !_resources[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    return _resources[campus][department][year].keys.toList();
  }

  int getGroupRes(String campus, String department, String year, String group) {
    if (campus == null || !_resources.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !_resources[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !_resources[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    if (group == null ||
        !_resources[campus][department][year].containsKey(group))
      group = getGroups(campus, department, year)[0];

    return _resources[campus][department][year][group];
  }

  PrefsCalendar checkDataValues({
    String campus,
    String department,
    String year,
    String group,
  }) {
    if (campus == null || !_resources.containsKey(campus))
      campus = getAllCampus()[0];
    if (department == null || !_resources[campus].containsKey(department))
      department = getCampusDepartments(campus)[0];
    if (year == null || !_resources[campus][department].containsKey(year))
      year = getYears(campus, department)[0];
    if (group == null ||
        !_resources[campus][department][year].containsKey(group))
      group = getGroups(campus, department, year)[0];

    return PrefsCalendar(
      campus: campus,
      department: department,
      year: year,
      group: group,
    );
  }

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
        .then((prefs) => prefs.setInt(PrefKey.numberWeeks, _numberWeeks));
  }

  PrefsTheme get theme => _prefsTheme;

  setDarkTheme(bool darkTheme, [state = true]) {
    if (theme.darkTheme == darkTheme) return;

    _updatePref(() {
      _prefsTheme.darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isDarkTheme, _prefsTheme.darkTheme));
  }

  setPrimaryColor(int newPrimaryColor, [state = true]) {
    if (theme.primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _prefsTheme.primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setInt(PrefKey.primaryColor, _prefsTheme.primaryColor));
  }

  setAccentColor(int newAccentColor, [state = true]) {
    if (theme.accentColor == newAccentColor) return;

    _updatePref(() {
      _prefsTheme.accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt(PrefKey.accentColor, _prefsTheme.accentColor));
  }

  setNoteColor(int newNoteColor, [state = true]) {
    if (theme.noteColor == newNoteColor) return;

    _updatePref(() {
      _prefsTheme.noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt(PrefKey.noteColor, _prefsTheme.noteColor));
  }

  bool get isFirstBoot => _firstBoot ?? true;

  setFirstBoot(bool firstBoot, [state = true]) {
    if (isFirstBoot == firstBoot) return;

    _updatePref(() {
      _firstBoot = firstBoot ?? true;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isFirstBoot, _firstBoot));
  }

  String get cachedIcal => _cachedIcal ?? null;

  setCachedIcal(String icalToCache, [state = false]) {
    if (cachedIcal == icalToCache) return;

    _updatePref(() {
      _cachedIcal = icalToCache ?? null;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(PrefKey.cachedIcal, _cachedIcal));
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
      _notes.forEach((note) {
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
      _customEvents.forEach((event) {
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
        (prefs) => prefs.setBool(PrefKey.isHorizontalView, _horizontalView));
  }

  List<University> get listUniversity => _listUniversity ?? [];

  setListUniversity(List<University> listUniv, [state = false]) {
    if (listUniversity == listUniv) return;

    _updatePref(() {
      _listUniversity = listUniv ?? [];
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      List<String> univsJSON = [];
      _listUniversity.forEach((univ) {
        if (univ != null) {
          String univJSONStr = json.encode(univ.toJson());
          univsJSON.add(univJSONStr);
        }
      });

      prefs.setStringList(PrefKey.listUniversity, univsJSON);
    });
  }

  University get university => _university;

  setUniversity(String newUniversity, [state = false]) {
    if ((university?.name ?? "") == newUniversity) return;

    if (listUniversity.length > 0) {
      var univ = findUniversity(newUniversity);

      univ ??= _listUniversity[0];
      _updatePref(() {
        _university = univ;
      }, state);

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(PrefKey.university, _university.name);
      });
    }
  }

  Map<String, dynamic> get resources => _resources ?? PrefKey.defaultResources;

  setResources(Map<String, dynamic> newResources, [state = true]) {
    if (resources == newResources) return;

    _updatePref(() {
      _resources = newResources ?? PrefKey.defaultResources;
    }, state);

    // Check actual calendar prefs with new resources
    changeGroupPref(
      calendar.campus,
      calendar.department,
      calendar.year,
      calendar.group,
      state,
    );

    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(PrefKey.resources, json.encode(_resources)),
    );
  }

  DateTime get resourcesDate => _resourcesDate ?? DateTime(1970);

  setResourcesDate([newResDate, state = false]) {
    newResDate ??= DateTime.now();

    _updatePref(() {
      _resourcesDate = newResDate;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(
          PrefKey.resourcesDate, _resourcesDate.millisecondsSinceEpoch);
    });
  }

  Future<Null> initFromDisk([state = false]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await initResAndGroup();

    final int resourcesDate = prefs.getInt(PrefKey.resourcesDate) ?? 0;
    setResourcesDate(DateTime.fromMillisecondsSinceEpoch(resourcesDate));

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

  Future<Null> initResAndGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Init stored values
    var storedListUnivsStr = prefs.getStringList(PrefKey.listUniversity) ?? [];
    String storedUniversityName = prefs.getString(PrefKey.university);
    String storedResourcesStr = prefs.getString(PrefKey.resources) ?? "{}";

    // Check valuees
    // Decode json from local
    List<University> listUniversity = [];
    storedListUnivsStr.forEach((univStr) {
      Map<String, dynamic> jsonMap = json.decode(univStr);
      listUniversity.add(University.fromJson(jsonMap));
    });
    // Update current list of university
    setListUniversity(listUniversity);

    // If list of university is not empty
    if (listUniversity.length > 0) {
      // If no university store
      if (storedUniversityName == null || storedUniversityName.length == 0) {
        // Take first university of list
        storedUniversityName = listUniversity[0].name;
      }
      setUniversity(storedUniversityName);

      // Parse local resources to Map
      Map<String, dynamic> localResources = json.decode(storedResourcesStr);
      // If local resources aren't empty
      if (localResources.length > 0) {
        // Init group preferences
        final String campus = prefs.getString(PrefKey.campus);
        final String department = prefs.getString(PrefKey.department);
        final String year = prefs.getString(PrefKey.year);
        final String group = prefs.getString(PrefKey.group);
        // Update
        setResources(localResources, false);
        // Check values and resave group prefs (useful if issue)
        changeGroupPref(campus, department, year, group, false);
      }
    }

    return null;
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
      listUniversity == other.listUniversity &&
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
      _listUniversity.hashCode ^
      _resources.hashCode;
}
