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

typedef Widget PreferenceBuilder(BuildContext context);

class PreferencesProvider extends StatefulWidget {
  final PreferenceBuilder preferenceBuilder;

  const PreferencesProvider({Key key, this.preferenceBuilder})
      : super(key: key);

  @override
  PreferencesProviderState createState() => PreferencesProviderState();

  static PreferencesProviderState of(BuildContext context) {
    return context
        .ancestorStateOfType(const TypeMatcher<PreferencesProviderState>());
  }
}

class PreferencesProviderState extends State<PreferencesProvider> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future _loadPreferences() async {
    await initFromDisk();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    return widget.preferenceBuilder(context);
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
    changeGroupPref(
      campus: newCampus,
      department: department,
      year: year,
      group: group,
    );
  }

  String get department => _department;

  set department(String newDepartment) {
    changeGroupPref(
      campus: campus,
      department: newDepartment,
      year: year,
      group: group,
    );
  }

  String get year => _year;

  set year(String newYear) {
    changeGroupPref(
      campus: campus,
      department: department,
      year: newYear,
      group: group,
    );
  }

  String get group => _group;

  set group(String newGroup) {
    changeGroupPref(
      campus: campus,
      department: department,
      year: year,
      group: newGroup,
    );
  }

  PrefsCalendar changeGroupPref({
    String campus,
    String department,
    String year,
    String group,
  }) {
    PrefsCalendar values = Data.checkDataValues(
      campus: campus,
      department: department,
      year: year,
      group: group,
    );

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

    return values;
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  set numberWeeks(int numberWeeks) {
    int intValue = (numberWeeks == null || numberWeeks < 1 || numberWeeks > 20)
        ? PrefKey.defaultNumberWeeks
        : numberWeeks;

    setState(() {
      _numberWeeks = intValue;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.numberWeeks, intValue));
  }

  bool get isDarkTheme => _darkTheme ?? PrefKey.defaultDarkTheme;

  set darkTheme(bool darkTheme) {
    setState(() {
      _darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isDarkTheme, darkTheme));
  }

  int get primaryColor => _primaryColor ?? PrefKey.defaultPrimaryColor;

  set primaryColor(int primaryColor) {
    setState(() {
      _primaryColor = primaryColor ?? PrefKey.defaultPrimaryColor;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.primaryColor, primaryColor));
  }

  int get accentColor => _accentColor ?? PrefKey.defaultAccentColor;

  set accentColor(int accentColor) {
    setState(() {
      _accentColor = accentColor ?? PrefKey.defaultAccentColor;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.accentColor, accentColor));
  }

  int get noteColor => _noteColor ?? PrefKey.defaultNoteColor;

  set noteColor(int noteColor) {
    setState(() {
      _noteColor = noteColor ?? PrefKey.defaultNoteColor;
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(PrefKey.noteColor, noteColor));
  }

  bool get isFirstBoot => _firstBoot ?? true;

  set firstBoot(bool firstBoot) {
    setState(() {
      _firstBoot = firstBoot ?? true;
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isFirstBoot, firstBoot));
  }

  String get cachedIcal => _cachedIcal ?? null;

  set cachedIcal(String icalToCache) {
    _cachedIcal = icalToCache ?? null;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(PrefKey.cachedIcal, icalToCache));
  }

  List<Note> get notes =>
      _notes?.where((note) => !note.isExpired())?.toList() ?? [];

  List<Note> notesOfCourse(Course course) {
    return notes.where((note) => note.courseUid == course.uid).toList();
  }

  set notes(List<Note> notes) {
    notes ??= [];
    // Remove expired notes
    notes.removeWhere((note) => note.isExpired());

    setState(() {
      _notes = notes;
    });

    SharedPreferences.getInstance().then((prefs) {
      List<String> notesJSON = [];
      notes.forEach((note) {
        notesJSON.add(json.encode(note.toJson()));
      });

      prefs.setStringList(PrefKey.notes, notesJSON);
    });
  }

  void addNote(Note noteToAdd) {
    if (noteToAdd != null) {
      notes.add(noteToAdd);
      notes = notes;
    }
  }

  void removeNote(Note noteToRemove) {
    if (noteToRemove != null) {
      notes.removeWhere((note) => (note == noteToRemove));
      notes = notes;
    }
  }

  List<CustomCourse> get customEvents =>
      _customEvents?.where((event) => !event.isFinish())?.toList() ?? [];

  set customEvents(List<CustomCourse> events) {
    events ??= [];
    setState(() {
      _notes = notes;
    });

    SharedPreferences.getInstance().then((prefs) {
      List<String> eventsJSON = [];
      events.forEach((event) {
        if (event != null) eventsJSON.add(json.encode(event.toJson()));
      });

      prefs.setStringList(PrefKey.customEvent, eventsJSON);
    });
  }

  void addCustomEvent(CustomCourse eventToAdd) {
    if (eventToAdd != null) {
      customEvents.add(eventToAdd);
      customEvents = customEvents;
    }
  }

  void removeCustomEvent(CustomCourse eventToRemove) {
    customEvents.removeWhere((event) => (event == eventToRemove));
    customEvents = customEvents;
  }

  void editCustomEvent(CustomCourse eventEdited) {
    removeCustomEvent(eventEdited);
    addCustomEvent(eventEdited);
  }

  bool get isUserLogged => _userLogged ?? false;

  set userLogged(bool userLogged) {
    setState(() {
      _userLogged = userLogged ?? false;
    });

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isLogged, _userLogged));
  }

  bool get isHorizontalView => _horizontalView ?? PrefKey.defaultHorizontalView;

  set horizontalView(bool horizontalView) {
    setState(() {
      _horizontalView = horizontalView ?? PrefKey.defaultHorizontalView;
    });

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isHorizontalView, isHorizontalView));
  }

  Map<String, dynamic> get ressources => _ressources ?? {};

  set ressources(Map<String, dynamic> ressources) {
    setState(() {
      _ressources = ressources ?? {};
    });

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setString(PrefKey.ressources, json.encode(ressources)));
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
      if (!note.isExpired()) notes.add(note);
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
}
