import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Comments', () {
    TestConfig? cfg;
    setUpAll(() async => cfg = await TestConfig.tryLoad());

    test('list comments (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.comments.list(ListCommentRequest(perPage: 5));
      expect(res.code, 200);
      expect(res.asSuccess().data.length, lessThanOrEqualTo(5));
    });

    test('list comments for post id 1 (tolerant)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.comments
          .list(ListCommentRequest(post: const [1], perPage: 3));
      expect(res.code, anyOf(200, 400));
    });
  });
}
