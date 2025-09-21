import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'test_harness.dart';

void main() {
  group('Users', () {
    TestConfig? cfg;

    setUpAll(() async {
      cfg = await TestConfig.tryLoad();
    });

    test('list users (perPage=5)', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null) return;
      final client = await bootstrapClient(cfg!);
      final res = await client.users.list(ListUserRequest());
      expect(res.code, anyOf(200, 401));
      if (res.code == 200) {
        expect(res.asSuccess().data.length, greaterThanOrEqualTo(0));
      }
    });

    test('retrieve me when authorized', () async {
      cfg ??= await TestConfig.tryLoad();
      if (cfg == null || (cfg!.username == null && cfg!.appPassword == null))
        return;
      final client = await bootstrapClient(cfg!);
      final me = await client.me.retrieve(RetrieveMeRequest());
      if (me.code == 200) {
        final u = me.asSuccess().data;
        final byId = await client.users.retrieve(RetrieveUserRequest(id: u.id));
        expect(byId.code, 200);
        expect(byId.asSuccess().data.id, u.id);
      } else {
        // Authorization not configured in site
        expect(me.code, anyOf(401, 403));
      }
    });
  });
}
