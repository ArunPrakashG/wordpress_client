import 'package:dio/dio.dart';

import '../authorization_container.dart';
import '../enums.dart';
import '../utilities/callback.dart';
import '../utilities/helpers.dart';
import '../utilities/pair.dart';

class Request<TResponseType> {
  final String endpoint;
  final Callback callback;
  final bool Function(TResponseType) validationDelegate;
  final CancelToken cancelToken;
  final HttpMethod httpMethod;
  final AuthorizationContainer authorization;
  final Map<String, dynamic> formBody;
  final List<Pair<String, String>> headers;
  final Map<String, String> queryParams;
  String generatedRequestPath;
  final bool isListRequest;

  Request(
    this.endpoint, {
    this.isListRequest = false,
    this.callback,
    this.validationDelegate,
    this.cancelToken,
    this.httpMethod,
    this.formBody,
    this.authorization,
    this.headers,
    this.queryParams,
  }) {
    generatedRequestPath = _buildUrlQueryString();
  }

  bool _hasIdInUrlAlready(String requestQueryUrl, MapEntry<String, String> currentEntry) {
    if (!requestQueryUrl.contains('/')) {
      return false;
    }

    if (currentEntry.key != 'id') {
      return false;
    }

    final id = requestQueryUrl.split('/')[1];
    return currentEntry.value == id;
  }

  String _buildUrlQueryString() {
    if (queryParams == null || queryParams.isEmpty) {
      return '';
    }

    var requestQueryUrl = endpoint;

    for (var param in queryParams.entries) {
      if(_hasIdInUrlAlready(requestQueryUrl, param)){
        continue;
      }

      requestQueryUrl += getJoiningChar(requestQueryUrl) + param.key + '=' + param.value;
    }

    return requestQueryUrl;
  }

  bool get hasHeaders => headers != null && headers.isNotEmpty;

  bool get hasFormContent => formBody != null;

  bool get shouldAuthorize => authorization != null && !authorization.isDefault;

  bool get shouldValidateResponse => validationDelegate != null;

  bool get hasValidExceptionCallback => callback != null && callback.unhandledExceptionCallback != null;

  bool get hasValidCallbacks => hasValidExceptionCallback && callback.responseCallback != null && callback.onReceiveProgress != null && callback.onSendProgress != null;

  bool get isRequestExecutable => !isNullOrEmpty(endpoint) || httpMethod != null;
}
