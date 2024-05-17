// ignore_for_file: avoid_print, unused_local_variable

import 'package:wordpress_client/wordpress_client.dart';

import 'auth_middleware.dart';

Future<void> main() async {
  final baseUrl = Uri.parse('https://example.com/wp-json/wp/v2');

  // Simple Usage
  final client = WordpressClient(
    baseUrl: baseUrl,
    bootstrapper: (bootstrapper) => bootstrapper
        .withDebugMode(true)
        .withMiddleware(AuthMiddleware())
        .withMiddleware(
          DelegatedMiddleware(
            onRequestDelegate: (request) async {
              return request.copyWith(
                headers: {
                  'X-My-Custom-Header': 'My Custom Value',
                },
              );
            },
            onResponseDelegate: (response) async {
              return response;
            },
          ),
        )
        .build(),
  );

  final response = await client.posts.list(
    ListPostRequest(
      perPage: 1,
      order: Order.asc,
    ),
  );

  response.map<void>(
    onSuccess: (response) {
      print('Posts Count: ${response.data.length}');
      // prints Posts Count: 1, as expected
    },
    onFailure: (response) {
      print(response.error);
    },
  );
}
