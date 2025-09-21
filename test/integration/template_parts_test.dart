import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Template Parts', () {
    TestConfig? cfg;
    setUpAll(() async => cfg = await TestConfig.tryLoad());

    test('list template parts (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res =
          await client.templateParts.list(ListTemplatePartsRequest(perPage: 5));
      // Some sites may require auth or have none available
      expect(res.code, anyOf(200, 401));
      if (res.code == 200) {
        expect(res.asSuccess().data.length, lessThanOrEqualTo(5));
      }
    });
  });
}
