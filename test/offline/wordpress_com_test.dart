import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() {
  final base =
      Uri.parse('https://public-api.wordpress.com/wp/v2/sites/example.blog');

  test('forWordpressCom builds the site API base from a domain or URL', () {
    expect(
      WordpressClient.forWordpressCom(site: 'example.blog').baseUrl,
      base,
    );
    final fromUrl =
        WordpressClient.forWordpressCom(site: 'https://example.blog/');
    expect(fromUrl.baseUrl, base);
    expect(fromUrl.siteUrl.toString(), 'https://example.blog');
    expect(
      () => WordpressClient.forWordpressCom(site: ''),
      throwsArgumentError,
    );
  });

  test('a bearer token is sent and plugin namespaces route per site', () async {
    final adapter = MockWordpressAdapter()
      ..reply('GET', RegExp('.*'), const MockResponse(body: []));
    final client = WordpressClient.fromDioInstance(
      baseUrl: base,
      instance: Dio()..httpClientAdapter = adapter,
      bootstrapper: (b) =>
          b.withDefaultAuthorization(WordpressAuth.bearer('tok123')).build(),
    );

    await client.posts.list(ListPostRequest(requireAuth: true));
    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer tok123');
    expect(
      adapter.lastRequest!.uri.path,
      '/wp/v2/sites/example.blog/posts',
    );

    await client
        .resource<Map<String, dynamic>>(
          'subscribers',
          namespace: 'wpcom/v2',
          decoder: (json) => json,
        )
        .list();
    expect(
      adapter.lastRequest!.uri.path,
      '/wpcom/v2/sites/example.blog/subscribers',
    );
  });

  group('WordpressComOAuth', () {
    test('authorizeUrl carries the app details', () {
      final url = WordpressComOAuth.authorizeUrl(
        clientId: '42',
        redirectUri: Uri.parse('myapp://oauth'),
        responseType: WordpressComResponseType.token,
        blog: 'example.blog',
        state: 'xyz',
      );

      expect(url.host, 'public-api.wordpress.com');
      expect(url.path, '/oauth2/authorize');
      expect(url.queryParameters, {
        'client_id': '42',
        'redirect_uri': 'myapp://oauth',
        'response_type': 'token',
        'blog': 'example.blog',
        'state': 'xyz',
      });
    });

    test('tokenFromRedirect reads the fragment and checks state', () {
      final redirect = Uri.parse(
        'myapp://oauth#access_token=abc%2Bdef&expires_in=1209600'
        '&token_type=bearer&site_id=7&state=xyz',
      );

      final token = WordpressComOAuth.tokenFromRedirect(
        redirect,
        expectedState: 'xyz',
      );
      expect(token!.accessToken, 'abc+def');
      expect(token.blogId, '7');
      expect(token.expiresIn, const Duration(days: 14));
      expect(token.toString(), isNot(contains('abc')));

      expect(
        WordpressComOAuth.tokenFromRedirect(redirect, expectedState: 'other'),
        isNull,
      );
      expect(
        WordpressComOAuth.tokenFromRedirect(
          Uri.parse('myapp://oauth?error=access_denied'),
        ),
        isNull,
      );
    });

    test('exchangeCode posts the code and reads the token', () async {
      final adapter = MockWordpressAdapter()
        ..reply(
          'POST',
          '/oauth2/token',
          const MockResponse(
            body: {
              'access_token': 'server-token',
              'token_type': 'bearer',
              'blog_id': 7,
              'blog_url': 'https://example.blog',
              'scope': '',
            },
          ),
        );

      final token = await WordpressComOAuth.exchangeCode(
        clientId: '42',
        clientSecret: 'secret',
        redirectUri: Uri.parse('https://app.example/callback'),
        code: 'the-code',
        dio: Dio()..httpClientAdapter = adapter,
      );

      expect(token.accessToken, 'server-token');
      expect(token.blogId, '7');
      expect(token.blogUrl, 'https://example.blog');
      final sent = adapter.lastRequest!;
      expect(sent.uri.host, 'public-api.wordpress.com');
      expect(sent.body, containsPair('grant_type', 'authorization_code'));
      expect(sent.body, containsPair('code', 'the-code'));
      expect(
        '${sent.headers['content-type'] ?? sent.headers['Content-Type']}',
        contains('x-www-form-urlencoded'),
      );
    });
  });
}
