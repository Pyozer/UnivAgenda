class CredentialFields {
  String username;
  String password;

  CredentialFields({this.username, this.password});

  factory CredentialFields.fromJson(Map<String, dynamic> json) =>
      CredentialFields(username: json["username"], password: json["password"]);

  Map<String, dynamic> toJson() => {"username": username, "password": password};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialFields &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;
}
