class CustomException implements Exception {
  /// Unique error code
  String code;

  /// User readable localized error message
  String message;

  CustomException(this.code, this.message);

  @override
  String toString() => message;
}
