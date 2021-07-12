import 'package:wordpress_client/wordpress_client.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    WordpressClient client;

    test('First Test', () {
      client.withDefaultUserAgent('');
      client.fetchPosts((builder) => builder.withPageNumber(2).build());
    });
  });
}
