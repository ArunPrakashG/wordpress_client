import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() {
  late MockWordpressAdapter adapter;
  late WordpressClient network;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply('GET', RegExp('/posts'), const MockResponse(body: []))
      ..reply('POST', RegExp('/posts'), MockResponse.connectionError());
    network = WordpressClient.fromDioInstance(
      baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
      instance: Dio()..httpClientAdapter = adapter,
      bootstrapper: (b) => b
          .withDefaultAuthorization(
            WordpressAuth.appPassword(user: 'admin', appPassword: 'pw'),
          )
          .withDefaultHeaders({'X-App': 'demo'})
          .withMiddleware(OfflineWriteQueue(store: MemoryWriteQueueStore()))
          .build(),
    );
  });

  test('siteUrl strips the REST path', () {
    expect(network.siteUrl.toString(), 'https://example.com');
    final blog = WordpressClient(
      baseUrl: Uri.parse('https://example.com/blog/wp-json/wp/v2'),
    );
    expect(blog.siteUrl.toString(), 'https://example.com/blog');
  });

  test('a sub-directory site gets the same settings, no credentials', () async {
    final shop = network.forNetworkSite(Uri.parse('/shop/'));

    expect(shop.baseUrl.toString(), 'https://example.com/shop/wp-json/wp/v2');
    await shop.posts.list(ListPostRequest());

    final request = adapter.lastRequest!;
    expect(request.uri.path, '/shop/wp-json/wp/v2/posts');
    expect(request.headers['X-App'], 'demo');
    expect(request.headers.containsKey('Authorization'), isFalse);

    // The offline queue belongs to the network client only.
    final write = await shop.posts.create(CreatePostRequest(title: 'A'));
    expect(write.wasQueued, isFalse);
  });

  test('a sub-domain site with its own credentials', () async {
    final blog = network.forNetworkSite(
      Uri.parse('https://blog.example.com'),
      bootstrapper: (b) => b
          .withDefaultAuthorization(
            WordpressAuth.appPassword(user: 'editor', appPassword: 'pw2'),
          )
          .build(),
    );

    await blog.posts.list(
      ListPostRequest(requireAuth: true),
    );
    final request = adapter.lastRequest!;
    expect(request.uri.host, 'blog.example.com');
    expect(request.headers['Authorization'], startsWith('Basic '));
    expect(request.headers['X-App'], 'demo');
  });

  test('the original client is unchanged', () async {
    network.forNetworkSite(Uri.parse('/shop/'));
    await network.posts.list(ListPostRequest(requireAuth: true));

    final request = adapter.lastRequest!;
    expect(request.uri.path, '/wp-json/wp/v2/posts');
    expect(request.headers['Authorization'], startsWith('Basic '));
    final write = await network.posts.create(CreatePostRequest(title: 'A'));
    expect(write.wasQueued, isTrue);
  });
}
