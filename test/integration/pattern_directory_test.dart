import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Pattern Directory Items', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list patterns (search=hero, perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);

      final res = await client.patternDirectory.list(
        ListPatternDirectoryItemsRequest(
          search: 'hero',
          perPage: 5,
        ),
      );

      // Unauthenticated-friendly; ensure endpoint behaves (either 200 or unauth codes on some sites)
      expect(res.code, anyOf(200, 401, 403));
      if (res.code == 200) {
        final data = res.asSuccess().data;
        expect(data, isA<List<PatternDirectoryItem>>());
        expect(data.length, greaterThanOrEqualTo(0));
      }
    });
  });
}
