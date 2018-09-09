import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/data.dart';
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
  Map<String, dynamic> _ressources;

  String get campus => _campus;

  set campus(String newCampus) {
    if (campus == newCampus) return;
    changeGroupPref(
      campus: newCampus,
      department: department,
      year: year,
      group: group,
    );
  }

  String get department => _department;

  set department(String newDepartment) {
    if (department == newDepartment) return;
    changeGroupPref(
      campus: campus,
      department: newDepartment,
      year: year,
      group: group,
    );
  }

  String get year => _year;

  set year(String newYear) {
    if (year == newYear) return;
    changeGroupPref(
      campus: campus,
      department: department,
      year: newYear,
      group: group,
    );
  }

  String get group => _group;

  set group(String newGroup) {
    if (group == newGroup) return;
    changeGroupPref(
      campus: campus,
      department: department,
      year: year,
      group: newGroup,
    );
  }

  void changeGroupPref(
      {String campus, String department, String year, String group}) {
    // Check if values are correct together
    PrefsCalendar values = Data.checkDataValues(
      campus: campus,
      department: department,
      year: year,
      group: group,
    );

    if (campus == values.campus &&
        department == values.department &&
        year == values.year &&
        group == values.group) return;

    setState(() {
      _campus = values.campus;
      _department = values.department;
      _year = values.year;
      _group = values.group;
    });

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(PrefKey.campus, values.campus);
      prefs.setString(PrefKey.department, values.department);
      prefs.setString(PrefKey.year, values.year);
      prefs.setString(PrefKey.group, values.group);
    });
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  set numberWeeks(int newNumberWeeks) {
    if (numberWeeks == newNumberWeeks) return;

    int intValue =
        (newNumberWeeks == null || newNumberWeeks < 1 || newNumberWeeks > 20)
            ? PrefKey.defaultNumberWeeks
            : newNumberWeeks;

    setState(() {
      _numberWeeks = intValue;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.numberWeeks, intValue));
  }

  bool get isDarkTheme => _darkTheme ?? PrefKey.defaultDarkTheme;

  set darkTheme(bool darkTheme) {
    if (isDarkTheme == darkTheme) return;

    setState(() {
      _darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isDarkTheme, darkTheme));
  }

  int get primaryColor => _primaryColor ?? PrefKey.defaultPrimaryColor;

  set primaryColor(int newPrimaryColor) {
    if (primaryColor == newPrimaryColor) return;

    setState(() {
      _primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.primaryColor, newPrimaryColor));
  }

  int get accentColor => _accentColor ?? PrefKey.defaultAccentColor;

  set accentColor(int newAccentColor) {
    if (accentColor == newAccentColor) return;

    setState(() {
      _accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.accentColor, newAccentColor));
  }

  int get noteColor => _noteColor ?? PrefKey.defaultNoteColor;

  set noteColor(int newNoteColor) {
    if (noteColor == newNoteColor) return;

    setState(() {
      _noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.noteColor, newNoteColor));
  }

  bool get isFirstBoot => _firstBoot ?? true;

  set firstBoot(bool firstBoot) {
    if (isFirstBoot == firstBoot) return;

    setState(() {
      _firstBoot = firstBoot ?? true;
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isFirstBoot, firstBoot));
  }

  String get cachedIcal => _cachedIcal ?? null;

  set cachedIcal(String icalToCache) {
    if (cachedIcal == icalToCache) return;

    setState(() {
      _cachedIcal = icalToCache ?? null;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(PrefKey.cachedIcal, icalToCache));
  }

  List<Note> get notes =>
      _notes?.where((note) => !note.isExpired())?.toList() ?? [];

  List<Note> notesOfCourse(Course course) {
    return notes.where((note) => note.courseUid == course.uid).toList();
  }

  set notes(List<Note> newNotes) {
    if (notes == newNotes) return;

    newNotes ??= [];
    // Remove expired notes
    newNotes.removeWhere((note) => note.isExpired());

    setState(() {
      _notes = newNotes;
    });

    SharedPreferences.getInstance().then((prefs) {
      List<String> notesJSON = [];
      newNotes.forEach((note) {
        notesJSON.add(json.encode(note.toJson()));
      });

      prefs.setStringList(PrefKey.notes, notesJSON);
    });
  }

  void addNote(Note noteToAdd) {
    if (noteToAdd == null) return;
    List<Note> newNotes = notes;
    newNotes.add(noteToAdd);
    notes = newNotes;
  }

  void removeNote(Note noteToRemove) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => (note == noteToRemove));
    notes = newNotes;
  }

  List<CustomCourse> get customEvents =>
      _customEvents?.where((event) => !event.isFinish())?.toList() ?? [];

  set customEvents(List<CustomCourse> newCustomEvents) {
    if (customEvents == newCustomEvents) return;

    newCustomEvents ??= [];
    newCustomEvents.removeWhere((event) => event.isFinish());
    setState(() {
      _customEvents = newCustomEvents;
    });

    SharedPreferences.getInstance().then((prefs) {
      List<String> eventsJSON = [];
      newCustomEvents.forEach((event) {
        if (event != null) eventsJSON.add(json.encode(event.toJson()));
      });

      prefs.setStringList(PrefKey.customEvent, eventsJSON);
    });
  }

  void addCustomEvent(CustomCourse eventToAdd) {
    if (eventToAdd == null) return;

    List<Course> newEvents = customEvents;
    newEvents.add(eventToAdd);
    customEvents = newEvents;
  }

  void removeCustomEvent(CustomCourse eventToRemove) {
    if (eventToRemove == null) return;

    List<Course> newEvents = customEvents;
    newEvents.removeWhere((event) => (event == eventToRemove));
    customEvents = newEvents;
  }

  void editCustomEvent(CustomCourse eventEdited) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited);
    addCustomEvent(eventEdited);
  }

  bool get isUserLogged => _userLogged ?? false;

  set userLogged(bool userLogged) {
    if (isUserLogged == userLogged) return;

    setState(() {
      _userLogged = userLogged ?? false;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isLogged, _userLogged));
  }

  bool get isHorizontalView => _horizontalView ?? PrefKey.defaultHorizontalView;

  set horizontalView(bool horizontalView) {
    if (isHorizontalView == horizontalView) return;

    setState(() {
      _horizontalView = horizontalView ?? PrefKey.defaultHorizontalView;
    });

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isHorizontalView, isHorizontalView));
  }

  Map<String, dynamic> get ressources => _ressources ?? {};

  set ressources(Map<String, dynamic> newRessources) {
    if (ressources == newRessources) return;

    setState(() {
      _ressources = newRessources ?? {};
    });

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setString(PrefKey.ressources, json.encode(newRessources)));
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
    Map<String, dynamic> actualRes =
        json.decode(prefs.getString(PrefKey.ressources) ?? "{}");
    // If no ressources saved, store defaults from JSON
    if (actualRes == null || actualRes.length == 0) {
      String jsonContent = await rootBundle.loadString("res/ressources.json");
      actualRes = json.decode(jsonContent);
    }
    ressources = actualRes;
    Data.allData = ressources;

    // Init group preferences
    final String campus = prefs.getString(PrefKey.campus);
    final String department = prefs.getString(PrefKey.department);
    final String year = prefs.getString(PrefKey.year);
    final String group = prefs.getString(PrefKey.group);

    // Check values and resave group prefs (useful if issue)
    changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    // Init number of weeks to display
    numberWeeks = prefs.getInt(PrefKey.numberWeeks);

    // Init theme preferences
    horizontalView = prefs.getBool(PrefKey.isHorizontalView);
    darkTheme = prefs.getBool(PrefKey.isDarkTheme);
    primaryColor = prefs.getInt(PrefKey.primaryColor);
    accentColor = prefs.getInt(PrefKey.accentColor);
    noteColor = prefs.getInt(PrefKey.noteColor);

    // Init other prefs
    cachedIcal = prefs.getString(PrefKey.cachedIcal);
    userLogged = prefs.getBool(PrefKey.isLogged);
    firstBoot = prefs.getBool(PrefKey.isFirstBoot);

    // Init saved notes
    List<Note> actualNotes = [];
    List<String> notesStr = prefs.getStringList(PrefKey.notes) ?? [];
    notesStr.forEach((noteJsonStr) {
      final note = Note.fromJsonStr(noteJsonStr);
      if (!note.isExpired()) actualNotes.add(note);
    });
    notes = actualNotes;

    List<CustomCourse> actualEvents = [];
    List<String> customEventsStr =
        prefs.getStringList(PrefKey.customEvent) ?? [];
    customEventsStr.forEach((eventJsonStr) {
      final event = CustomCourse.fromJsonStr(eventJsonStr);
      if (!event.isFinish()) actualEvents.add(event);
    });
    customEvents = actualEvents;
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
      ressources == other.ressources;

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
      _ressources.hashCode;
}
