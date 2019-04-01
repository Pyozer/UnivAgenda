import 'dart:ui';

import 'package:myagenda/models/preferences/credentiel_fields.Dart';
import 'package:myagenda/models/preferences/status_tags.Dart';
import 'package:myagenda/utils/functions.dart';

class University {
  String university;
  String agendaUrl;
  String loginUrl;
  String resourcesFile;
  List<String> loginFields;
  CredentialFields credentialFields;
  StatusTags statusTags;

  University({
    this.university,
    this.agendaUrl,
    this.loginUrl,
    this.resourcesFile,
    this.loginFields,
    this.credentialFields,
    this.statusTags,
  });

  factory University.fromJson(Map<String, dynamic> json) => University(
        university: json["university"],
        agendaUrl: json["agendaUrl"],
        loginUrl: json["loginUrl"],
        resourcesFile: json["resourcesFile"],
        loginFields: json["loginFields"] == null
            ? null
            : List<String>.from(json["loginFields"].map((x) => x)),
        credentialFields: json["credentialFields"] == null
            ? null
            : CredentialFields.fromJson(json["credentialFields"]),
        statusTags: json["statusTags"] == null
            ? null
            : StatusTags.fromJson(json["statusTags"]),
      );

  Map<String, dynamic> toJson() => {
        "university": university,
        "agendaUrl": agendaUrl,
        "loginUrl": loginUrl,
        "resourcesFile": resourcesFile,
        "loginFields": loginFields == null
            ? null
            : List<dynamic>.from(loginFields.map((x) => x)),
        "credentialFields":
            credentialFields == null ? null : credentialFields.toJson(),
        "statusTags": statusTags == null ? null : statusTags.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is University &&
          runtimeType == other.runtimeType &&
          university == other.university &&
          agendaUrl == other.agendaUrl &&
          loginUrl == other.loginUrl &&
          resourcesFile == other.resourcesFile &&
          listEqualsNotOrdered(loginFields, other.loginFields) &&
          credentialFields == other.credentialFields &&
          statusTags == other.statusTags;

  @override
  int get hashCode =>
      university.hashCode ^
      agendaUrl.hashCode ^
      loginUrl.hashCode ^
      resourcesFile.hashCode ^
      hashList(loginFields) ^
      credentialFields.hashCode ^
      statusTags.hashCode;
}
