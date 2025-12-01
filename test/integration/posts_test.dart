import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Posts', () {
    late TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
      if (cfg == null) {
        return; // skip via matcher later
      }
    });

    test('list posts (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return; // effectively skipped when not configured

      final client = await bootstrapClient(cfg!);
      final response = await client.posts.list(ListPostRequest(perPage: 5));
      expect(response.code, 200);
      final items = response.asSuccess().data;
      expect(items.length, lessThanOrEqualTo(5));
    });

    test('retrieve by id via extension (first list item)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final list = await client.posts.list(ListPostRequest(perPage: 1));
      final posts = list.asSuccess().data;
      if (posts.isEmpty) return;
      final one = await client.posts.extensions.getById(posts.first.id);
      final post = one.asSuccess().data;
      expect(post.id, posts.first.id);
    });
  });
}
