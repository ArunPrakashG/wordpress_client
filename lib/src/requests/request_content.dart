import '../enums.dart';

class RequestContent {
  RequestContent()
      : body = <String, dynamic>{},
        headers = <String, String>{},
        queryParameters = <String, String>{};

  final Map<String, String> headers;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> body;

  String endpoint = '';
  HttpMethod method = HttpMethod.get;
}
