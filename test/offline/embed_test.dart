import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;

  setUp(() => adapter = MockWordpressAdapter());

  Map<String, dynamic> embeddedPost() => {
        ...onePost,
        '_embedded': {
          'author': [
            {
              'id': 7,
              'name': 'Ada',
              'slug': 'ada',
              'url': '',
              'description': '',
              'link': 'https://example.com/author/ada/',
              'avatar_urls': {'24': 'a', '48': 'b', '96': 'c'},
            },
          ],
          'wp:featuredmedia': [
            {'id': 9, 'source_url': 'https://example.com/a.jpg'},
          ],
          'wp:term': [
            [
              {'id': 3, 'name': 'News', 'slug': 'news', 'taxonomy': 'category'},
            ],
            [
              {
                'id': 5,
                'name': 'Dart',
                'link': 'https://example.com/tag/dart/',
                'slug': 'dart',
                'taxonomy': 'post_tag',
              },
              {
                'code': 'rest_term_invalid',
                'message': 'gone',
                'data': {'status': 404},
              },
            ],
          ],
        },
      };

  test('withEmbed / withFields set _embed and _fields', () async {
    adapter.reply(
      'GET',
      '/posts',
      MockResponse.paged([embeddedPost()], total: 1, totalPages: 1),
    );
    final client = makeClient(adapter);

    await client.posts.query
        .withEmbed(['author', 'wp:term']).withFields(['id', 'title']).execute();
    await client.posts.query.withEmbed().execute();

    final first = adapter.requests.first.uri.queryParameters;
    expect(first['_embed'], 'author,wp:term');
    expect(first['_fields'], 'id,title');
    expect(adapter.requests.last.uri.queryParameters['_embed'], 'true');
  });

  test('embedded exposes typed author, media, categories and tags', () async {
    adapter.reply(
      'GET',
      '/posts',
      MockResponse.paged([embeddedPost()], total: 1, totalPages: 1),
    );
    final client = makeClient(adapter);

    final post =
        (await client.posts.query.withEmbed().execute()).dataOrThrow().first;
    final embedded = post.embedded;

    expect(embedded.isPresent, isTrue);
    expect(embedded.author?.name, 'Ada');
    expect(embedded.featuredMedia?.id, 9);
    expect(embedded.categories.map((c) => c.slug), ['news']);
    expect(embedded.tags.map((t) => t.slug), ['dart']);
    expect(embedded.terms('post_tag'), hasLength(1));
  });

  test('getAuthor and getMedia use embedded data without a request', () async {
    adapter.reply(
      'GET',
      '/posts',
      MockResponse.paged([embeddedPost()], total: 1, totalPages: 1),
    );
    final client = makeClient(adapter);
    final post =
        (await client.posts.query.withEmbed().execute()).dataOrThrow().first;
    adapter.clearRequests();

    expect((await post.getAuthor(client))?.name, 'Ada');
    expect((await post.getMedia(client))?.id, 9);
    expect(adapter.requests, isEmpty);
  });

  test('embedded is empty without _embed', () async {
    adapter.reply(
      'GET',
      '/posts',
      MockResponse.paged([onePost], total: 1, totalPages: 1),
    );
    final client = makeClient(adapter);

    final post =
        (await client.posts.list(ListPostRequest())).dataOrThrow().first;

    expect(post.embedded.isPresent, isFalse);
    expect(post.embedded.author, isNull);
    expect(post.embedded.categories, isEmpty);
  });
}
