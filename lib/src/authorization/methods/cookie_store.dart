import 'package:dio/dio.dart';

/// A minimal in-memory cookie store for the JWT refresh flow.
///
/// It remembers `Set-Cookie` values per host and sends them back on later
/// requests to that host. Browsers manage cookies themselves (and hide
/// `Set-Cookie` from scripts), so on the web this is a no-op.
final class CookieStore extends Interceptor {
  final Map<String, Map<String, String>> _byHost = {};

  /// The cookies stored for the host of [uri], by name.
  Map<String, String> cookiesFor(Uri uri) =>
      Map.unmodifiable(_byHost[uri.host] ?? const <String, String>{});

  /// Forgets every cookie.
  void clear() => _byHost.clear();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookies = _byHost[options.uri.host];
    if (cookies != null && cookies.isNotEmpty) {
      final sent = [
        for (final entry in cookies.entries) '${entry.key}=${entry.value}',
      ].join('; ');
      final existing = options.headers['cookie'] ?? options.headers['Cookie'];
      options.headers['Cookie'] = existing == null ? sent : '$existing; $sent';
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _store(response.requestOptions.uri, response.headers['set-cookie']);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _store(err.requestOptions.uri, err.response?.headers['set-cookie']);
    handler.next(err);
  }

  void _store(Uri uri, List<String>? setCookies) {
    if (setCookies == null) {
      return;
    }

    final cookies = _byHost.putIfAbsent(uri.host, () => {});
    for (final header in setCookies) {
      final pair = header.split(';').first;
      final index = pair.indexOf('=');
      if (index <= 0) {
        continue;
      }

      final name = pair.substring(0, index).trim();
      final value = pair.substring(index + 1).trim();
      final expired = RegExp('max-age=0|expires=thu, 01 jan 1970')
          .hasMatch(header.toLowerCase());

      if (expired || value.isEmpty) {
        cookies.remove(name);
      } else {
        cookies[name] = value;
      }
    }
  }
}
