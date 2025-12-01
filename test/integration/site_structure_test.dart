import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Menus / Navigations / Widgets', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list classic menus', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.menus.list(ListNavMenuRequest(perPage: 5));
      expect(res.code, anyOf(200, 401));
    });

    test('list menu locations', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.menuLocations.list(ListMenuLocationRequest());
      expect(res.code, anyOf(200, 401));
    });

    test('list navigations (site editor)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res =
          await client.navigations.list(ListNavigationsRequest(perPage: 5));
      expect(res.code, anyOf(200, 401));
    });

    test('list sidebars and widgets', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final sidebars = await client.sidebars.list(ListSidebarsRequest());
      expect(sidebars.code, anyOf(200, 401));
      final widgets = await client.widgets.list(ListWidgetsRequest());
      expect(widgets.code, anyOf(200, 401));
    });
  });
}
