import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Pages', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list pages (perPage=3)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.pages.list(ListPageRequest(perPage: 3));
      expect(res.code, 200);
      expect(res.asSuccess().data.length, lessThanOrEqualTo(3));
    });
  });
}
