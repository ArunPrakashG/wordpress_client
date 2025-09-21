import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Settings', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('get settings (singleton)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.settings.retrieve(RetrieveSettingsRequest());
      expect(res.code, 200);
      final st = res.asSuccess().data;
      expect(st.url, isNotEmpty);
    });

    test('update settings (title roundtrip)', () async {
      cfg ??= await TestConfig.tryLoad();
      // Need auth to update settings
      if (cfg == null) return;
      if ((cfg!.appPassword == null) &&
          (cfg!.username == null || cfg!.password == null)) {
        // No credentials configured; skip/no-op
        return;
      }

      final client = await bootstrapClient(cfg!);
      // Read current settings
      final getRes = await client.settings.retrieve(RetrieveSettingsRequest());
      expect(getRes.code, anyOf(200, 401));
      if (getRes.code != 200) return; // unauthenticated environment
      final original = getRes.asSuccess().data;

      // Choose a new temporary title
      final tempTitle =
          'WP Client Test ${DateTime.now().millisecondsSinceEpoch}';

      try {
        // Update title
        final upd = await client.settings.update(
          UpdateSettingsRequest(title: tempTitle),
        );
        expect(upd.code, 200);
        final updated = upd.asSuccess().data;
        expect(updated.title, tempTitle);

        // Retrieve again to confirm persisted
        final check = await client.settings.retrieve(RetrieveSettingsRequest());
        expect(check.code, 200);
        expect(check.asSuccess().data.title, tempTitle);
      } finally {
        // Restore original title to avoid polluting the site
        try {
          await client.settings.update(
            UpdateSettingsRequest(title: original.title),
          );
        } catch (_) {
          // Best-effort restore; ignore errors
        }
      }
    });
  });
}
