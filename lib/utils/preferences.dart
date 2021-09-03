import 'dart:async';
import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/standalone.dart';
import 'package:univagenda/keys/pref_key.dart';
import 'package:univagenda/models/calendar_type.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/models/preferences/prefs_theme.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class _MyInheritedPreferences extends InheritedWidget {
  _MyInheritedPreferences({
    Key? key,
    required Widget child,
    required this.data,
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

  const PreferencesProvider(
      {Key? key, required this.child, required this.prefs})
      : super(key: key);

  @override
  PreferencesProviderState createState() => PreferencesProviderState();

  static PreferencesProviderState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MyInheritedPreferences>()!
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

  /// Url of custom ics file (if user choose "Other" in login page)
  String? _urlIcs;

  /// Number of weeks to display
  int? _numberWeeks;

  /// Show or not courses already passed
  bool? _isPreviousCourses;

  /// App launch counter
  int? _appLaunchCounter;

  /// Is intro already view
  bool? _isIntroDone;

  /// Is the user if logged
  bool? _userLogged;

  /// If agenda is in horizontal mode
  CalendarType? _calendarType;

  /// Display all week days even if no event
  bool? _isDisplayAllDays;

  /// Totally hide hidden courses or display as very small
  bool? _isFullHiddenEvent;

  /// Last courses loaded
  List<Course>? _cachedCourses;

  /// List of notes for events
  List<Note>? _notes;

  /// List of all custom events
  List<CustomCourse>? _customEvents;

  /// List of hidden courses
  List<String>? _hiddenEvents;

  /// List of renamed courses
  Map<String, String>? _renamedEvents;

  /// Last date that the ical cache has ben updated
  DateTime? _cachedIcalDate;

  /// Generate or not a event color
  bool? _isGenerateEventColor;

  /// Callback when preferences changes
  VoidCallback? onPrefsChanges;

  String get urlIcs => _urlIcs ?? PrefKey.defaultUrlIcs;

  setUrlIcs(String? newUrlIcs, [state = false]) {
    if (urlIcs == newUrlIcs) return;

    _updatePref(() => _urlIcs = newUrlIcs, state);
    _setString(PrefKey.urlIcs, _urlIcs);
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  setNumberWeeks(int? newNumberWeeks, [state = false]) {
    if (numberWeeks == newNumberWeeks) return;

    int intValue =
        (newNumberWeeks == null || newNumberWeeks < 1 || newNumberWeeks > 20)
            ? PrefKey.defaultNumberWeeks
            : newNumberWeeks;

    _updatePref(() => _numberWeeks = intValue, state);
    _setInt(PrefKey.numberWeeks, _numberWeeks);
  }

  bool get isPreviousCourses =>
      _isPreviousCourses ?? PrefKey.defaultIsPreviousCourses;

  setShowPreviousCourses(bool? newIsPreviousCourses, [state = false]) {
    if (isPreviousCourses == newIsPreviousCourses) return;

    _updatePref(() => _isPreviousCourses = newIsPreviousCourses, state);
    _setBool(PrefKey.isPreviousCourses, _isPreviousCourses);
  }

  PrefsTheme get theme => _prefsTheme;

  setDarkTheme(bool? darkTheme, [state = false]) {
    if (theme.darkTheme == darkTheme) return;

    _updatePref(() {
      _prefsTheme.darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);
    _setBool(PrefKey.isDarkTheme, _prefsTheme.darkTheme);
  }

  setPrimaryColor(Color? newPrimaryColor, [state = false]) {
    if (theme.primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _prefsTheme.primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);
    _setInt(PrefKey.primaryColor, _prefsTheme.primaryColor.value);
  }

  setAccentColor(Color? newAccentColor, [state = false]) {
    if (theme.accentColor == newAccentColor) return;

    _updatePref(() {
      _prefsTheme.accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);
    _setInt(PrefKey.accentColor, _prefsTheme.accentColor.value);
  }

  setNoteColor(Color? newNoteColor, [state = false]) {
    if (theme.noteColor == newNoteColor) return;

    _updatePref(() {
      _prefsTheme.noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);
    _setInt(PrefKey.noteColor, _prefsTheme.noteColor.value);
  }

  int get appLaunchCounter =>
      _appLaunchCounter ?? PrefKey.defaultAppLaunchCounter;

  setAppLaunchCounter(int? newAppLaunchCounter, [state = false]) {
    if (newAppLaunchCounter == _appLaunchCounter) return;

    _updatePref(() => _appLaunchCounter = newAppLaunchCounter, state);
    _setInt(PrefKey.appLaunchCounter, _appLaunchCounter);
  }

  bool get isIntroDone => _isIntroDone ?? PrefKey.defaultIntroDone;

  setIntroDone(bool? newIntroDone, [state = false]) {
    if (newIntroDone == _isIntroDone) return;

    _updatePref(() => _isIntroDone = newIntroDone, state);
    _setBool(PrefKey.isIntroDone, _isIntroDone);
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

  setNotes(List<Note>? newNotes, [state = false]) {
    _updatePref(() => _notes = newNotes ?? PrefKey.defaultNotes, state);

    final notesJSON = _notes!.map((n) => json.encode(n.toJson())).toList();
    _setStringList(PrefKey.notes, notesJSON);
  }

  void addNote(Note? noteToAdd, [state = false]) {
    if (noteToAdd == null) return;
    setNotes(notes..insert(0, noteToAdd), state);
  }

  void removeNote(Note? noteToRemove, [state = false]) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => note == noteToRemove);

    setNotes(newNotes, state);
  }

  List<CustomCourse> get customEvents =>
      _customEvents ?? PrefKey.defaultCustomEvents;

  setCustomEvents(List<CustomCourse?>? newCustomEvents, [state = false]) {
    _updatePref(() {
      _customEvents = (newCustomEvents ??= PrefKey.defaultCustomEvents)
          .whereNotNull()
          .toList();
      _customEvents!.removeWhere((e) => e.isFinish() && !e.isRecurrentEvent());
    }, state);

    List<String> eventsJSON =
        _customEvents!.map((event) => json.encode(event.toJson())).toList();
    _setStringList(PrefKey.customEvent, eventsJSON);
  }

  void addCustomEvent(CustomCourse? eventToAdd, [state = false]) {
    if (eventToAdd == null) return;

    if (eventToAdd.syncCalendar != null) {
      final eventToCreate = Event(
        eventToAdd.syncCalendar!.id,
        eventId: eventToAdd.uid,
        title: eventToAdd.title,
        description: eventToAdd.description,
        start: TZDateTime.fromMillisecondsSinceEpoch(
          getLocation('UTC'),
          eventToAdd.dateStart.toUtc().millisecondsSinceEpoch,
        ),
        end: TZDateTime.fromMillisecondsSinceEpoch(
          getLocation('UTC'),
          eventToAdd.dateEnd.toUtc().millisecondsSinceEpoch,
        ),
        availability: Availability.Free,
      );

      DeviceCalendarPlugin().createOrUpdateEvent(eventToCreate).then((result) {
        if (result != null && result.isSuccess && result.data != null)
          eventToAdd.uid = result.data!;
      });
    }

    setCustomEvents(customEvents..add(eventToAdd), state);
  }

  void removeCustomEvent(
    CustomCourse? eventToRemove, [
    state = false,
    syncCalendar = true,
  ]) {
    if (eventToRemove == null) return;

    if (syncCalendar && eventToRemove.syncCalendar != null) {
      DeviceCalendarPlugin()
          .deleteEvent(eventToRemove.syncCalendar!.id, eventToRemove.uid);
    }

    List<CustomCourse> newEvents = customEvents;
    newEvents.removeWhere((event) => (event.uid == eventToRemove.uid));

    setCustomEvents(newEvents, state);
  }

  void editCustomEvent(CustomCourse? eventEdited, [state = false]) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited, state, false);
    addCustomEvent(eventEdited, state);
  }

  bool get isUserLogged => _userLogged ?? PrefKey.defaultUserLogged;

  setUserLogged(bool? userLogged, [state = false]) {
    if (isUserLogged == userLogged) return;

    _updatePref(() {
      _userLogged = userLogged ?? PrefKey.defaultUserLogged;
    }, state);
    _setBool(PrefKey.isUserLogged, _userLogged!);
  }

  CalendarType get calendarType => _calendarType ?? PrefKey.defaultCalendarType;

  setCalendarType(CalendarType? newCalendarType, [state = false]) {
    if (calendarType == newCalendarType) return;

    _updatePref(() {
      _calendarType = newCalendarType ?? PrefKey.defaultCalendarType;
    }, state);
    _setString(PrefKey.calendarType, _calendarType.toString());
  }

  bool get isDisplayAllDays =>
      _isDisplayAllDays ?? PrefKey.defaultDisplayAllDays;

  setDisplayAllDays(bool? displayAllDays, [state = false]) {
    if (isDisplayAllDays == displayAllDays) return;

    _updatePref(() {
      _isDisplayAllDays = displayAllDays ?? PrefKey.defaultDisplayAllDays;
    }, state);
    _setBool(PrefKey.isDisplayAllDays, _isDisplayAllDays);
  }

  DateTime get cachedIcalDate => _cachedIcalDate ?? DateTime(2000);

  setCachedIcalDate([DateTime? newCachedIcalDate, state = false]) {
    _updatePref(() => _cachedIcalDate = newCachedIcalDate, state);
    _setString(PrefKey.cachedIcalDate, _cachedIcalDate?.toIso8601String());
  }

  List<String> get hiddenEvents => _hiddenEvents ?? PrefKey.defaultHiddenEvents;

  setHiddenEvents(List<String>? newHiddenEvents, [state = false]) {
    _updatePref(() {
      _hiddenEvents =
          newHiddenEvents?.toSet().toList() ?? PrefKey.defaultHiddenEvents;
    }, state);
    _setStringList(PrefKey.hiddenEvent, _hiddenEvents);
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

  setRenamedEvents(Map<String, String>? newRenamedEvents, [state = false]) {
    _updatePref(() {
      _renamedEvents = newRenamedEvents ?? PrefKey.defaultRenamedEvent;
    }, state);
    _setString(PrefKey.renamedEvent, json.encode(_renamedEvents));
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

  setFullHiddenEvent(bool? fullHiddenEvent, [state = false]) {
    if (isFullHiddenEvent == fullHiddenEvent) return;

    _updatePref(() {
      _isFullHiddenEvent = fullHiddenEvent ?? PrefKey.defaultFullHiddenEvent;
    }, state);
    _setBool(PrefKey.isFullHiddenEvents, _isFullHiddenEvent);
  }

  disconnectUser([state = false]) {
    setUserLogged(false);
    setUrlIcs(null);
    setCachedCourses(PrefKey.defaultCachedCourses);
  }

  bool get isGenerateEventColor =>
      _isGenerateEventColor ?? PrefKey.defaultGenerateEventColor;

  setGenerateEventColor(bool? isEventColor, [state = false]) {
    if (isGenerateEventColor == isEventColor) return;

    _updatePref(() {
      _isGenerateEventColor = isEventColor ?? PrefKey.defaultGenerateEventColor;
    }, state);
    _setBool(PrefKey.isGenerateEventColor, _isGenerateEventColor);
  }

  Future<void> initFromDisk(BuildContext context, [state = false]) async {
    await initResAndGroup();

    String? cachedIcalDate = widget.prefs.getString(PrefKey.cachedIcalDate);
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
    List<String>? hiddenEvents =
        widget.prefs.getStringList(PrefKey.hiddenEvent);
    setHiddenEvents(hiddenEvents ?? []);

    // Renamed events
    Map<String, dynamic> renamedEvents = json.decode(
      widget.prefs.getString(PrefKey.renamedEvent) ?? "{}",
    );
    setRenamedEvents(renamedEvents.cast<String, String>());

    List<String>? eventsStr = widget.prefs.getStringList(PrefKey.customEvent);
    List<CustomCourse> actualEvents = (eventsStr ?? []).map((eventStr) {
      Map<String, dynamic> eventJson = json.decode(eventStr);
      return CustomCourse.fromJson(eventJson);
    }).toList();

    // Set update state true/false on last to force rebuild
    setCustomEvents(actualEvents, state);
  }

  Future<void> initResAndGroup() async {
    // If user choose custom url ics, not init other group prefs
    String? urlIcs = widget.prefs.getString(PrefKey.urlIcs);
    if (urlIcs != null) {
      setUrlIcs(urlIcs);
    }
  }

  void _updatePref(VoidCallback f, bool state) {
    if (state) {
      setState(f);
      if (onPrefsChanges != null) onPrefsChanges!();
    } else {
      f();
    }
  }

  void forceSetState() {
    setState(() {
      // nothing, just force to rebuild
    });
  }

  void _setString(String prefKey, String? value) {
    if (value == null) {
      widget.prefs.remove(prefKey);
    } else {
      widget.prefs.setString(prefKey, value);
    }
  }

  void _setStringList(String prefKey, List<String>? value) {
    if (value == null) {
      widget.prefs.remove(prefKey);
    } else {
      widget.prefs.setStringList(prefKey, value);
    }
  }

  void _setInt(String prefKey, int? value) {
    if (value == null) {
      widget.prefs.remove(prefKey);
    } else {
      widget.prefs.setInt(prefKey, value);
    }
  }

  void _setBool(String prefKey, bool? value) {
    if (value == null) {
      widget.prefs.remove(prefKey);
    } else {
      widget.prefs.setBool(prefKey, value);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is PreferencesProviderState &&
      theme != other.theme &&
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
      cachedIcalDate != other.cachedIcalDate &&
      isGenerateEventColor != other.isGenerateEventColor;

  @override
  int get hashCode =>
      theme.hashCode ^
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
      cachedIcalDate.hashCode ^
      isGenerateEventColor.hashCode;
}
