import 'package:dio/dio.dart';

import '../utilities/callback.dart';
import '../enums.dart';
import '../utilities/pair.dart';

class Request {
  final Uri requestUri;
  final String endpoint;
  final Callback callback;
  final bool Function(String) validationDelegate;
  final CancelToken cancelToken;
  final HttpMethod httpMethod;
  final dynamic formBody;
  final int perPageCount;
  final List<Pair<String, String>> headers;

  Request(
    this.requestUri, {
    this.endpoint,
    this.callback,
    this.validationDelegate,
    this.cancelToken,
    this.httpMethod,
    this.formBody,
    this.perPageCount,
    this.headers,
  });
}
