import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Templates & Parts', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list templates (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.templates.list(ListTemplatesRequest(perPage: 5));
      expect(res.code, anyOf(200, 401));
    });

    test('list template parts (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res =
          await client.templateParts.list(ListTemplatePartsRequest(perPage: 5));
      expect(res.code, anyOf(200, 401));
    });
  });
}
