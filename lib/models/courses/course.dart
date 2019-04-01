import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/note.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';

class Course extends BaseCourse {
  String uid;
  String title;
  String description;
  String location;
  String renamedTitle;
  List<Note> notes;
  DateTime dateStart;
  DateTime dateEnd;
  Color color;
  bool isHidden;

  Course({
    this.uid,
    this.title,
    this.description,
    this.location,
    this.dateStart,
    this.dateEnd,
    this.notes,
    this.color,
    this.isHidden = false,
    this.renamedTitle,
  }) {
    this.notes ??= [];
  }

  factory Course.empty() =>
      Course(uid: "", title: "", description: "", location: "");

  bool hasNote() => (notes?.length ?? 0) > 0;

  bool isFinish() => dateEnd.isBefore(DateTime.now());

  bool isStarted() => dateStart.isBefore(DateTime.now()) && !isFinish();

  int getMinutesBeforeStart() {
    int minutes = dateStart.difference(dateEnd).inMinutes;
    return minutes > 0 ? minutes : 0;
  }

  bool isExam() {
    return title.contains(RegExp('exam', caseSensitive: false));
  }

  bool hasColor() => color != null;

  Color getColor(bool isGenerateEventColor) {
    if (color != null) return color;
    if (isExam()) return Colors.red[600];
    if (isGenerateEventColor) return getColorFromString(getTitle());
    return null;
  }

  @override
  String dateForDisplay() {
    final startTime = Date.extractTime(dateStart);
    final endTime = Date.extractTime(dateEnd);

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

  String getTitle() => this.renamedTitle ?? this.title;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        uid: json["uid"],
        title: json["title"],
        description: json["description"],
        location: json["location"],
        dateStart: DateTime.fromMillisecondsSinceEpoch(json["date_start"]),
        dateEnd: DateTime.fromMillisecondsSinceEpoch(json["date_end"]),
        color: json['color'] != null ? Color(json['color']) : null,
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "title": title,
        "description": description,
        "location": location,
        "date_start": dateStart.millisecondsSinceEpoch,
        "date_end": dateEnd.millisecondsSinceEpoch,
        "color": color?.value,
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
      notes.hashCode ^
      dateStart.hashCode ^
      dateEnd.hashCode ^
      color.hashCode;
}
