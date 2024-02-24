/// Exception that an authentication failed.
class ApiAuthException implements Exception {
  final String message;

  ApiAuthException(this.message);

  @override
  String toString() => 'ApiAuthException: $message';
}

/// Exception, that connection issues occurred.
class ApiConnectException implements Exception {
  final String message;

  ApiConnectException(this.message);

  @override
  String toString() => 'ApiConnectException: $message';
}

/// Exception, that a selected / loaded school
/// is not found and not supported.
class SchoolNotFoundException implements Exception {
  final String message;

  SchoolNotFoundException(this.message);

  @override
  String toString() => 'SchoolNotFoundException: $message';
}

/// Exception, that a requested school type is not known.
class SchoolTypeNotFoundException implements Exception {
  final String message;

  SchoolTypeNotFoundException(this.message);

  @override
  String toString() => 'SchoolTypeNotFoundException: $message';
}