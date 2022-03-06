import '../../wordpress_client.dart';
import '../constants.dart';

typedef ValidatorCallback = bool Function(dynamic response);

class GenericRequest {
  const GenericRequest({
    required this.endpoint,
    required this.method,
    this.callback,
    this.cancelToken,
    this.authorization,
    this.headers = const {},
    this.responseValidationCallback,
    this.body,
    this.queryParams,
    this.sendTimeout = kDefaultRequestTimeout,
    this.receiveTimeout = kDefaultRequestTimeout,
  });

  final String endpoint;
  final Callback? callback;
  final HttpMethod method;
  final ValidatorCallback? responseValidationCallback;
  final CancelToken? cancelToken;
  final IAuthorization? authorization;
  final Map<String, String> headers;
  final dynamic body;
  final Map<String, String>? queryParams;
  final int sendTimeout;
  final int receiveTimeout;

  bool get hasHeaders => headers.isNotEmpty;

  bool get hasFormContent => body != null;

  bool get shouldAuthorize =>
      authorization != null && !authorization!.isDefault;

  bool get shouldValidateResponse => responseValidationCallback != null;

  bool get hasValidExceptionCallback =>
      callback != null && callback!.unhandledExceptionCallback != null;

  bool get hasValidCallbacks =>
      hasValidExceptionCallback &&
      callback!.responseCallback != null &&
      callback!.onReceiveProgress != null &&
      callback!.onSendProgress != null;

  bool get isRequestExecutable => endpoint.isNotEmpty;
}
