import 'package:flutter/material.dart';

import 'base_course.dart';
import 'note.dart';
import '../../utils/date.dart';
import '../../utils/functions.dart';

class Course extends BaseCourse {
  String uid;
  String title;
  String description;
  String? location;
  String? renamedTitle;
  late List<Note> allNotes;
  DateTime dateStart;
  DateTime dateEnd;
  Color? color;
  bool isHidden;

  // Only for calendar plugin, not really useful
  String? notes;

  Course({
    required this.uid,
    required this.title,
    required this.description,
    this.location,
    required this.dateStart,
    required this.dateEnd,
    List<Note>? notes,
    this.color,
    this.isHidden = false,
    this.renamedTitle,
  }) {
    allNotes = notes ?? [];
  }

  factory Course.empty(DateTime dateStart, DateTime dateEnd) => Course(
        uid: '',
        title: '',
        description: '',
        location: '',
        dateStart: dateStart,
        dateEnd: dateEnd,
      );

  Duration get duration => dateEnd.difference(dateStart);

  DateTime get dateEndCalc {
    if (isAllDay()) {
      return dateEnd.subtract(const Duration(milliseconds: 1));
    }
    return dateEnd;
  }

  bool hasNote() => allNotes.isNotEmpty;

  bool isFinish() => dateEnd.isSameOrBefore(DateTime.now());

  bool isStarted() => dateStart.isSameOrBefore(DateTime.now()) && !isFinish();

  bool isExam() {
    return title.contains(RegExp('exam', caseSensitive: false));
  }

  bool isAllDay() {
    if (dateStart.hour == 0 && dateStart.minute == 0 && dateStart.second == 0) {
      final diff = dateEnd.difference(dateStart).inSeconds;
      if (diff % (24 * 60 * 60) == 0) {
        return true;
      }
    }
    return false;
  }

  bool isAllDayOnlyOneDay() {
    if (!isAllDay()) return false;

    final diff = dateEnd.difference(dateStart).inSeconds;
    if (diff == 24 * 60 * 60) return true;
    return false;
  }

  bool hasColor() => color != null;

  Color? getBgColor(bool isGenerateEventColor) {
    if (color != null) return color!;
    if (isExam()) return Colors.red[600]!;
    if (isGenerateEventColor) return getColorFromString(getTitle());
    return null;
  }

  Color? getTitleColor(bool isGenerateEventColor) {
    final bgColor = getBgColor(isGenerateEventColor);
    if (bgColor == null) return null;

    final luminance = bgColor.computeLuminance();
    if (luminance < 0.5) return Colors.white;
    return Colors.black;
  }

  String displayTime(BuildContext context) {
    final startTime = Date.extractTime(context, dateStart);
    final endTime = Date.extractTime(context, dateEnd);

    if (Date.isSameDay(dateStart, dateEnd)) {
      return '$startTime - $endTime';
    }

    final startDate = Date.isSameDay(dateStart, DateTime.now())
        ? ''
        : Date.extractDate(dateStart);
    final endDate = Date.extractDate(dateEnd);

    return '$startDate $startTime - $endDate $endTime'.trim();
  }

  String titleClear() {
    return title
        .replaceAll('TP', '')
        .replaceAll('TD', '')
        .replaceAll('TDm', '')
        .replaceAll('CM', '')
        .replaceAll('-  -', '-');
  }

  String getTitle() => renamedTitle ?? title;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        uid: json['uid'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        dateStart: DateTime.fromMillisecondsSinceEpoch(json['date_start']),
        dateEnd: DateTime.fromMillisecondsSinceEpoch(json['date_end']),
        color: json['color'] != null ? Color(json['color']) : null,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'description': description,
        'location': location,
        'date_start': dateStart.millisecondsSinceEpoch,
        'date_end': dateEnd.millisecondsSinceEpoch,
        'color': color?.value,
      };

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          dateStart == other.dateStart &&
          dateEnd == other.dateEnd &&
          color == other.color;

  @override
  int get hashCode =>
      uid.hashCode ^
      title.hashCode ^
      description.hashCode ^
      location.hashCode ^
      allNotes.hashCode ^
      dateStart.hashCode ^
      dateEnd.hashCode ^
      color.hashCode;
}
