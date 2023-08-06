import 'package:dio/dio.dart';

import '../../authorization.dart';
import '../constants.dart';
import '../enums.dart';
import '../utilities/request_url.dart';
import '../utilities/typedefs.dart';
import '../utilities/wordpress_events.dart';
import '../wordpress_client_base.dart';

/// Wraps over all requests to be send from this [WordpressClient] instance.
final class WordpressRequest {
  const WordpressRequest({
    required this.url,
    required this.method,
    this.headers = const {},
    this.queryParams = const {},
    this.body,
    this.events,
    this.cancelToken,
    this.requireAuth = false,
    this.authorization,
    this.validator,
    this.sendTimeout = kDefaultRequestTimeout,
    this.receiveTimeout = kDefaultRequestTimeout,
  });

  final RequestUrl url;
  final HttpMethod method;
  final Map<String, String> headers;
  final Map<String, String> queryParams;
  final dynamic body;
  final bool requireAuth;
  final CancelToken? cancelToken;
  final IAuthorization? authorization;
  final Duration sendTimeout;
  final Duration receiveTimeout;
  final WordpressEvents? events;
  final ValidatorCallback? validator;

  bool get hasEvents => events != null;
  bool get hasValidator => validator != null;
  bool get hasAuthorization => authorization != null;
}
