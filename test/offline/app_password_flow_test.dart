import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

WordpressDiscovery discovery() {
  return WordpressDiscovery.fromJson(const {
    'name': 'Site',
    'url': 'https://example.com',
    'home': 'https://example.com',
    'authentication': {
      'application-passwords': {
        'endpoints': {
          'authorization':
              'https://example.com/wp-admin/authorize-application.php',
        },
      },
    },
  });
}

void main() {
  AppPasswordFlow flow() => AppPasswordFlow.fromDiscovery(
        discovery(),
        appName: 'My App',
        successUrl: Uri.parse('myapp://callback'),
        rejectUrl: Uri.parse('myapp://rejected'),
      );

  group('AppPasswordFlow', () {
    test('builds the authorize URL with state on both redirect URLs', () {
      final f = flow();
      final url = f.authorizeUrl;

      expect(url.path, '/wp-admin/authorize-application.php');
      expect(url.queryParameters['app_name'], 'My App');
      expect(url.queryParameters['app_id'], f.appId);
      expect(f.appId, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(
        Uri.parse(url.queryParameters['success_url']!).queryParameters['state'],
        f.state,
      );
      expect(
        Uri.parse(url.queryParameters['reject_url']!).queryParameters['state'],
        f.state,
      );
    });

    test('parses a granted callback into credentials', () {
      final f = flow();
      final result = f.parseCallback(
        Uri.parse(
          'myapp://callback?state=${f.state}&site_url=https%3A%2F%2Fexample.com'
          '&user_login=admin&password=abcd+efgh',
        ),
      );

      expect(result, isA<AppPasswordGranted>());
      final granted = result as AppPasswordGranted;
      expect(granted.userLogin, 'admin');
      expect(granted.password, 'abcd efgh');
      expect(granted.toAuthorization().isValidAuth, isTrue);
    });

    test('reports a rejection', () {
      final f = flow();
      final callback =
          Uri.parse('myapp://rejected?state=${f.state}&success=false');

      expect(f.parseCallback(callback), isA<AppPasswordRejected>());
    });

    test('refuses callbacks with a wrong state, wrong site or no password', () {
      final f = flow();

      expect(
        () => f.parseCallback(
          Uri.parse('myapp://callback?state=nope&user_login=a&password=b'),
        ),
        throwsFormatException,
      );
      expect(
        () => f.parseCallback(
          Uri.parse(
            'myapp://callback?state=${f.state}&site_url=https%3A%2F%2Fevil.test'
            '&user_login=a&password=b',
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => f.parseCallback(Uri.parse('myapp://callback?state=${f.state}')),
        throwsFormatException,
      );
    });

    test('fromDiscovery fails when the site has no application passwords', () {
      final bare = WordpressDiscovery.fromJson(const {
        'name': 'Site',
        'url': 'https://example.com',
        'home': 'https://example.com',
      });

      expect(
        () => AppPasswordFlow.fromDiscovery(
          bare,
          appName: 'x',
          successUrl: Uri.parse('myapp://cb'),
        ),
        throwsStateError,
      );
    });
  });
}
