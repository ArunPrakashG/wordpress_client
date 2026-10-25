import 'dart:convert';

import '../library_exports.dart';

/// Receives one formatted log line.
typedef LogSink = void Function(String line);

/// Logs every request and response that passes through the client.
///
/// Credentials never reach the log: the values of [redactedHeaders]
/// (`Authorization`, `Cookie`, ... by default) are replaced with `***`, and
/// query values of [redactedQueryKeys] likewise.
///
/// ```dart
/// WordpressClient.forSite(
///   siteUrl: siteUrl,
///   bootstrapper: (b) => b
///       .withMiddleware(LoggingMiddleware(sink: myLogger.info))
///       .build(),
/// );
/// // GET /wp-json/wp/v2/posts?per_page=5 -> 200 in 143 ms
/// ```
final class LoggingMiddleware extends IWordpressMiddleware {
  /// Creates a logging middleware writing to [sink] (default: `print`).
  const LoggingMiddleware({
    this.sink = _print,
    this.logRequests = false,
    this.logHeaders = false,
    this.logBodies = false,
    this.maxBodyLength = 500,
    this.redactedHeaders = const {
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'proxy-authorization',
    },
    this.redactedQueryKeys = const {'password', 'token', 'key', 'secret'},
  });

  /// Where lines are written.
  final LogSink sink;

  /// Also log a line when a request starts. Off by default: the response line
  /// already carries the method and URL.
  final bool logRequests;

  /// Include request and response headers (redacted).
  final bool logHeaders;

  /// Include request and response bodies, cut at [maxBodyLength].
  final bool logBodies;

  /// Bodies longer than this many characters are truncated.
  final int maxBodyLength;

  /// Header names (case-insensitive) whose values are hidden.
  final Set<String> redactedHeaders;

  /// Query keys whose values are hidden.
  final Set<String> redactedQueryKeys;

  @override
  String get name => 'LoggingMiddleware';

  @override
  Future<void> onLoad() async {}

  @override
  Future<void> onUnload() async {}

  @override
  Future<WordpressRequest> onRequest(WordpressRequest request) async {
    if (logRequests) {
      final buffer = StringBuffer('-> ${_describe(request.extra, null)}');
      if (logHeaders) {
        buffer.write('\n   headers: ${_redactHeaders(request.headers)}');
      }
      if (logBodies && request.body != null) {
        buffer.write('\n   body: ${_truncate(request.body)}');
      }
      sink(buffer.toString());
    }

    return request;
  }

  @override
  Future<WordpressRawResponse> onResponse(WordpressRawResponse response) async {
    final buffer = StringBuffer(_describe(response.extra, response));

    if (logHeaders) {
      buffer
        ..write('\n   request headers: ')
        ..write(_redactHeaders(response.requestHeaders))
        ..write('\n   response headers: ')
        ..write(_redactHeaders(response.headers));
    }
    if (logBodies && response.data != null) {
      buffer.write('\n   body: ${_truncate(response.data)}');
    }

    sink(buffer.toString());
    return response;
  }

  String _describe(Map<String, dynamic> extra, WordpressRawResponse? response) {
    final method =
        (extra[WordpressRequest.metaMethod] as String? ?? '?').toUpperCase();
    final url = extra[WordpressRequest.metaUrl] as String? ?? '?';
    final query = _redactQuery(extra[WordpressRequest.metaQuery] as String?);
    final target = query.isEmpty ? url : '$url?$query';

    if (response == null) {
      return '$method $target';
    }

    final status = response.code < 0
        ? 'ERR ${RequestErrorType.values[-response.code % RequestErrorType.values.length].name}'
        : '${response.code}';
    final attempts = response.extra[WordpressRequest.metaAttempts];
    final cache = _header(response.headers, 'x-cache');

    return '$method $target -> $status in ${response.duration.inMilliseconds} ms'
        '${attempts is int && attempts > 1 ? ' ($attempts attempts)' : ''}'
        '${cache != null ? ' [$cache]' : ''}';
  }

  String _redactQuery(String? query) {
    if (query == null || query.isEmpty) {
      return '';
    }

    return query.split('&').map((pair) {
      final index = pair.indexOf('=');
      if (index < 0) {
        return pair;
      }

      final key = pair.substring(0, index);
      return redactedQueryKeys.contains(key.toLowerCase()) ? '$key=***' : pair;
    }).join('&');
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic>? headers) {
    return {
      for (final e in (headers ?? const <String, dynamic>{}).entries)
        e.key: redactedHeaders.contains(e.key.toLowerCase()) ? '***' : e.value,
    };
  }

  static String? _header(Map<String, dynamic> headers, String name) {
    for (final e in headers.entries) {
      if (e.key.toLowerCase() == name) {
        final value = e.value;
        return value is List ? value.join(',') : '$value';
      }
    }

    return null;
  }

  String _truncate(Object? body) {
    final text = body is String ? body : _tryEncode(body);
    return text.length <= maxBodyLength
        ? text
        : '${text.substring(0, maxBodyLength)}… (${text.length} chars)';
  }

  static String _tryEncode(Object? body) {
    try {
      return jsonEncode(body);
    } catch (_) {
      return '${body.runtimeType}';
    }
  }
}

// ignore: avoid_print
void _print(String line) => print(line);
