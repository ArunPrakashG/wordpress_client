import 'package:dio/dio.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

final testBaseUrl = Uri.parse('https://example.com/wp-json/wp/v2');

/// Builds a client wired to [adapter], with no network access.
WordpressClient makeClient(
  MockWordpressAdapter adapter, {
  List<IWordpressMiddleware> middlewares = const [],
  IAuthorization? auth,
  Uri? baseUrl,
}) {
  return WordpressClient.fromDioInstance(
    baseUrl: baseUrl ?? testBaseUrl,
    instance: Dio()..httpClientAdapter = adapter,
    bootstrapper: (b) {
      if (middlewares.isNotEmpty) {
        b.withMiddlewares(middlewares);
      }
      if (auth != null) {
        b.withDefaultAuthorization(auth);
      }
      return b.build();
    },
  );
}

const onePost = {
  'id': 1,
  'date': '2024-01-01T00:00:00',
  'slug': 'hello',
  'status': 'publish',
  'type': 'post',
  'title': {'rendered': 'Hello'},
  'content': {'rendered': '', 'protected': false},
  'excerpt': {'rendered': '', 'protected': false},
};
