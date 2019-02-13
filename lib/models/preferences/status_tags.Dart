class StatusTags {
  String error;
  String success;

  StatusTags({this.error, this.success});

  factory StatusTags.fromJson(Map<String, dynamic> json) =>
      StatusTags(error: json["error"], success: json["success"]);

  Map<String, dynamic> toJson() => {"error": error, "success": success};
}
