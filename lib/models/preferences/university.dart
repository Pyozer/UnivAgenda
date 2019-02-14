import 'package:myagenda/models/preferences/credentiel_fields.Dart';
import 'package:myagenda/models/preferences/status_tags.Dart';

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
}
