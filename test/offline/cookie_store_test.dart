import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/src/authorization/methods/cookie_store.dart';
import 'package:wordpress_client/testing.dart';

void main() {
  test('keeps Set-Cookie values per host and sends them back', () async {
    final adapter = MockWordpressAdapter()
      ..reply(
        'POST',
        '/token',
        const MockResponse(
          body: {'ok': true},
          headers: {
            'set-cookie': 'refresh_token=abc; Path=/; HttpOnly; Secure',
          },
        ),
      )
      ..reply('GET', '/me', const MockResponse(body: {}));
    final store = CookieStore();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(store);

    await dio.post<dynamic>('https://example.com/token');
    expect(store.cookiesFor(Uri.parse('https://example.com')), {
      'refresh_token': 'abc',
    });

    await dio.get<dynamic>('https://example.com/me');
    expect(adapter.lastRequest!.headers['Cookie'], 'refresh_token=abc');

    await dio.get<dynamic>('https://other.com/me');
    expect(adapter.lastRequest!.headers['Cookie'], isNull);
  });

  test('an expired cookie is removed', () async {
    final adapter = MockWordpressAdapter()
      ..reply(
        'POST',
        '/logout',
        const MockResponse(
          body: {},
          headers: {'set-cookie': 'refresh_token=; Max-Age=0'},
        ),
      );
    final store = CookieStore();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(store);
    store.onResponse(
      Response(
        requestOptions: RequestOptions(path: 'https://example.com/a'),
        headers: Headers.fromMap({
          'set-cookie': ['refresh_token=abc'],
        }),
      ),
      ResponseInterceptorHandler(),
    );

    await dio.post<dynamic>('https://example.com/logout');

    expect(store.cookiesFor(Uri.parse('https://example.com')), isEmpty);
  });
}
