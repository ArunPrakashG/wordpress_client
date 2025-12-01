import 'dart:convert';
import 'dart:io';

import 'package:wordpress_client/wordpress_client.dart';

class TestConfig {
  TestConfig({
    required this.baseUrl,
    this.username,
    this.password,
    this.appPassword,
  });
  final Uri baseUrl;
  final String? username;
  final String? password;
  final String? appPassword;

  static Future<TestConfig?> tryLoad() async {
    // Prefer test/test_local.json if present; else fall back to test_settings.json
    final candidates = [
      'test/test_local.json',
    ];

    for (final path in candidates) {
      final f = File(path);
      if (f.existsSync()) {
        final json = jsonDecode(f.readAsStringSync());
        final baseUrlStr = (json['base_url'] ?? json['baseUrl']) as String?;
        if (baseUrlStr == null) continue;

        return TestConfig(
          baseUrl: Uri.parse(
            baseUrlStr.endsWith('/wp/v2')
                ? baseUrlStr
                : baseUrlStr.endsWith('/wp-json')
                    ? '$baseUrlStr/wp/v2'
                    : '$baseUrlStr/wp-json/wp/v2',
          ),
          username: json['username'] as String?,
          password: json['password'] as String?,
          appPassword: json['application_password'] as String?,
        );
      }
    }

    // Env var override
    final env = Platform.environment;
    final base = env['WP_BASE_URL'];
    if (base != null) {
      return TestConfig(
        baseUrl: Uri.parse(base),
        username: env['WP_USERNAME'],
        password: env['WP_PASSWORD'],
        appPassword: env['WP_APP_PASSWORD'],
      );
    }

    return null;
  }
}

Future<WordpressClient> bootstrapClient(TestConfig cfg) async {
  return WordpressClient(
    baseUrl: cfg.baseUrl,
    bootstrapper: (b) {
      b = b.withRequestTimeout(const Duration(seconds: 30));
      // Only set default authorization if provided
      if (cfg.appPassword != null) {
        b = b.withDefaultAuthorization(
          WordpressAuth.appPassword(
            user: cfg.username ?? 'admin',
            appPassword: cfg.appPassword!,
          ),
        );
      } else if (cfg.username != null && cfg.password != null) {
        // Local Docker stack installs the classic JWT plugin (Tmeister).
        // Use BasicJwt for compatibility with its token response shape.
        b = b.withDefaultAuthorization(
          WordpressAuth.basicJwt(
            user: cfg.username!,
            password: cfg.password!,
          ),
        );
      }
      return b.build();
    },
  );
}

/// Quick probe to check if the site is reachable and REST index is available.
Future<bool> isRestReachable(Uri baseUrl) async {
  try {
    final client = HttpClient();
    final req = await client.getUrl(
      baseUrl.replace(path: baseUrl.path.replaceAll(RegExp(r'/+$'), '')),
    );
    final res = await req.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}
