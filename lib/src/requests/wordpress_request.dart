import 'package:dio/dio.dart';

import '../constants.dart';
import '../enums.dart';
import '../utilities/wordpress_callback.dart';
import '../wordpress_client_base.dart';
import 'request_content.dart';
import 'request_interface.dart';

typedef ValidatorCallback = bool Function(dynamic response);

/// Wraps over all requests to be send from this [WordpressClient] instance.
class WordpressRequest<T extends IRequest> {
  WordpressRequest({
    required this.requestData,
    this.callback,
    this.cancelToken,
    this.authorization,
    this.responseValidationCallback,
    this.sendTimeout = kDefaultRequestTimeout,
    this.receiveTimeout = kDefaultRequestTimeout,
  }) {
    _buildRequest();
  }

  String? _endpoint;
  String? _path;
  HttpMethod? _method;
  Map<String, String>? _headers;
  dynamic _body;
  Map<String, String>? _queryParams;
  final T requestData;
  final WordpressCallback? callback;
  final ValidatorCallback? responseValidationCallback;
  final CancelToken? cancelToken;
  final IAuthorization? authorization;
  final Duration sendTimeout;
  final Duration receiveTimeout;

  String get endpoint => _endpoint ?? '';
  String? get path => _path;
  HttpMethod get method => _method ?? HttpMethod.get;
  Map<String, String> get headers => _headers ?? const {};
  Map<String, String> get queryParams => _queryParams ?? const {};
  dynamic get body => _body;

  bool get hasHeaders => headers.isNotEmpty;
  bool get hasCustomPath => path != null;
  bool get hasFormContent => body != null;
  bool get isRequestExecutable => endpoint.isNotEmpty;
  bool get shouldValidateResponse => responseValidationCallback != null;
  bool get shouldAuthorize =>
      authorization != null && !authorization!.isDefault;
  bool get hasValidExceptionCallback =>
      callback != null && callback!.unhandledExceptionCallback != null;
  bool get hasValidCallbacks =>
      hasValidExceptionCallback &&
      callback!.responseCallback != null &&
      callback!.onReceiveProgress != null &&
      callback!.onSendProgress != null;

  bool get _hasBuild =>
      endpoint.isNotEmpty &&
      (headers.isNotEmpty || body != null || queryParams.isNotEmpty);

  void _buildRequest() {
    if (_hasBuild) {
      return;
    }

    final requestContent = RequestContent();
    requestData.build(requestContent);

    _endpoint = requestContent.endpoint;
    _method = requestContent.method;
    _headers = requestContent.headers;
    _body = requestContent.body;
    _path = requestContent.path;
    _queryParams = requestContent.queryParameters;
  }
}
