import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Blocks & Block Types', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list block types (perPage unsupported => expect 200/401)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.blockTypes.list(ListBlockTypeRequest());
      expect(res.code, anyOf(200, 401));
    });

    test('list blocks (perPage=2) (requires auth on some sites)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.blocks.list(ListBlockRequest(perPage: 2));
      expect(res.code, anyOf(200, 401, 403));
    });
  });
}
