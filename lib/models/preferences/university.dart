class University {
  final String name;
  final String loginUrl;
  final String agendaUrl;
  final String resourcesFile;

  University(
      this.name, this.loginUrl, this.agendaUrl, this.resourcesFile);

  factory University.fromJson(Map<String, dynamic> json) => University(
        json['university'],
        json['loginUrl'],
        json['agendaUrl'],
        json['resourcesFile'],
      );

  Map<String, dynamic> toJson() => {
        'university': name,
        'agendaUrl': agendaUrl,
        'loginUrl': loginUrl,
        'resourcesFile': resourcesFile
      };

  String toString() {
    return "$name, $agendaUrl, $loginUrl, $resourcesFile";
  }
}
