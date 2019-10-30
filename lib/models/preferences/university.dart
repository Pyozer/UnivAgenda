import 'dart:ui';

import 'package:myagenda/models/preferences/credentiel_fields.Dart';
import 'package:myagenda/models/preferences/status_tags.Dart';
import 'package:myagenda/utils/functions.dart';

class University {
  String id;
  String university;
  String agendaUrl;
  String loginUrl;
  List<String> loginFields;
  CredentialFields credentialFields;
  StatusTags statusTags;

  University({
    this.id,
    this.university,
    this.agendaUrl,
    this.loginUrl,
    this.loginFields,
    this.credentialFields,
    this.statusTags,
  });

  factory University.fromJson(Map<String, dynamic> json) => University(
        id: json["id"],
        university: json["university"],
        agendaUrl: json["agendaUrl"],
        loginUrl: json["loginUrl"],
        loginFields: json["loginFields"] != null
            ? List<String>.from(json["loginFields"].map((v) => v.toString()))
            : null,
        credentialFields: json["credentialFields"] == null
            ? null
            : CredentialFields.fromJson(json["credentialFields"]),
        statusTags: json["statusTags"] == null
            ? null
            : StatusTags.fromJson(json["statusTags"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "university": university,
        "agendaUrl": agendaUrl,
        "loginUrl": loginUrl,
        "loginFields": loginFields,
        "credentialFields": credentialFields?.toJson(),
        "statusTags": statusTags?.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is University &&
          id == other.id &&
          runtimeType == other.runtimeType &&
          university == other.university &&
          agendaUrl == other.agendaUrl &&
          loginUrl == other.loginUrl &&
          listEqualsNotOrdered(loginFields, other.loginFields) &&
          credentialFields == other.credentialFields &&
          statusTags == other.statusTags;

  @override
  int get hashCode =>
      id.hashCode ^
      university.hashCode ^
      agendaUrl.hashCode ^
      loginUrl.hashCode ^
      hashList(loginFields) ^
      credentialFields.hashCode ^
      statusTags.hashCode;
}
