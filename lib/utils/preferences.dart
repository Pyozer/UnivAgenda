import 'dart:async';
import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/calendar_type.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/courses/note.dart';
import 'package:myagenda/models/preferences/prefs_theme.dart';
import 'package:myagenda/models/preferences/university.dart';
import 'package:myagenda/utils/functions.dart';
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
    return data != oldWidget.data;
  }
}

class PreferencesProvider extends StatefulWidget {
  final Widget child;
  final SharedPreferences prefs;

  const PreferencesProvider({Key key, this.child, @required this.prefs})
      : super(key: key);

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

  /// Agenda preferences (list of group keys)
  List<String> _prefsGroupKeys = [];

  /// Url of custom ics file (if user choose "Other" in login page)
  String _urlIcs;

  /// Number of weeks to display
  int _numberWeeks;

  /// Show or not courses already passed
  bool _isPreviousCourses;

  /// App launch counter
  int _appLaunchCounter;

  /// Is intro already view
  bool _isIntroDone;

  /// Is the user if logged
  bool _userLogged;

  /// If agenda is in horizontal mode
  CalendarType _calendarType;

  /// Display all week days even if no event
  bool _isDisplayAllDays;

  /// Totally hide hidden courses or display as very small
  bool _isFullHiddenEvent;

  /// Last courses loaded
  List<Course> _cachedCourses;

  /// List of notes for events
  List<Note> _notes;

  /// List of all custom events
  List<CustomCourse> _customEvents;

  /// List of hidden courses
  List<String> _hiddenEvents;

  /// List of renamed courses
  Map<String, String> _renamedEvents;

  /// Resources (contain all agenda with their ID)
  Map<String, dynamic> _resources;

  /// Last date that the resources has ben updated
  DateTime _resourcesDate;

  /// Last date that the ical cache has ben updated
  DateTime _cachedIcalDate;

  /// Generate or not a event color
  bool _isGenerateEventColor;

  /// Callback when preferences changes
  VoidCallback onPrefsChanges;

  List<String> getAllUniversity() {
    return _listUniversity?.map((univ) => univ.university)?.toList() ?? [];
  }

  University findUniversity(String university) {
    return listUniversity.firstWhere(
      (univ) => univ.university == university,
      orElse: () => null,
    );
  }

  List<String> get groupKeys => _prefsGroupKeys;

  setGroupKeys(List<String> newGroupKeys, [state = false]) {
    // Check if values are correct together
    List<String> checkedGroupKeys = checkDataValues(newGroupKeys);

    if (checkedGroupKeys == groupKeys) return;

    _updatePref(() => _prefsGroupKeys = checkedGroupKeys, state);

    widget.prefs.setStringList(PrefKey.groupKeys, checkedGroupKeys);
  }

  List<List<String>> getAllGroupKeys(List<String> groupKeys) {
    List<List<String>> allGroupKeys = [];

    dynamic resources = _resources;
    groupKeys.forEach((key) {
      if (!(resources is int)) {
        allGroupKeys.add(resources.keys.toList());
        resources = resources[key];
      }
    });
    return allGroupKeys;
  }

  int getGroupResID() {
    dynamic resources = _resources;

    groupKeys.forEach((key) {
      resources = resources[key];
    });
    return resources as int;
  }

  List<String> checkDataValues(List<String> groupKeys) {
    groupKeys ??= [];
    List<String> checkedGroupKeys = [];

    dynamic resources = _resources;

    String key;
    int level = 0;
    while (!(resources is int) && resources.keys.isNotEmpty) {
      if (level < groupKeys.length && resources.containsKey(groupKeys[level]))
        key = groupKeys[level];
      else
        key = resources.keys.first;

      resources = resources[key];
      checkedGroupKeys.add(key);
      level++;
    }

    return checkedGroupKeys;
  }

  String get urlIcs => _urlIcs ?? PrefKey.defaultUrlIcs;

  setUrlIcs(String newUrlIcs, [state = false]) {
    if (urlIcs == newUrlIcs) return;

    _updatePref(() => _urlIcs = newUrlIcs, state);

    widget.prefs.setString(PrefKey.urlIcs, _urlIcs);
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  setNumberWeeks(int newNumberWeeks, [state = false]) {
    if (numberWeeks == newNumberWeeks) return;

    int intValue =
        (newNumberWeeks == null || newNumberWeeks < 1 || newNumberWeeks > 20)
            ? PrefKey.defaultNumberWeeks
            : newNumberWeeks;

    _updatePref(() => _numberWeeks = intValue, state);

    widget.prefs.setInt(PrefKey.numberWeeks, _numberWeeks);
  }

  bool get isPreviousCourses =>
      _isPreviousCourses ?? PrefKey.defaultIsPreviousCourses;

  setShowPreviousCourses(bool newIsPreviousCourses, [state = false]) {
    if (isPreviousCourses == newIsPreviousCourses) return;

    _updatePref(() => _isPreviousCourses = newIsPreviousCourses, state);

    widget.prefs.setBool(PrefKey.isPreviousCourses, _isPreviousCourses);
  }

  PrefsTheme get theme => _prefsTheme;

  setDarkTheme(bool darkTheme, [state = false]) {
    if (theme.darkTheme == darkTheme) return;

    _updatePref(() {
      _prefsTheme.darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);

    widget.prefs.setBool(PrefKey.isDarkTheme, _prefsTheme.darkTheme);
  }

  setPrimaryColor(Color newPrimaryColor, [state = false]) {
    if (theme.primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _prefsTheme.primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);

    widget.prefs.setInt(PrefKey.primaryColor, _prefsTheme.primaryColor.value);
  }

  setAccentColor(Color newAccentColor, [state = false]) {
    if (theme.accentColor == newAccentColor) return;

    _updatePref(() {
      _prefsTheme.accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);

    widget.prefs.setInt(PrefKey.accentColor, _prefsTheme.accentColor.value);
  }

  setNoteColor(Color newNoteColor, [state = false]) {
    if (theme.noteColor == newNoteColor) return;

    _updatePref(() {
      _prefsTheme.noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);

    widget.prefs.setInt(PrefKey.noteColor, _prefsTheme.noteColor.value);
  }

  int get appLaunchCounter =>
      _appLaunchCounter ?? PrefKey.defaultAppLaunchCounter;

  setAppLaunchCounter(int newAppLaunchCounter, [state = false]) {
    if (newAppLaunchCounter == _appLaunchCounter) return;

    _updatePref(() => _appLaunchCounter = newAppLaunchCounter, state);

    widget.prefs.setInt(PrefKey.appLaunchCounter, _appLaunchCounter);
  }

  bool get isIntroDone => _isIntroDone ?? PrefKey.defaultIntroDone;

  setIntroDone(bool newIntroDone, [state = false]) {
    if (newIntroDone == _isIntroDone) return;

    _updatePref(() => _isIntroDone = newIntroDone, state);

    widget.prefs.setBool(PrefKey.isIntroDone, _isIntroDone);
  }

  List<Course> get cachedCourses =>
      _cachedCourses ?? PrefKey.defaultCachedCourses;

  setCachedCourses(List<Course> coursesToCache, [state = false]) {
    if (cachedCourses == coursesToCache) return;

    _updatePref(() => _cachedCourses = coursesToCache, state);

    writeFile(
      PrefKey.cachedCoursesFile,
      json.encode(List.from(coursesToCache.map((x) => x.toJson()))),
    );
    setCachedIcalDate(); // Set ical last update date to now
  }

  List<Note> get notes => _notes ?? PrefKey.defaultNotes;

  setNotes(List<Note> newNotes, [state = false]) {
    _updatePref(() => _notes = newNotes ?? PrefKey.defaultNotes, state);

    final notesJSON = _notes.map((n) => json.encode(n.toJson())).toList();
    widget.prefs.setStringList(PrefKey.notes, notesJSON);
  }

  void addNote(Note noteToAdd, [state = false]) {
    if (noteToAdd == null) return;
    setNotes(notes..insert(0, noteToAdd), state);
  }

  void removeNote(Note noteToRemove, [state = false]) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => note == noteToRemove);

    setNotes(newNotes, state);
  }

  List<CustomCourse> get customEvents =>
      _customEvents ?? PrefKey.defaultCustomEvents;

  setCustomEvents(List<CustomCourse> newCustomEvents, [state = false]) {
    newCustomEvents ??= PrefKey.defaultCustomEvents;
    newCustomEvents.removeWhere((e) => e.isFinish() && !e.isRecurrentEvent());

    _updatePref(() => _customEvents = newCustomEvents, state);

    List<String> eventsJSON = [];
    _customEvents.forEach((event) {
      if (event != null) eventsJSON.add(json.encode(event.toJson()));
    });
    widget.prefs.setStringList(PrefKey.customEvent, eventsJSON);
  }

  void addCustomEvent(CustomCourse eventToAdd, [state = false]) {
    if (eventToAdd == null) return;

    if (eventToAdd.syncCalendar != null) {
      final eventToCreate = Event(
        eventToAdd.syncCalendar.id,
        eventId: eventToAdd.uid,
        title: eventToAdd.title,
        description: eventToAdd.description,
        start: eventToAdd.dateStart,
        end: eventToAdd.dateEnd,
      );

      DeviceCalendarPlugin().createOrUpdateEvent(eventToCreate).then((result) {
        if (result.isSuccess && result.data != null)
          eventToAdd.uid = result.data;
      });
    }

    setCustomEvents(customEvents..add(eventToAdd), state);
  }

  void removeCustomEvent(CustomCourse eventToRemove,
      [state = false, syncCalendar = true]) {
    if (eventToRemove == null) return;

    if (syncCalendar && eventToRemove.syncCalendar != null) {
      DeviceCalendarPlugin()
          .deleteEvent(eventToRemove.syncCalendar.id, eventToRemove.uid);
    }

    List<CustomCourse> newEvents = customEvents;
    newEvents.removeWhere((event) => (event.uid == eventToRemove.uid));

    setCustomEvents(newEvents, state);
  }

  void editCustomEvent(CustomCourse eventEdited, [state = false]) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited, state, false);
    addCustomEvent(eventEdited, state);
  }

  bool get isUserLogged => _userLogged ?? PrefKey.defaultUserLogged;

  setUserLogged(bool userLogged, [state = false]) {
    if (isUserLogged == userLogged) return;

    _updatePref(() {
      _userLogged = userLogged ?? PrefKey.defaultUserLogged;
    }, state);

    widget.prefs.setBool(PrefKey.isUserLogged, _userLogged);
  }

  CalendarType get calendarType => _calendarType ?? PrefKey.defaultCalendarType;

  setCalendarType(CalendarType newCalendarType, [state = false]) {
    if (calendarType == newCalendarType) return;

    _updatePref(() {
      _calendarType = newCalendarType ?? PrefKey.defaultCalendarType;
    }, state);

    widget.prefs.setString(PrefKey.calendarType, _calendarType.toString());
  }

  bool get isDisplayAllDays =>
      _isDisplayAllDays ?? PrefKey.defaultDisplayAllDays;

  setDisplayAllDays(bool displayAllDays, [state = false]) {
    if (isDisplayAllDays == displayAllDays) return;

    _updatePref(() {
      _isDisplayAllDays = displayAllDays ?? PrefKey.defaultDisplayAllDays;
    }, state);

    widget.prefs.setBool(PrefKey.isDisplayAllDays, _isDisplayAllDays);
  }

  List<University> get listUniversity =>
      _listUniversity ?? PrefKey.defaultListUniversity;

  setListUniversity(List<University> listUniv, [state = false]) {
    if (listUniversity == listUniv) return;

    _updatePref(() {
      _listUniversity = listUniv ?? PrefKey.defaultListUniversity;
    }, state);

    writeFile(PrefKey.listUniversityFile, json.encode(listUniv));
  }

  University get university => _university;

  setUniversity(String newUniversity, [state = false]) {
    if ((university?.university ?? "") == newUniversity) return;

    if (listUniversity.isNotEmpty) {
      final univ = findUniversity(newUniversity);
      _updatePref(() => _university = univ ?? _listUniversity[0], state);

      widget.prefs.setString(PrefKey.university, _university.university);
    }
  }

  Map<String, dynamic> get resources => _resources ?? PrefKey.defaultResources;

  void setResources(Map<String, dynamic> newResources, [state = false]) {
    if (resources == newResources) return;

    _updatePref(() {
      _resources = newResources ?? PrefKey.defaultResources;
    }, state);

    // Check actual calendar prefs with new resources
    if (_resources.isNotEmpty) setGroupKeys(groupKeys, state);
    // Update cache file
    writeFile(PrefKey.resourcesFile, json.encode(newResources));
  }

  DateTime get resourcesDate => _resourcesDate ?? DateTime(2000);

  setResourcesDate([DateTime newResDate, state = false]) {
    _updatePref(() => _resourcesDate = newResDate, state);

    widget.prefs.setString(
      PrefKey.resourcesDate,
      _resourcesDate?.toIso8601String(),
    );
  }

  DateTime get cachedIcalDate => _cachedIcalDate ?? DateTime(2000);

  setCachedIcalDate([DateTime newCachedIcalDate, state = false]) {
    _updatePref(() => _cachedIcalDate = newCachedIcalDate, state);

    widget.prefs.setString(
      PrefKey.cachedIcalDate,
      _cachedIcalDate?.toIso8601String(),
    );
  }

  List<String> get hiddenEvents => _hiddenEvents ?? PrefKey.defaultHiddenEvents;

  setHiddenEvents(List<String> newHiddenEvents, [state = false]) {
    _updatePref(() {
      _hiddenEvents =
          newHiddenEvents?.toSet()?.toList() ?? PrefKey.defaultHiddenEvents;
    }, state);

    widget.prefs.setStringList(PrefKey.hiddenEvent, _hiddenEvents);
  }

  void addHiddenEvent(String title, [bool state = false]) {
    hiddenEvents.add(title);
    setHiddenEvents(hiddenEvents, state);
  }

  void removeHiddenEvent(String title, [bool state = false]) {
    hiddenEvents.remove(title);
    setHiddenEvents(hiddenEvents, state);
  }

  Map<String, String> get renamedEvents =>
      _renamedEvents ?? PrefKey.defaultRenamedEvent;

  setRenamedEvents(Map<String, String> newRenamedEvents, [state = false]) {
    _updatePref(() {
      _renamedEvents = newRenamedEvents ?? PrefKey.defaultRenamedEvent;
    }, state);

    widget.prefs.setString(PrefKey.renamedEvent, json.encode(_renamedEvents));
  }

  void addRenamedEvent(String eventTitle, String newTitle,
      [bool state = false]) {
    renamedEvents[eventTitle] = newTitle;
    setRenamedEvents(renamedEvents, state);
  }

  void removeRenamedEvent(String eventTitle, [bool state = false]) {
    renamedEvents.remove(eventTitle);
    setRenamedEvents(renamedEvents, state);
  }

  bool isCourseHidden(Course course) =>
      hiddenEvents.any((e) => e == course.title);

  bool get isFullHiddenEvent =>
      _isFullHiddenEvent ?? PrefKey.defaultFullHiddenEvent;

  setFullHiddenEvent(bool fullHiddenEvent, [state = false]) {
    if (isFullHiddenEvent == fullHiddenEvent) return;

    _updatePref(() {
      _isFullHiddenEvent = fullHiddenEvent ?? PrefKey.defaultFullHiddenEvent;
    }, state);

    widget.prefs.setBool(PrefKey.isFullHiddenEvents, _isFullHiddenEvent);
  }

  disconnectUser([state = false]) {
    setUserLogged(false);
    setUrlIcs(null);
    setResources(PrefKey.defaultResources);
    setCachedCourses(PrefKey.defaultCachedCourses);
  }

  bool get isGenerateEventColor =>
      _isGenerateEventColor ?? PrefKey.defaultGenerateEventColor;

  setGenerateEventColor(bool isEventColor, [state = false]) {
    if (isGenerateEventColor == isEventColor) return;

    _updatePref(() {
      _isGenerateEventColor = isEventColor ?? PrefKey.defaultGenerateEventColor;
    }, state);

    widget.prefs.setBool(PrefKey.isGenerateEventColor, _isGenerateEventColor);
  }

  Future<void> initFromDisk(BuildContext context, [state = false]) async {
    await initResAndGroup();

    String resourcesDate = widget.prefs.getString(PrefKey.resourcesDate);
    if (resourcesDate != null) setResourcesDate(DateTime.parse(resourcesDate));

    String cachedIcalDate = widget.prefs.getString(PrefKey.cachedIcalDate);
    if (cachedIcalDate != null)
      setCachedIcalDate(DateTime.parse(cachedIcalDate));

    // Init number of weeks to display
    setNumberWeeks(widget.prefs.getInt(PrefKey.numberWeeks));

    // Init display or not of previous courses
    setShowPreviousCourses(widget.prefs.getBool(PrefKey.isPreviousCourses));

    // Init theme preferences
    setCalendarType(
      calendarTypeFromStr(widget.prefs.getString(PrefKey.calendarType)),
    );
    final isDarkTheme = widget.prefs.getBool(PrefKey.isDarkTheme);
    final deviceBrightness = MediaQuery.of(context).platformBrightness;
    setDarkTheme(isDarkTheme ?? deviceBrightness == Brightness.dark);

    final primaryColorValue = widget.prefs.getInt(PrefKey.primaryColor);
    if (primaryColorValue != null) setPrimaryColor(Color(primaryColorValue));

    final accentColorValue = widget.prefs.getInt(PrefKey.accentColor);
    if (accentColorValue != null) setAccentColor(Color(accentColorValue));

    final noteColorValue = widget.prefs.getInt(PrefKey.noteColor);
    if (noteColorValue != null) setNoteColor(Color(noteColorValue));

    // Init other prefs
    try {
      String cachedCourses = await readFile(PrefKey.cachedCoursesFile, '[]');
      cachedCourses = cachedCourses.trim();
      if (!cachedCourses.startsWith('[') || !cachedCourses.endsWith(']')) {
        cachedCourses = '[]';
      }
      final coursesJson = json.decode(cachedCourses);
      setCachedCourses(
        List<Course>.from(coursesJson.map((x) => Course.fromJson(x))),
      );
    } catch (_) {}
    setUserLogged(widget.prefs.getBool(PrefKey.isUserLogged));
    setAppLaunchCounter(widget.prefs.getInt(PrefKey.appLaunchCounter));
    setIntroDone(widget.prefs.getBool(PrefKey.isIntroDone));
    setDisplayAllDays(widget.prefs.getBool(PrefKey.isDisplayAllDays));
    setGenerateEventColor(widget.prefs.getBool(PrefKey.isGenerateEventColor));
    setFullHiddenEvent(widget.prefs.getBool(PrefKey.isFullHiddenEvents));

    // Init saved notes
    List<String> notesStr = widget.prefs.getStringList(PrefKey.notes) ?? [];
    List<Note> actualNotes = notesStr.map((n) => Note.fromJsonStr(n)).toList();
    setNotes(actualNotes);

    // Init hidden courses
    List<String> hiddenEvents = widget.prefs.getStringList(PrefKey.hiddenEvent);
    setHiddenEvents(hiddenEvents ?? []);

    // Renamed events
    Map<String, dynamic> renamedEvents = json.decode(
      widget.prefs.getString(PrefKey.renamedEvent) ?? "{}",
    );
    setRenamedEvents(renamedEvents.cast<String, String>());

    List<String> eventsStr = widget.prefs.getStringList(PrefKey.customEvent);
    List<CustomCourse> actualEvents = (eventsStr ?? []).map((eventStr) {
      Map<String, dynamic> eventJson = json.decode(eventStr);
      return CustomCourse.fromJson(eventJson);
    }).toList();

    // Set update state true/false on last to force rebuild
    setCustomEvents(actualEvents, state);
  }

  Future<void> initResAndGroup() async {
    // Init list university stored values
    String listUnivStored = await readFile(
      PrefKey.listUniversityFile,
      PrefKey.defaultListUniversityJson,
    );
    List listUnivJson = json.decode(listUnivStored);
    setListUniversity(listUnivJson.map((m) => University.fromJson(m)).toList());

    // If user choose custom url ics, not init other group prefs
    String urlIcs = widget.prefs.getString(PrefKey.urlIcs);
    if (urlIcs != null) {
      setUrlIcs(urlIcs);
      return null;
    }

    // If list of university is not empty
    if (listUniversity.isNotEmpty) {
      String storedUniversityName = widget.prefs.getString(PrefKey.university);

      // If no university store
      if (storedUniversityName == null || storedUniversityName.isEmpty) {
        // Take first university of list
        storedUniversityName = listUniversity[0].university;
      }
      setUniversity(storedUniversityName);

      // Parse local resources to Map
      String storedResourcesStr = await readFile(PrefKey.resourcesFile, '{}');
      storedResourcesStr..trim();

      // If local resources aren't empty
      if (storedResourcesStr.isNotEmpty) {
        // Init group preferences
        final groupKeys = widget.prefs.getStringList(PrefKey.groupKeys);
        // Update
        setResources(json.decode(storedResourcesStr));
        // Check values and resave group prefs (useful if issue)
        setGroupKeys(groupKeys);
      }
    }
    return null;
  }

  void _updatePref(Function f, bool state) {
    if (state) {
      setState(f);
      if (onPrefsChanges != null) onPrefsChanges();
    } else {
      f();
    }
  }

  void forceSetState() {
    setState(() {
      // nothing, just force to rebuild
    });
  }

  @override
  bool operator ==(Object other) =>
      other is PreferencesProviderState &&
      theme != other.theme &&
      listEqualsNotOrdered(listUniversity, other.listUniversity) &&
      university != other.university &&
      listEqualsNotOrdered(groupKeys, other.groupKeys) &&
      urlIcs != other.urlIcs &&
      numberWeeks != other.numberWeeks &&
      isPreviousCourses != other.isPreviousCourses &&
      appLaunchCounter != other.appLaunchCounter &&
      isIntroDone != other.isIntroDone &&
      isUserLogged != other.isUserLogged &&
      calendarType != other.calendarType &&
      isDisplayAllDays != other.isDisplayAllDays &&
      isFullHiddenEvent != other.isFullHiddenEvent &&
      listEqualsNotOrdered(cachedCourses, other.cachedCourses) &&
      listEqualsNotOrdered(notes, other.notes) &&
      listEqualsNotOrdered(customEvents, other.customEvents) &&
      listEqualsNotOrdered(hiddenEvents, other.hiddenEvents) &&
      renamedEvents == other.renamedEvents &&
      resources != other.resources &&
      resourcesDate != other.resourcesDate &&
      cachedIcalDate != other.cachedIcalDate &&
      isGenerateEventColor != other.isGenerateEventColor;

  @override
  int get hashCode =>
      theme.hashCode ^
      hashList(listUniversity) ^
      university.hashCode ^
      hashList(groupKeys) ^
      urlIcs.hashCode ^
      numberWeeks.hashCode ^
      isPreviousCourses.hashCode ^
      appLaunchCounter.hashCode ^
      isIntroDone.hashCode ^
      isUserLogged.hashCode ^
      calendarType.hashCode ^
      isDisplayAllDays.hashCode ^
      isFullHiddenEvent.hashCode ^
      hashList(cachedCourses) ^
      hashList(notes) ^
      hashList(customEvents) ^
      hashList(hiddenEvents) ^
      renamedEvents.hashCode ^
      resources.hashCode ^
      resourcesDate.hashCode ^
      cachedIcalDate.hashCode ^
      isGenerateEventColor.hashCode;
}
