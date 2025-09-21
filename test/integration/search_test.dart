import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Search', () {
    TestConfig? cfg;
    setUpAll(() async => cfg = await TestConfig.tryLoad());

    test('search for "hello" (perPage=1)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.search
          .list(ListSearchRequest(search: 'hello', perPage: 1));
      expect(res.code, 200);
      // May be empty on a fresh site, but the shape should decode
      expect(res.asSuccess().data.length, lessThanOrEqualTo(1));
    });
  });
}
