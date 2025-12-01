import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Media', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list media (perPage=3)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.media.list(ListMediaRequest(perPage: 3));
      expect(res.code, 200);
      expect(res.asSuccess().data.length, lessThanOrEqualTo(3));
    });
  });
}
