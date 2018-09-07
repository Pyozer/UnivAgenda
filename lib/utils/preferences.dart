import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends InheritedWidget {
  PreferencesProvider({Key key, @required this.prefs, @required this.child})
      : super(key: key, child: child);

  final Preferences prefs;
  final Widget child;

  static PreferencesProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PreferencesProvider)
        as PreferencesProvider);
  }

  @override
  bool updateShouldNotify(PreferencesProvider oldWidget) {
    if (!prefs.dataChange) {
      return false;
    }
    prefs.dataChange = false;
    return true;
  }
}

class Preferences {
  bool dataChange = false;

  Future<String> getCampus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.campus);
  }

  Future<String> getDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.department);
  }

  Future<String> getYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.year);
  }

  Future<String> getGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.group);
  }

  Future<PrefsCalendar> changeGroupPref(
      {String campus, String department, String year, String group}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    PrefsCalendar values = Data.checkDataValues(
        campus: campus, department: department, year: year, group: group);

    await prefs.setString(PrefKey.campus, values.campus);
    await prefs.setString(PrefKey.department, values.department);
    await prefs.setString(PrefKey.year, values.year);
    await prefs.setString(PrefKey.group, values.group);

    dataChange = true;

    return values;
  }

  Future<int> getNumberWeek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.numberWeek) ?? PrefKey.defaultNumberWeek;
  }

  Future<int> setNumberWeekStr(String numberWeek) async {
    int intValue = PrefKey.defaultNumberWeek;
    if (isNumeric(numberWeek)) intValue = int.parse(numberWeek);
    return setNumberWeek(intValue);
  }

  Future<int> setNumberWeek(int numberWeek) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.numberWeek, numberWeek);
    dataChange = true;
    return numberWeek;
  }

  Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.darkTheme) ?? PrefKey.defaultDarkTheme;
  }

  Future<bool> setDarkTheme(bool darkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.darkTheme, darkTheme);
    dataChange = true;
    return darkTheme;
  }

  Future<int> getPrimaryColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.primaryColor) ?? PrefKey.defaultPrimaryColor;
  }

  Future<int> setPrimaryColor(int primaryColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.primaryColor, primaryColor);
    dataChange = true;
    return primaryColor;
  }

  Future<int> getAccentColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.accentColor) ?? PrefKey.defaultAccentColor;
  }

  Future<int> setAccentColor(int accentColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.accentColor, accentColor);
    dataChange = true;
    return accentColor;
  }

  Future<int> getNoteColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.noteColor) ?? PrefKey.defaultNoteColor;
  }

  Future<int> setNoteColor(int noteColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.noteColor, noteColor);
    dataChange = true;
    return noteColor;
  }

  Future<bool> isFirstBoot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.isFirstBoot) ?? true;
  }

  Future<bool> setFirstBoot(bool isFirstBoot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.isFirstBoot, isFirstBoot);
    dataChange = true;
    return isFirstBoot;
  }

  Future<String> getCachedIcal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.cachedIcal) ?? null;
  }

  Future<String> setCachedIcal(String icalToCache) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKey.cachedIcal, icalToCache);
    dataChange = true;
    return icalToCache;
  }

  Future<List<Note>> getNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJSONStr = prefs.getStringList(PrefKey.notes) ?? [];

    List<Note> notes = [];
    notesJSONStr.forEach((noteJsonStr) {
      Map noteMap = json.decode(noteJsonStr);
      final note = Note.fromJson(noteMap);

      if (!note.isExpired()) notes.add(note);
    });

    return notes;
  }

  Future<List<Note>> getCourseNotes(Course course) async {
    List<Note> notes = await getNotes();

    return notes.where((note) => note.courseUid == course.uid);
  }

  Future<List<Note>> setNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> notesJSON = [];
    notes.forEach((note) {
      notesJSON.add(json.encode(note.toJson()));
    });

    await prefs.setStringList(PrefKey.notes, notesJSON);
    dataChange = true;
    return notes;
  }

  Future<List<Note>> addNote(Note noteToAdd) async {
    List<Note> notes = await getNotes();
    notes.add(noteToAdd);

    await setNotes(notes);

    return notes;
  }

  Future<List<Note>> removeNote(Note noteToRemove) async {
    List<Note> notes = await getNotes();
    notes.removeWhere((note) => (note == noteToRemove));

    await setNotes(notes);

    return notes;
  }

  Future<List<CustomCourse>> getCustomEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventsJSONStr = prefs.getStringList(PrefKey.customEvent) ?? [];

    List<CustomCourse> events = [];
    eventsJSONStr.forEach((eventJsonStr) {
      Map eventMap = json.decode(eventJsonStr);
      final event = CustomCourse.fromJson(eventMap);

      if (!event.isFinish()) events.add(event);
    });

    return events;
  }

  Future<List<CustomCourse>> setCustomEvents(List<CustomCourse> events) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> eventsJSON = [];
    events.forEach((event) {
      if (event != null) eventsJSON.add(json.encode(event.toJson()));
    });

    await prefs.setStringList(PrefKey.customEvent, eventsJSON);
    dataChange = true;
    return events;
  }

  Future<List<CustomCourse>> addCustomEvent(CustomCourse eventToAdd) async {
    List<CustomCourse> events = await getCustomEvents();
    events.add(eventToAdd);

    await setCustomEvents(events);

    return events;
  }

  Future<List<CustomCourse>> editCustomEvent(CustomCourse eventEdited) async {
    await removeCustomEvent(eventEdited);
    return await addCustomEvent(eventEdited);
  }

  Future<List<CustomCourse>> removeCustomEvent(
      CustomCourse eventToRemove) async {
    List<CustomCourse> events = await getCustomEvents();
    events.removeWhere((event) => (event == eventToRemove));

    await setCustomEvents(events);

    return events;
  }

  Future<bool> isUserLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.isLogged) ?? false;
  }

  Future<bool> setUserLogged(bool isLogged) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.isLogged, isLogged);
    dataChange = true;
    return isLogged;
  }

  Future<bool> isHorizontalView() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.isHorizontalView) ??
        PrefKey.defaultHorizontalView;
  }

  Future<bool> setHorizontalView(bool isHorizontalView) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.isHorizontalView, isHorizontalView);
    dataChange = true;
    return isHorizontalView;
  }

  Future<Map<String, dynamic>> getRessources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map ressources = json.decode(prefs.getString(PrefKey.ressources) ?? "{}");
    return ressources;
  }

  Future<Map<String, dynamic>> setRessources(
      Map<String, dynamic> ressources) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKey.ressources, json.encode(ressources));
    Data.allData = ressources;
    dataChange = true;
    return ressources;
  }

  Future<Map<String, dynamic>> getThemeValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.darkTheme] = await getDarkTheme();
    dataPrefs[PrefKey.primaryColor] = await getPrimaryColor();
    dataPrefs[PrefKey.accentColor] = await getAccentColor();
    dataPrefs[PrefKey.noteColor] = await getNoteColor();
    dataPrefs[PrefKey.isHorizontalView] = await isHorizontalView();

    return dataPrefs;
  }

  Future<Map<String, dynamic>> getGroupValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.campus] = await getCampus();
    dataPrefs[PrefKey.department] = await getDepartment();
    dataPrefs[PrefKey.year] = await getYear();
    dataPrefs[PrefKey.group] = await getGroup();
    dataPrefs[PrefKey.numberWeek] = await getNumberWeek();

    return dataPrefs;
  }

  Future<Map<String, dynamic>> getGroupAndThemeValues() async {
    Map allPrefs = await getGroupValues();
    allPrefs.addAll(await getThemeValues());

    return allPrefs;
  }
}
