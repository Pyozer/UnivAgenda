import 'dart:ui';

import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';

class Course extends BaseCourse {
  String uid;
  String title;
  String description;
  String location;
  List<Note> notes;
  DateTime dateStart;
  DateTime dateEnd;
  Color color;
  bool isHidden;

  Course(
    this.uid,
    this.title,
    this.description,
    this.location,
    this.dateStart,
    this.dateEnd, {
    this.notes,
    this.color,
    this.isHidden = false
  }) {
    this.notes ??= [];
  }

  factory Course.empty() => Course("", "", "", "", null, null);

  bool hasNote() => (notes?.length ?? 0) > 0;

  bool isFinish() {
    return dateEnd.isBefore(DateTime.now());
  }

  bool isStarted() {
    return dateStart.isBefore(DateTime.now()) && !isFinish();
  }

  int getMinutesBeforeStart() {
    int minutes = dateStart.difference(dateEnd).inMinutes;
    return minutes > 0 ? minutes : 0;
  }

  bool isExam() {
    return title.contains(RegExp('exam', caseSensitive: false));
  }

  bool hasColor() => color != null;

  @override
  String dateForDisplay([Locale locale]) {
    final startTime = Date.extractTime(dateStart, locale);
    final endTime = Date.extractTime(dateEnd, locale);

    return '$startTime - $endTime';
  }

  String titleClear() {
    return title
        .replaceAll('TP', '')
        .replaceAll('TD', '')
        .replaceAll('TDm', '')
        .replaceAll('CM', '')
        .replaceAll('-  -', '-');
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    Color courseColor;
    if (json['color'] != null) courseColor = Color(json['color']);

    return Course(
      json['uid'],
      json['title'],
      json['description'],
      json['location'],
      DateTime.fromMillisecondsSinceEpoch(json['date_start']),
      DateTime.fromMillisecondsSinceEpoch(json['date_end']),
      color: courseColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'description': description,
        'location': location,
        'date_start': dateStart.millisecondsSinceEpoch,
        'date_end': dateEnd.millisecondsSinceEpoch,
        'color': color?.value
      };

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          listEqualsNotOrdered(notes, other.notes) &&
          dateStart == other.dateStart &&
          dateEnd == other.dateEnd &&
          color == other.color;

  @override
  int get hashCode =>
      uid.hashCode ^
      title.hashCode ^
      description.hashCode ^
      location.hashCode ^
      notes.hashCode ^
      dateStart.hashCode ^
      dateEnd.hashCode ^
      color.hashCode;
}
