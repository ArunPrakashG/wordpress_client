import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Metadata: types/taxonomies/statuses/themes/widget types', () {
    TestConfig? cfg;
    setUpAll(() async => cfg = await TestConfig.tryLoad());

    test('post types list', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.types.request(ListTypeRequest());
      expect(res.code, 200);
    });

    test('taxonomies list', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.taxonomies.request(ListTaxonomyRequest());
      expect(res.code, 200);
    });

    test('statuses list', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.statuses.request(ListStatusRequest());
      expect(res.code, 200);
    });

    test('themes list', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.themes.list(ListThemeRequest());
      expect(res.code, anyOf(200, 401));
    });

    test('widget types list', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.widgetTypes.list(ListWidgetTypesRequest());
      expect(res.code, anyOf(200, 401));
    });
  });
}
