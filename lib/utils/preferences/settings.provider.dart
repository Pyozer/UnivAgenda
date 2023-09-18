import 'dart:async';
import 'dart:convert';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:collection/collection.dart';

import '../../keys/pref_key.dart';
import '../../models/calendar_type.dart';
import '../../models/courses/course.dart';
import '../../models/courses/custom_course.dart';
import '../../models/courses/note.dart';
import '../functions.dart';
import 'base.provider.dart';
import '../../models/courses/hidden.dart';

class SettingsProvider extends BaseProvider {
  ///
  /// Singleton Factory
  ///
  static final instance = SettingsProvider._internal();
  SettingsProvider._internal();

  /// Urls of custom ics file
  List<String>? _urlIcs;

  /// Number of weeks to display
  int? _numberWeeks;

  /// Show or not courses already passed
  bool? _isPreviousCourses;

  /// App launch counter
  int? _appLaunchCounter;

  /// Is intro already view
  bool? _isIntroDone;

  /// If agenda is in horizontal mode
  CalendarView? _calendarType;

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
  List<Hidden>? _hiddenEvents;

  /// List of renamed courses
  Map<String, String>? _renamedEvents;

  /// Last date that the ical cache has ben updated
  DateTime? _cachedIcalDate;

  /// Generate or not a event color
  bool? _isGenerateEventColor;

  List<String> get urlIcs => _urlIcs ?? PrefKey.defaultUrlIcs;

  void setUrlIcs(List<String> newUrlIcs, [bool state = false]) {
    if (urlIcs == newUrlIcs) return;

    updatePref(() => _urlIcs = newUrlIcs, state);
    setStringList(PrefKey.urlIcs, _urlIcs);
  }

  void addUrlIcs(String newUrlIcs, [bool state = false]) {
    setUrlIcs([...urlIcs, newUrlIcs], state);
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  void setNumberWeeks(int? newNumberWeeks, [bool state = false]) {
    if (numberWeeks == newNumberWeeks) return;

    int intValue =
        (newNumberWeeks == null || newNumberWeeks < 1 || newNumberWeeks > 20)
            ? PrefKey.defaultNumberWeeks
            : newNumberWeeks;

    updatePref(() => _numberWeeks = intValue, state);
    setInt(PrefKey.numberWeeks, _numberWeeks);
  }

  bool get isPreviousCourses =>
      _isPreviousCourses ?? PrefKey.defaultIsPreviousCourses;

  void setShowPreviousCourses(bool? newIsPreviousCourses,
      [bool state = false]) {
    if (isPreviousCourses == newIsPreviousCourses) return;

    updatePref(() => _isPreviousCourses = newIsPreviousCourses, state);
    setBool(PrefKey.isPreviousCourses, _isPreviousCourses);
  }

  int get appLaunchCounter =>
      _appLaunchCounter ?? PrefKey.defaultAppLaunchCounter;

  void setAppLaunchCounter(int? newAppLaunchCounter, [bool state = false]) {
    if (newAppLaunchCounter == _appLaunchCounter) return;

    updatePref(() => _appLaunchCounter = newAppLaunchCounter, state);
    setInt(PrefKey.appLaunchCounter, _appLaunchCounter);
  }

  void incrementAppLaunchCounter([bool state = false]) {
    setAppLaunchCounter(appLaunchCounter + 1, state);
  }

  bool get isIntroDone => _isIntroDone ?? PrefKey.defaultIntroDone;

  void setIntroDone(bool? newIntroDone, [bool state = false]) {
    if (newIntroDone == _isIntroDone) return;

    updatePref(() => _isIntroDone = newIntroDone, state);
    setBool(PrefKey.isIntroDone, _isIntroDone);
  }

  List<Course> get cachedCourses =>
      _cachedCourses ?? PrefKey.defaultCachedCourses;

  void setCachedCourses(List<Course> coursesToCache, [bool state = false]) {
    if (cachedCourses == coursesToCache) return;

    updatePref(() => _cachedCourses = coursesToCache, state);

    writeFile(
      PrefKey.cachedCoursesFile,
      json.encode(List.from(coursesToCache.map((x) => x.toJson()))),
    );
    setCachedIcalDate(); // Set ical last update date to now
  }

  List<Note> get notes => _notes ?? PrefKey.defaultNotes;

  void setNotes(List<Note>? newNotes, [bool state = false]) {
    updatePref(() => _notes = newNotes ?? PrefKey.defaultNotes, state);
    final notesJSON = _notes!.map((n) => json.encode(n.toJson())).toList();
    setStringList(PrefKey.notes, notesJSON);
  }

  void addNote(Note? noteToAdd, [bool state = false]) {
    if (noteToAdd == null) return;
    setNotes(notes..insert(0, noteToAdd), state);
  }

  void removeNote(Note? noteToRemove, [bool state = false]) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => note == noteToRemove);

    setNotes(newNotes, state);
  }

  List<CustomCourse> get customEvents =>
      _customEvents ?? PrefKey.defaultCustomEvents;

  void setCustomEvents(List<CustomCourse?>? newCustomEvents,
      [bool state = false]) {
    updatePref(() {
      _customEvents = (newCustomEvents ??= PrefKey.defaultCustomEvents)
          .whereNotNull()
          .toList();
      _customEvents!.removeWhere((e) => e.isFinish() && !e.isRecurrentEvent());
    }, state);

    List<String> eventsJSON =
        _customEvents!.map((event) => json.encode(event.toJson())).toList();
    setStringList(PrefKey.customEvent, eventsJSON);
  }

  void addCustomEvent(CustomCourse? eventToAdd, [bool state = false]) {
    if (eventToAdd == null) return;

    setCustomEvents(customEvents..add(eventToAdd), state);
  }

  void removeCustomEvent(
    CustomCourse? eventToRemove, [
    state = false,
    syncCalendar = true,
  ]) {
    if (eventToRemove == null) return;

    List<CustomCourse> newEvents = customEvents;
    newEvents.removeWhere((event) => (event.uid == eventToRemove.uid));

    setCustomEvents(newEvents, state);
  }

  void editCustomEvent(CustomCourse? eventEdited, [bool state = false]) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited, state, false);
    addCustomEvent(eventEdited, state);
  }

  CalendarView get calendarType => _calendarType ?? PrefKey.defaultCalendarType;

  void setCalendarType(CalendarView? newCalendarType, [bool state = false]) {
    if (calendarType == newCalendarType) return;

    updatePref(() {
      _calendarType = newCalendarType ?? PrefKey.defaultCalendarType;
    }, state);
    setString(PrefKey.calendarType, _calendarType.toString());
  }

  bool get isDisplayAllDays =>
      _isDisplayAllDays ?? PrefKey.defaultDisplayAllDays;

  void setDisplayAllDays(bool? displayAllDays, [bool state = false]) {
    if (isDisplayAllDays == displayAllDays) return;

    updatePref(() {
      _isDisplayAllDays = displayAllDays ?? PrefKey.defaultDisplayAllDays;
    }, state);
    setBool(PrefKey.isDisplayAllDays, _isDisplayAllDays);
  }

  DateTime get cachedIcalDate => _cachedIcalDate ?? DateTime(2000);

  void setCachedIcalDate([DateTime? newCachedIcalDate, state = false]) {
    updatePref(() => _cachedIcalDate = newCachedIcalDate, state);
    setString(PrefKey.cachedIcalDate, _cachedIcalDate?.toIso8601String());
  }

  List<Hidden> get hiddenEvents => _hiddenEvents ?? PrefKey.defaultHiddenEvents;

  void setHiddenEvents(List<Hidden>? newHiddenEvents, [bool state = false]) {
    updatePref(() {
      _hiddenEvents =
          newHiddenEvents?.toSet().toList() ?? PrefKey.defaultHiddenEvents;
    }, state);
    final hiddensJSON =
        _hiddenEvents!.map((n) => json.encode(n.toJson())).toList();
    setStringList(PrefKey.hiddenEvent, hiddensJSON);
  }

  void addHiddenEvent(Hidden hidden, [bool state = false]) {
    hiddenEvents.add(hidden);
    setHiddenEvents(hiddenEvents, state);
  }

  void removeHiddenEvent(String uid, [bool state = false]) {
    hiddenEvents.removeWhere((event) => event.courseUid == uid);
    setHiddenEvents(hiddenEvents, state);
  }

  Map<String, String> get renamedEvents =>
      _renamedEvents ?? PrefKey.defaultRenamedEvent;

  void setRenamedEvents(Map<String, String>? newRenamedEvents,
      [bool state = false]) {
    updatePref(() {
      _renamedEvents = newRenamedEvents ?? PrefKey.defaultRenamedEvent;
    }, state);
    setString(PrefKey.renamedEvent, json.encode(_renamedEvents));
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
      hiddenEvents.any((e) => e.courseUid == course.uid);

  bool get isFullHiddenEvent =>
      _isFullHiddenEvent ?? PrefKey.defaultFullHiddenEvent;

  void setFullHiddenEvent(bool? fullHiddenEvent, [bool state = false]) {
    if (isFullHiddenEvent == fullHiddenEvent) return;

    updatePref(() {
      _isFullHiddenEvent = fullHiddenEvent ?? PrefKey.defaultFullHiddenEvent;
    }, state);
    setBool(PrefKey.isFullHiddenEvents, _isFullHiddenEvent);
  }

  bool get isGenerateEventColor =>
      _isGenerateEventColor ?? PrefKey.defaultGenerateEventColor;

  void setGenerateEventColor(bool? isEventColor, [bool state = false]) {
    if (isGenerateEventColor == isEventColor) return;

    updatePref(() {
      _isGenerateEventColor = isEventColor ?? PrefKey.defaultGenerateEventColor;
    }, state);
    setBool(PrefKey.isGenerateEventColor, _isGenerateEventColor);
  }

  @override
  Future<void> initFromDisk() async {
    await initIcsUrls();

    String? cachedIcalDate = sharedPrefs?.getString(PrefKey.cachedIcalDate);
    if (cachedIcalDate != null) {
      setCachedIcalDate(DateTime.parse(cachedIcalDate));
    }

    // Init number of weeks to display
    setNumberWeeks(sharedPrefs?.getInt(PrefKey.numberWeeks));

    // Init display or not of previous courses
    setShowPreviousCourses(sharedPrefs?.getBool(PrefKey.isPreviousCourses));

    // Init theme preferences
    setCalendarType(
      calendarTypeFromStr(sharedPrefs?.getString(PrefKey.calendarType)),
    );

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
    setAppLaunchCounter(sharedPrefs?.getInt(PrefKey.appLaunchCounter));
    setIntroDone(sharedPrefs?.getBool(PrefKey.isIntroDone));
    setDisplayAllDays(sharedPrefs?.getBool(PrefKey.isDisplayAllDays));
    setGenerateEventColor(sharedPrefs?.getBool(PrefKey.isGenerateEventColor));
    setFullHiddenEvent(sharedPrefs?.getBool(PrefKey.isFullHiddenEvents));

    // Init saved notes
    List<String> notesStr = sharedPrefs?.getStringList(PrefKey.notes) ?? [];
    List<Note> actualNotes =
        notesStr.map((n) => Note.fromJson(json.decode(n))).toList();
    setNotes(actualNotes);

    // Init hidden courses
    List<String> hiddensStr =
        sharedPrefs?.getStringList(PrefKey.hiddenEvent) ?? [];
    List<Hidden> hiddens =
        hiddensStr.map((n) => Hidden.fromJson(json.decode(n))).toList();
    setHiddenEvents(hiddens);

    // Renamed events
    Map<String, dynamic> renamedEvents = json.decode(
      sharedPrefs?.getString(PrefKey.renamedEvent) ?? '{}',
    );
    setRenamedEvents(renamedEvents.cast<String, String>());

    List<String>? eventsStr = sharedPrefs?.getStringList(PrefKey.customEvent);
    List<CustomCourse> actualEvents = (eventsStr ?? []).map((eventStr) {
      Map<String, dynamic> eventJson = json.decode(eventStr);
      return CustomCourse.fromJson(eventJson);
    }).toList();

    // Set update state true/false on last to force rebuild
    setCustomEvents(actualEvents);
  }

  Future<void> initIcsUrls() async {
    // OLD VERSION migration
    String? urlIcs = sharedPrefs?.getString('url_ics');
    if (urlIcs != null) {
      setUrlIcs([urlIcs]);
      await sharedPrefs?.remove('url_ics');
      return;
    }

    List<String>? allUrlIcs = sharedPrefs?.getStringList(PrefKey.urlIcs);
    if (allUrlIcs != null) {
      setUrlIcs(allUrlIcs);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is SettingsProvider &&
      urlIcs != other.urlIcs &&
      numberWeeks != other.numberWeeks &&
      isPreviousCourses != other.isPreviousCourses &&
      appLaunchCounter != other.appLaunchCounter &&
      isIntroDone != other.isIntroDone &&
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
      urlIcs.hashCode ^
      numberWeeks.hashCode ^
      isPreviousCourses.hashCode ^
      appLaunchCounter.hashCode ^
      isIntroDone.hashCode ^
      calendarType.hashCode ^
      isDisplayAllDays.hashCode ^
      isFullHiddenEvent.hashCode ^
      Object.hashAll(cachedCourses) ^
      Object.hashAll(notes) ^
      Object.hashAll(customEvents) ^
      Object.hashAll(hiddenEvents) ^
      renamedEvents.hashCode ^
      cachedIcalDate.hashCode ^
      isGenerateEventColor.hashCode;
}
