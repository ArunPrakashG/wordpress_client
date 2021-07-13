import 'package:dio/dio.dart';
import 'package:wordpress_client/src/wordpress_authorization.dart';

import '../utilities/callback.dart';
import '../enums.dart';
import '../utilities/pair.dart';

class Request {
  final Uri requestUri;
  final String endpoint;
  final Callback callback;
  final bool Function(Map<String, dynamic>) validationDelegate;
  final CancelToken cancelToken;
  final HttpMethod httpMethod;
  final WordpressAuthorization authorization;
  final Map<String, dynamic> formBody;
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
    this.authorization,
    this.perPageCount,
    this.headers,
  });

  bool get hasHeaders => headers != null && headers.isNotEmpty;

  bool get hasFormContent => formBody != null;

  bool get shouldAuthorize => authorization != null && !authorization.isDefault;

  bool get shouldValidateResponse => validationDelegate != null;

  bool get hasValidExceptionCallback => callback != null && callback.unhandledExceptionCallback != null;

  bool get hasValidCallbacks => hasValidExceptionCallback && callback.requestCallback != null && callback.responseCallback != null;

  bool get isRequestExecutable => requestUri != null;
}
