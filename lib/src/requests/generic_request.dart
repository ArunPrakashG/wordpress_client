part of '../wordpress_client_base.dart';

typedef ValidatorCallback = bool Function(dynamic response);

class GenericRequest<T extends IRequest> {
  GenericRequest({
    required this.requestData,
    this.callback,
    this.cancelToken,
    this.authorization,
    this.responseValidationCallback,
    this.sendTimeout = kDefaultRequestTimeout,
    this.receiveTimeout = kDefaultRequestTimeout,
  });

  late final String endpoint;
  late final HttpMethod method;
  late final Map<String, String> headers;
  late final dynamic body;
  late final Map<String, String> queryParams;
  final T requestData;
  final Callback? callback;
  final ValidatorCallback? responseValidationCallback;
  final CancelToken? cancelToken;
  final IAuthorization? authorization;
  final int sendTimeout;
  final int receiveTimeout;

  bool get hasHeaders => headers.isNotEmpty;
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

  void buildRequest() {
    if (_hasBuild) {
      return;
    }

    final requestContent = RequestContent();
    requestData.build(requestContent);

    endpoint = requestContent.endpoint;
    method = requestContent.method;
    headers = requestContent.headers;
    body = requestContent.body;
    queryParams = requestContent.queryParameters;
  }
}
