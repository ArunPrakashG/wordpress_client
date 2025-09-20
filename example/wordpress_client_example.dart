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
        // Example: set a default authorization (choose one)
        // .withDefaultAuthorization(
        //   AppPasswordAuth(userName: 'user', password: 'app-password'),
        // )
        // .withDefaultAuthorization(
        //   UsefulJwtAuth(userName: 'user', password: 'pass', device: 'my-device-id'),
        // )
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

  // --- Composite ID examples ---
  // Block Types use a composite identifier: (namespace, name)
  final blockTypeResp =
      await client.blockTypes.extensions.getById(('core', 'paragraph'));
  blockTypeResp.map(
    onSuccess: (s) => print('Block type: ${s.data.name}'),
    onFailure: (f) => print('Failed to get block type: ${f.error}'),
  );

  // Template Revisions use (parentId, revisionId) as a composite key
  final templateRevResp =
      await client.templateRevisions.extensions.getById((123, 456));
  templateRevResp.map(
    onSuccess: (s) => print('Template revision id: ${s.data.id}'),
    onFailure: (f) => print('Failed to get template revision: ${f.error}'),
  );

  // Template Part Revisions also use (parentId, revisionId)
  final tpartRevResp =
      await client.templatePartRevisions.extensions.getById((789, 55));
  tpartRevResp.map(
    onSuccess: (s) => print('Template part revision id: ${s.data.id}'),
    onFailure: (f) => print('Failed to get template part revision: ${f.error}'),
  );
}
