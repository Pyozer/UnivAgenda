class BaseResponse<T> {
  /// Response data (can be null if error)
  T? data;

  /// Response error (can be null if no error)
  String? error;

  BaseResponse({this.data, this.error});

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
        data: json['data'],
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {'data': data, 'error': error};
}
