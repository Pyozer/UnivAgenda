import 'dart:async';
import 'dart:convert';

import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<String> getCampus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.campus);
  }

  static Future<String> getDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.department);
  }

  static Future<String> getYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.year);
  }

  static Future<String> getGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.group);
  }

  static Future<PrefsCalendar> changeGroupPref(
      {String campus, String department, String year, String group}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    PrefsCalendar values = Data.checkDataValues(
        campus: campus, department: department, year: year, group: group);

    await prefs.setString(PrefKey.campus, values.campus);
    await prefs.setString(PrefKey.department, values.department);
    await prefs.setString(PrefKey.year, values.year);
    await prefs.setString(PrefKey.group, values.group);

    return values;
  }

  static Future<int> getNumberWeek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.numberWeek) ?? PrefKey.defaultNumberWeek;
  }

  static Future<int> setNumberWeekStr(String numberWeek) async {
    int intValue = PrefKey.defaultNumberWeek;
    if (isNumeric(numberWeek)) intValue = int.parse(numberWeek);
    return setNumberWeek(intValue);
  }

  static Future<int> setNumberWeek(int numberWeek) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.numberWeek, numberWeek);
    return numberWeek;
  }

  static Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.darkTheme) ?? PrefKey.defaultDarkTheme;
  }

  static Future<bool> setDarkTheme(bool darkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.darkTheme, darkTheme);
    return darkTheme;
  }

  static Future<int> getPrimaryColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.primaryColor) ?? PrefKey.defaultPrimaryColor;
  }

  static Future<int> setPrimaryColor(int primaryColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.primaryColor, primaryColor);
    return primaryColor;
  }

  static Future<int> getAccentColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.accentColor) ?? PrefKey.defaultAccentColor;
  }

  static Future<int> setAccentColor(int accentColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.accentColor, accentColor);
    return accentColor;
  }

  static Future<int> getNoteColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.noteColor) ?? PrefKey.defaultNoteColor;
  }

  static Future<int> setNoteColor(int noteColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.noteColor, noteColor);
    return noteColor;
  }

  static Future<bool> isFirstBoot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.firstBoot) ?? true;
  }

  static Future<bool> setFirstBoot(bool isFirstBoot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.firstBoot, isFirstBoot);
    return isFirstBoot;
  }

  static Future<String> getCachedIcal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.cachedIcal) ?? null;
  }

  static Future<String> setCachedIcal(String icalToCache) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKey.cachedIcal, icalToCache);
    return icalToCache;
  }

  static Future<List<Note>> getNotes() async {
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

  static Future<List<Note>> getCourseNotes(Course course) async {
    List<Note> notes = await getNotes();

    return notes.where((note) => note.courseUid == course.uid);
  }

  static Future<List<Note>> setNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> notesJSON = [];
    notes.forEach((note) {
      notesJSON.add(json.encode(note.toJson()));
    });

    await prefs.setStringList(PrefKey.notes, notesJSON);
    return notes;
  }

  static Future<List<Note>> addNote(Note noteToAdd) async {
    List<Note> notes = await getNotes();
    notes.add(noteToAdd);

    await setNotes(notes);

    return notes;
  }

  static Future<List<Note>> removeNote(Note noteToRemove) async {
    List<Note> notes = await getNotes();
    notes.removeWhere((note) => (note == noteToRemove));

    await setNotes(notes);

    return notes;
  }

  static Future<List<CustomCourse>> getCustomEvents() async {
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

  static Future<List<CustomCourse>> setCustomEvents(
      List<CustomCourse> events) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> eventsJSON = [];
    events.forEach((event) {
      if (event != null)
        eventsJSON.add(json.encode(event.toJson()));
    });

    await prefs.setStringList(PrefKey.customEvent, eventsJSON);
    return events;
  }

  static Future<List<CustomCourse>> addCustomEvent(
      CustomCourse eventToAdd) async {
    List<CustomCourse> events = await getCustomEvents();
    events.add(eventToAdd);

    await setCustomEvents(events);

    return events;
  }

  static Future<List<CustomCourse>> editCustomEvent(
      CustomCourse eventEdited) async {
    await removeCustomEvent(eventEdited);
    return await addCustomEvent(eventEdited);
  }

  static Future<List<CustomCourse>> removeCustomEvent(
      CustomCourse eventToRemove) async {
    List<CustomCourse> events = await getCustomEvents();
    events.removeWhere((event) => (event == eventToRemove));

    await setCustomEvents(events);

    return events;
  }

  static Future<Map<String, dynamic>> getThemeValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.darkTheme] = await Preferences.getDarkTheme();
    dataPrefs[PrefKey.primaryColor] = await Preferences.getPrimaryColor();
    dataPrefs[PrefKey.accentColor] = await Preferences.getAccentColor();
    dataPrefs[PrefKey.noteColor] = await Preferences.getNoteColor();

    return dataPrefs;
  }

  static Future<Map<String, dynamic>> getGroupValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.campus] = await Preferences.getCampus();
    dataPrefs[PrefKey.department] = await Preferences.getDepartment();
    dataPrefs[PrefKey.year] = await Preferences.getYear();
    dataPrefs[PrefKey.group] = await Preferences.getGroup();
    dataPrefs[PrefKey.numberWeek] = await Preferences.getNumberWeek();

    return dataPrefs;
  }

  static Future<Map<String, dynamic>> getAllValues() async {
    Map allPrefs = await Preferences.getGroupValues();
    allPrefs.addAll(await Preferences.getThemeValues());

    return allPrefs;
  }
}
