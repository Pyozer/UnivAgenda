import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/preferences/prefs_theme.dart';
import 'package:myagenda/models/preferences/university.dart';
import 'package:myagenda/models/room.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  /// Agenda preferences (list of group keys)
  List<String> _prefsGroupKeys = [];

  /// Url of custom ics file (if user choose "Other" in login page)
  String _urlIcs;

  /// Number of weeks to display
  int _numberWeeks;

  /// Installation UID
  String _installUID;

  /// App launch counter
  int _appLaunchCounter;

  /// Is intro already view
  bool _isIntroDone;

  /// Is the user if logged
  bool _userLogged;

  /// If agenda is in horizontal mode
  bool _horizontalView;

  /// Display all week days even if no event
  bool _isDisplayAllDays;

  /// Display the group header
  bool _isHeaderGroup;

  /// Last ical loaded
  String _cachedIcal;

  /// List of notes for events
  List<Note> _notes;

  /// List of all custom events
  List<CustomCourse> _customEvents;

  /// Resources (contain all agenda with their ID)
  Map<String, dynamic> _resources;

  /// Last date that the resources has ben updated
  DateTime _resourcesDate;

  /// Last date that the ical cache has ben updated
  DateTime _cachedIcalDate;

  /// Generate or not a event color
  bool _isGenerateEventColor;

  List<String> getAllUniversity() {
    return _listUniversity?.map((univ) => univ.name)?.toList() ?? [];
  }

  University findUniversity(String university) {
    return listUniversity.firstWhere((univ) => univ.name == university,
        orElse: () => null);
  }

  List<String> get groupKeys => _prefsGroupKeys;

  setGroupKeys(List<String> newGroupKeys, [state = false]) {
    // Check if values are correct together
    List<String> checkedGroupKeys = checkDataValues(newGroupKeys);

    if (checkedGroupKeys == groupKeys) return;

    _updatePref(() {
      _prefsGroupKeys = checkedGroupKeys;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(PrefKey.groupKeys, checkedGroupKeys);
    });
  }

  List<List<String>> getAllGroupKeys() {
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
    while (!(resources is int) && resources.keys.length > 0) {
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

  List<String> getAllRoomsKeys() {
    List<String> roomsKeys = [];
    if (resources.containsKey('Rooms')) {
      resources['Rooms'].keys.forEach((roomKey) {
        roomsKeys.add(roomKey);
      });
    }
    return roomsKeys;
  }

  List<Room> getRoomsOfCampus(String campus) {
    List<Room> rooms = [];

    if (resources.containsKey('Rooms') && resources['Rooms'].containsKey(campus))
      rooms.addAll(getRoom(resources['Rooms'][campus]));
    
    return rooms;
  }

  List<Room> getRoom(Map<String, dynamic> roomResources) {
    List<Room> rooms = [];
    roomResources.keys.forEach((key) {
      if (roomResources[key] is int)
        rooms.add(Room(key, roomResources[key]));
      else 
        rooms.addAll(getRoom(roomResources[key]));
    });
    return rooms;
  }

  String get urlIcs => _urlIcs ?? PrefKey.defaultUrlIcs;

  setUrlIcs(String newUrlIcs, [state = false]) {
    if (urlIcs == newUrlIcs) return;

    _updatePref(() {
      _urlIcs = newUrlIcs;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(PrefKey.urlIcs, _urlIcs));
  }

  int get numberWeeks => _numberWeeks ?? PrefKey.defaultNumberWeeks;

  setNumberWeeks(int newNumberWeeks, [state = false]) {
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

  setDarkTheme(bool darkTheme, [state = false]) {
    if (theme.darkTheme == darkTheme) return;

    _updatePref(() {
      _prefsTheme.darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isDarkTheme, _prefsTheme.darkTheme));
  }

  setPrimaryColor(int newPrimaryColor, [state = false]) {
    if (theme.primaryColor == newPrimaryColor) return;

    _updatePref(() {
      _prefsTheme.primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setInt(PrefKey.primaryColor, _prefsTheme.primaryColor));
  }

  setAccentColor(int newAccentColor, [state = false]) {
    if (theme.accentColor == newAccentColor) return;

    _updatePref(() {
      _prefsTheme.accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt(PrefKey.accentColor, _prefsTheme.accentColor));
  }

  setNoteColor(int newNoteColor, [state = false]) {
    if (theme.noteColor == newNoteColor) return;

    _updatePref(() {
      _prefsTheme.noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt(PrefKey.noteColor, _prefsTheme.noteColor));
  }

  String get installUID {
    if (_installUID == null) {
      _installUID = Uuid().v1();

      SharedPreferences.getInstance()
          .then((prefs) => prefs.setString(PrefKey.installUID, _installUID));
    }
    return _installUID;
  }

  int get appLaunchCounter =>
      _appLaunchCounter ?? PrefKey.defaultAppLaunchCounter;

  setAppLaunchCounter(int newAppLaunchCounter, [state = false]) {
    if (newAppLaunchCounter == _appLaunchCounter) return;

    _updatePref(() {
      _appLaunchCounter = newAppLaunchCounter;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setInt(PrefKey.appLaunchCounter, _appLaunchCounter));
  }

  bool get isIntroDone => _isIntroDone ?? PrefKey.defaultIntroDone;

  setIntroDone(bool newIntroDone, [state = false]) {
    if (newIntroDone == _isIntroDone) return;

    _updatePref(() {
      _isIntroDone = newIntroDone;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isIntroDone, _isIntroDone));
  }

  String get cachedIcal => _cachedIcal ?? null;

  setCachedIcal(String icalToCache, [state = false]) {
    if (cachedIcal == icalToCache) return;

    _updatePref(() {
      _cachedIcal = icalToCache ?? null;
    }, state);

    writeFile(PrefKey.cachedIcalFile, _cachedIcal);
    setCachedIcalDate(); // Set ical last update date to now
  }

  List<Note> get notes {
    List<CustomCourse> events = customEvents;
    // Get all notes who have their courseUID in events list or not expired
    return _notes
            ?.where((note) =>
                events.contains(note.courseUid) || !note.isNoteExpired())
            ?.toList() ??
        PrefKey.defaultNotes;
  }

  setNotes(List<Note> newNotes, [state = false]) {
    if (notes == newNotes) return;

    newNotes ??= PrefKey.defaultNotes;

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

  void addNote(Note noteToAdd, [state = false]) {
    if (noteToAdd == null) return;
    List<Note> newNotes = notes;
    newNotes.add(noteToAdd);

    setNotes(newNotes, state);
  }

  void removeNote(Note noteToRemove, [state = false]) {
    if (noteToRemove == null) return;

    List<Note> newNotes = notes;
    newNotes.removeWhere((note) => (note == noteToRemove));

    setNotes(newNotes, state);
  }

  List<CustomCourse> get customEvents =>
      _customEvents
          ?.where((event) => !event.isFinish() || event.isRecurrentEvent())
          ?.toList() ??
      PrefKey.defaultCustomEvents;

  setCustomEvents(List<CustomCourse> newCustomEvents, [state = false]) {
    if (customEvents == newCustomEvents) return;

    newCustomEvents ??= PrefKey.defaultCustomEvents;
    newCustomEvents
        .removeWhere((event) => event.isFinish() && !event.isRecurrentEvent());

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

  void addCustomEvent(CustomCourse eventToAdd, [state = false]) {
    if (eventToAdd == null) return;

    List<CustomCourse> newEvents = customEvents;
    newEvents.add(eventToAdd);

    setCustomEvents(newEvents, state);
  }

  void removeCustomEvent(CustomCourse eventToRemove, [state = false]) {
    if (eventToRemove == null) return;

    List<CustomCourse> newEvents = customEvents;
    newEvents.removeWhere((event) => (event.uid == eventToRemove.uid));

    setCustomEvents(newEvents, state);
  }

  void editCustomEvent(CustomCourse eventEdited, [state = false]) {
    if (eventEdited == null) return;

    removeCustomEvent(eventEdited, false);
    addCustomEvent(eventEdited, state);
  }

  bool get isUserLogged => _userLogged ?? PrefKey.defaultUserLogged;

  setUserLogged(bool userLogged, [state = false]) {
    if (isUserLogged == userLogged) return;

    _updatePref(() {
      _userLogged = userLogged ?? PrefKey.defaultUserLogged;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isUserLogged, _userLogged));
  }

  bool get isHorizontalView => _horizontalView ?? PrefKey.defaultHorizontalView;

  setHorizontalView(bool horizontalView, [state = false]) {
    if (isHorizontalView == horizontalView) return;

    _updatePref(() {
      _horizontalView = horizontalView ?? PrefKey.defaultHorizontalView;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isHorizontalView, _horizontalView));
  }

  bool get isDisplayAllDays =>
      _isDisplayAllDays ?? PrefKey.defaultDisplayAllDays;

  setDisplayAllDays(bool displayAllDays, [state = false]) {
    if (isDisplayAllDays == displayAllDays) return;

    _updatePref(() {
      _isDisplayAllDays = displayAllDays ?? PrefKey.defaultDisplayAllDays;
    }, state);

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PrefKey.isDisplayAllDays, _isDisplayAllDays));
  }

  bool get isHeaderGroupVisible => _isHeaderGroup ?? PrefKey.defaultHeaderGroup;

  setHeaderGroupVisible(bool headerGroup, [state = false]) {
    if (isHeaderGroupVisible == headerGroup) return;

    _updatePref(() {
      _isHeaderGroup = headerGroup ?? PrefKey.defaultHeaderGroup;
    }, state);

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(PrefKey.isHeaderGroup, _isHeaderGroup));
  }

  List<University> get listUniversity =>
      _listUniversity ?? PrefKey.defaultListUniversity;

  setListUniversityFromJSONString(String listUnivJson, [state = false]) {
    List resJson = json.decode(listUnivJson);
    List<University> univ = resJson.map((m) => University.fromJson(m)).toList();

    if (listUniversity == univ) return;

    _updatePref(() {
      _listUniversity = univ ?? PrefKey.defaultListUniversity;
    }, state);

    writeFile(PrefKey.listUniversityFile, listUnivJson);
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

  setResources(String newResourcesJson, [state = false]) {
    Map<String, dynamic> newResources = json.decode(newResourcesJson);
    if (resources == newResources) return;

    _updatePref(() {
      _resources = newResources ?? PrefKey.defaultResources;
    }, state);

    // Check actual calendar prefs with new resources
    if (_resources.length > 0) setGroupKeys(groupKeys, state);
    // Update cache file
    writeFile(PrefKey.resourcesFile, newResourcesJson);
  }

  DateTime get resourcesDate =>
      _resourcesDate ??
      DateTime.fromMillisecondsSinceEpoch(PrefKey.defaultCachedIcalDate);

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

  DateTime get cachedIcalDate =>
      _cachedIcalDate ??
      DateTime.fromMillisecondsSinceEpoch(PrefKey.defaultCachedIcalDate);

  setCachedIcalDate([newCachedIcalDate, state = false]) {
    newCachedIcalDate ??= DateTime.now();

    _updatePref(() {
      _cachedIcalDate = newCachedIcalDate;
    }, state);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(
          PrefKey.cachedIcalDate, _cachedIcalDate.millisecondsSinceEpoch);
    });
  }

  disconnectUser([state = false]) {
    setUserLogged(false);
    setUrlIcs(null);
    setResources(PrefKey.defaultResourcesJson);
    setCachedIcal(PrefKey.defaultCachedIcal);
  }

  bool get isGenerateEventColor =>
      _isGenerateEventColor ?? PrefKey.defaultGenerateEventColor;

  setGenerateEventColor(bool generateEventColor, [state = false]) {
    if (isGenerateEventColor == generateEventColor) return;

    _updatePref(() {
      _isGenerateEventColor =
          generateEventColor ?? PrefKey.defaultGenerateEventColor;
    }, state);

    SharedPreferences.getInstance().then((prefs) =>
        prefs.setBool(PrefKey.isGenerateEventColor, _isGenerateEventColor));
  }

  Future<Null> initFromDisk([state = false]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await initResAndGroup();

    final int resourcesDate =
        prefs.getInt(PrefKey.resourcesDate) ?? PrefKey.defaultResourcesDate;
    setResourcesDate(DateTime.fromMillisecondsSinceEpoch(resourcesDate));

    final int cachedIcalDate =
        prefs.getInt(PrefKey.cachedIcalDate) ?? PrefKey.defaultCachedIcalDate;
    setCachedIcalDate(DateTime.fromMillisecondsSinceEpoch(cachedIcalDate));

    // Init number of weeks to display
    setNumberWeeks(prefs.getInt(PrefKey.numberWeeks));

    // Init theme preferences
    setHorizontalView(prefs.getBool(PrefKey.isHorizontalView));
    setDarkTheme(prefs.getBool(PrefKey.isDarkTheme));
    setPrimaryColor(prefs.getInt(PrefKey.primaryColor));
    setAccentColor(prefs.getInt(PrefKey.accentColor));
    setNoteColor(prefs.getInt(PrefKey.noteColor));

    // Init other prefs
    setCachedIcal(
        await readFile(PrefKey.cachedIcalFile, PrefKey.defaultCachedIcal));
    setUserLogged(prefs.getBool(PrefKey.isUserLogged));
    _installUID = prefs.getString(PrefKey.installUID);
    setAppLaunchCounter(prefs.getInt(PrefKey.appLaunchCounter));
    setIntroDone(prefs.getBool(PrefKey.isIntroDone));
    setDisplayAllDays(prefs.getBool(PrefKey.isDisplayAllDays));
    setGenerateEventColor(prefs.getBool(PrefKey.isGenerateEventColor));

    // Init saved notes
    List<Note> actualNotes = [];
    List<String> notesStr = prefs.getStringList(PrefKey.notes) ?? [];
    notesStr.forEach((noteJsonStr) {
      actualNotes.add(Note.fromJsonStr(noteJsonStr));
    });
    setNotes(actualNotes);

    List<CustomCourse> actualEvents = [];
    List<String> customEventsStr =
        prefs.getStringList(PrefKey.customEvent) ?? [];
    customEventsStr.forEach((eventJsonStr) {
      actualEvents.add(CustomCourse.fromJsonStr(eventJsonStr));
    });

    // Set update state true/false on last to force rebuild
    setCustomEvents(actualEvents, state);
  }

  Future<Null> initResAndGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Init list university stored values
    String listUnivStored = await readFile(
        PrefKey.listUniversityFile, PrefKey.defaultListUniversityJson);
    setListUniversityFromJSONString(listUnivStored);

    // If user choose custom url ics, not init other group prefs
    String urlIcs = prefs.getString(PrefKey.urlIcs);
    if (urlIcs != null) {
      setUrlIcs(urlIcs);
      return null;
    }

    // If list of university is not empty
    if (listUniversity.length > 0) {
      String storedUniversityName = prefs.getString(PrefKey.university);

      // If no university store
      if (storedUniversityName == null || storedUniversityName.length == 0) {
        // Take first university of list
        storedUniversityName = listUniversity[0].name;
      }
      setUniversity(storedUniversityName);

      // Parse local resources to Map
      String storedResourcesStr =
          await readFile(PrefKey.resourcesFile, PrefKey.defaultResourcesJson);
      storedResourcesStr.trim();

      // If local resources aren't empty
      if (storedResourcesStr.length > 0 &&
          storedResourcesStr != PrefKey.defaultResourcesJson) {
        // Init group preferences
        final List<String> groupKeys = prefs.getStringList(PrefKey.groupKeys);
        // Update
        setResources(storedResourcesStr);
        // Check values and resave group prefs (useful if issue)
        setGroupKeys(groupKeys);
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

  void forceSetState() {
    setState(() {
      // nothing, just force to rebuild
    });
  }

  @override
  bool operator ==(Object other) =>
      other is PreferencesProviderState &&
      groupKeys == other.groupKeys &&
      numberWeeks == other.numberWeeks &&
      theme == other.theme &&
      appLaunchCounter == other.appLaunchCounter &&
      isIntroDone == other.isIntroDone &&
      cachedIcal == other.cachedIcal &&
      notes == other.notes &&
      customEvents == other.customEvents &&
      isUserLogged == other.isUserLogged &&
      isHorizontalView == other.isHorizontalView &&
      listUniversity == other.listUniversity &&
      cachedIcalDate == other.cachedIcalDate &&
      resourcesDate == other.resourcesDate &&
      resources == other.resources;

  @override
  int get hashCode =>
      _prefsGroupKeys.hashCode ^
      _numberWeeks.hashCode ^
      _prefsTheme.hashCode ^
      _appLaunchCounter.hashCode ^
      _isIntroDone.hashCode ^
      _cachedIcal.hashCode ^
      _notes.hashCode ^
      _customEvents.hashCode ^
      _userLogged.hashCode ^
      _horizontalView.hashCode ^
      _listUniversity.hashCode ^
      _resourcesDate.hashCode ^
      _cachedIcalDate.hashCode ^
      _resources.hashCode;
}
