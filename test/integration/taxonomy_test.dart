import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Categories & Tags', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list categories (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.categories.list(ListCategoryRequest(perPage: 5));
      expect(res.code, 200);
      expect(res.asSuccess().data.length, lessThanOrEqualTo(5));
    });

    test('list tags (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.tags.list(ListTagRequest(perPage: 5));
      expect(res.code, 200);
      expect(res.asSuccess().data.length, lessThanOrEqualTo(5));
    });
  });
}
