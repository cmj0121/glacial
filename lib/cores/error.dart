// The general error definition and handling library
import 'package:http/http.dart' as http;

// The missing authorization error message
class MissingAuth implements Exception {
  final String message;

  const MissingAuth(this.message);

  @override
  String toString() => 'MissingAuth: $message';
}

// The HTTP request error message
class RequestError implements Exception {
  final http.Response response;

  const RequestError(this.response);

  @override
  String toString() => '${response.statusCode} ${response.reasonPhrase}';
}

// vim: set ts=2 sw=2 sts=2 et:
