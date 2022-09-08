class StatusTags {
  String error;
  String success;

  StatusTags({this.error, this.success});

  factory StatusTags.fromJson(Map<String, dynamic> json) =>
      StatusTags(error: json["error"], success: json["success"]);

  Map<String, dynamic> toJson() => {"error": error, "success": success};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusTags &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          success == other.success;

  @override
  int get hashCode => error.hashCode ^ success.hashCode;
}
