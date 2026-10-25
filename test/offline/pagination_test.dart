import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

Map<String, dynamic> post(int id) => {...onePost, 'id': id};

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..on('GET', '/posts', (req) {
        final page = int.parse('${req.uri.queryParameters['page']}');

        return switch (page) {
          1 => MockResponse.paged([post(1), post(2)], total: 5, totalPages: 3),
          2 => MockResponse.paged([post(3), post(4)], total: 5, totalPages: 3),
          3 => MockResponse.paged([post(5)], total: 5, totalPages: 3),
          _ => MockResponse.wpError(
              statusCode: 400,
              code: 'rest_post_invalid_page_number',
            ),
        };
      });
  });

  group('auto-pagination (#97)', () {
    test('listAll collects every page', () async {
      final client = makeClient(adapter);

      final response = await client.posts.listAll(ListPostRequest());

      expect(response, isA<WordpressSuccessResponse<List<Post>>>());
      final ok = response as WordpressSuccessResponse<List<Post>>;
      expect(ok.data.map((p) => p.id), [1, 2, 3, 4, 5]);
      expect(ok.totalCount, 5);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 3);
    });

    test('listPages is lazy and sends page / per_page', () async {
      final client = makeClient(adapter);

      final first =
          await client.posts.listPages(ListPostRequest(), perPage: 2).first;

      expect(first.isSuccessful, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
      final query = adapter.lastRequest!.uri.queryParameters;
      expect(query['page'], '1');
      expect(query['per_page'], '2');
    });

    test('maxPages bounds the walk', () async {
      final client = makeClient(adapter);

      final pages =
          await client.posts.listPages(ListPostRequest(), maxPages: 2).toList();

      expect(pages, hasLength(2));
    });

    test('maxItems trims the result', () async {
      final client = makeClient(adapter);

      final response = await client.posts.listAll(
        ListPostRequest(),
        maxItems: 3,
      );

      final ok = response as WordpressSuccessResponse<List<Post>>;
      expect(ok.data.map((p) => p.id), [1, 2, 3]);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
    });

    test('a failing page ends the walk and is returned', () async {
      adapter.replySequence('GET', '/posts', [
        MockResponse.paged([post(1)], total: 2, totalPages: 2),
        MockResponse.wpError(statusCode: 500, code: 'boom'),
      ]);
      final client = makeClient(adapter);

      final response = await client.posts.listAll(ListPostRequest());

      expect(response.isFailure, isTrue);
    });

    test('stops on a short page when the server sends no total', () async {
      adapter.replySequence('GET', '/posts', const [
        MockResponse(body: [onePost, onePost]),
        MockResponse(body: [onePost]),
      ]);
      final client = makeClient(adapter);

      final pages =
          await client.posts.listPages(ListPostRequest(), perPage: 2).toList();

      expect(pages, hasLength(2));
    });
  });
}
