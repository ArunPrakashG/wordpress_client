import '../enums.dart';

class RequestContent {
  RequestContent({
    this.headers = const {},
    this.queryParameters = const {},
    this.body = const <String, dynamic>{},
  });

  final Map<String, String> headers;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> body;

  String endpoint = '';
  HttpMethod method = HttpMethod.get;
}
