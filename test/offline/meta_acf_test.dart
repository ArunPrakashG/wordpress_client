import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;
  late WordpressClient client;

  setUp(() {
    adapter = MockWordpressAdapter();
    client = makeClient(
      adapter,
      auth: WordpressAuth.appPassword(user: 'a', appPassword: 'b'),
    );
  });

  test('meta and acf values read with lenient conversion', () async {
    adapter.reply(
      'GET',
      '/posts/1',
      const MockResponse(
        body: {
          ...onePost,
          'meta': {'rating': '4', 'featured': '1', 'subtitle': 'Hi'},
          'acf': {
            'price': '12.5',
            'stock': 3,
            'launch_date': '20240131',
            'gallery': [1, 2],
            'on_sale': false,
          },
        },
      ),
    );

    final post = (await client.posts.retrieve(RetrievePostRequest(id: 1)))
        .asSuccess()
        .data;

    expect(post.metaValue<int>('rating'), 4);
    expect(post.metaValue<bool>('featured'), isTrue);
    expect(post.metaValue<String>('subtitle'), 'Hi');
    expect(post.metaValue<int>('missing'), isNull);
    expect(post.metaValue<int>('subtitle'), isNull);

    expect(post.acfValue<double>('price'), 12.5);
    expect(post.acfValue<int?>('stock'), 3);
    expect(post.acfValue<String>('stock'), '3');
    expect(post.acfValue<DateTime>('launch_date'), DateTime(2024, 1, 31));
    expect(post.acfValue<List<dynamic>>('gallery'), [1, 2]);
    expect(post.acfValue<bool>('on_sale'), isFalse);
    expect(post.acf, containsPair('stock', 3));
  });

  test('a site without ACF reads as null', () async {
    adapter.reply('GET', '/posts/1', const MockResponse(body: onePost));

    final post = (await client.posts.retrieve(RetrievePostRequest(id: 1)))
        .asSuccess()
        .data;

    expect(post.acf, isNull);
    expect(post.acfValue<int>('price'), isNull);
  });

  test('acf and meta are sent on create and update', () async {
    adapter
      ..reply('POST', '/posts', const MockResponse(body: onePost))
      ..reply('POST', '/pages/2', const MockResponse(body: onePost));

    await client.posts.create(
      CreatePostRequest(
        title: 'A',
        meta: {'rating': 5},
        acf: {'price': 9.99},
      ),
    );
    expect(adapter.lastRequest!.body, containsPair('acf', {'price': 9.99}));
    expect(adapter.lastRequest!.body, containsPair('meta', {'rating': 5}));

    await client.pages.update(
      UpdatePageRequest(
        id: 2,
        slug: 'about',
        title: 'About',
        content: '',
        acf: {'hero': 'Hello'},
      ),
    );
    expect(adapter.lastRequest!.body, containsPair('acf', {'hero': 'Hello'}));
  });
}
