import 'dart:convert';

import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

Map<String, dynamic> ability(
  String name, {
  bool readonly = false,
  bool destructive = false,
}) {
  return {
    'name': name,
    'label': 'Label of $name',
    'description': 'Does something',
    'category': 'site',
    'input_schema': {'type': 'object'},
    'output_schema': {'type': 'object'},
    'meta': {
      'annotations': {
        'readonly': readonly,
        'destructive': destructive,
        'idempotent': readonly || destructive,
      },
      'show_in_rest': true,
    },
  };
}

void main() {
  late MockWordpressAdapter adapter;
  late WordpressClient client;

  const root = '/wp-json/wp-abilities/v1';

  setUp(() {
    adapter = MockWordpressAdapter();
    client = makeClient(
      adapter,
      auth: WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1'),
    );
  });

  group('Abilities API (#99)', () {
    test('lists abilities from the site root with auth', () async {
      adapter.reply(
        'GET',
        '$root/abilities',
        MockResponse.paged(
          [ability('demo/info', readonly: true)],
          total: 1,
          totalPages: 1,
        ),
      );

      final response = await client.abilities.list(category: 'site');

      final ok = response as WordpressSuccessResponse<List<Ability>>;
      expect(ok.data.single.name, 'demo/info');
      expect(ok.data.single.isReadOnly, isTrue);
      expect(ok.data.single.runMethod, 'GET');
      expect(ok.data.single.inputSchema, {'type': 'object'});
      final sent = adapter.lastRequest!;
      expect(sent.path, '$root/abilities');
      expect(sent.uri.queryParameters['category'], 'site');
      expect(sent.headers['Authorization'], startsWith('Basic '));
    });

    test('listAll walks every page', () async {
      adapter.on('GET', '$root/abilities', (req) {
        final page = int.parse(req.uri.queryParameters['page']!);

        return MockResponse.paged(
          [ability('demo/p$page')],
          total: 2,
          totalPages: 2,
        );
      });

      final response = await client.abilities.listAll();

      final ok = response as WordpressSuccessResponse<List<Ability>>;
      expect(ok.data.map((a) => a.name), ['demo/p1', 'demo/p2']);
    });

    test('retrieves one ability by namespaced name', () async {
      adapter.reply(
        'GET',
        '$root/abilities/demo/info',
        MockResponse(body: ability('demo/info')),
      );

      final response = await client.abilities.retrieve('demo/info');

      expect(response, isA<WordpressSuccessResponse<Ability>>());
      expect(adapter.lastRequest!.path, '$root/abilities/demo/info');
    });

    test('a hidden ability is a failure', () async {
      adapter.reply(
        'GET',
        '$root/abilities/demo/hidden',
        MockResponse.wpError(statusCode: 404, code: 'rest_ability_not_found'),
      );

      final response = await client.abilities.retrieve('demo/hidden');

      expect(response.isFailure, isTrue);
    });

    test('lists and retrieves categories', () async {
      adapter
        ..reply(
          'GET',
          '$root/categories',
          const MockResponse(
            body: [
              {'slug': 'site', 'label': 'Site'},
            ],
          ),
        )
        ..reply(
          'GET',
          '$root/categories/site',
          const MockResponse(body: {'slug': 'site', 'label': 'Site'}),
        );

      final list = await client.abilities.categories();
      final one = await client.abilities.category('site');

      expect(
        (list as WordpressSuccessResponse<List<AbilityCategory>>).data.single,
        isA<AbilityCategory>().having((c) => c.slug, 'slug', 'site'),
      );
      expect(
        (one as WordpressSuccessResponse<AbilityCategory>).data.label,
        'Site',
      );
    });

    test('read-only abilities run with GET and JSON input in the query',
        () async {
      adapter
        ..reply(
          'GET',
          '$root/abilities/demo/info',
          MockResponse(body: ability('demo/info', readonly: true)),
        )
        ..reply(
          'GET',
          '$root/abilities/demo/info/run',
          const MockResponse(body: {'name': 'Site'}),
        );

      final response = await client.abilities.run(
        'demo/info',
        input: {'user_id': 1},
      );

      expect((response as WordpressSuccessResponse<dynamic>).data, {
        'name': 'Site',
      });
      final sent = adapter.lastRequest!;
      expect(sent.method, 'GET');
      expect(jsonDecode(sent.uri.queryParameters['input']!), {'user_id': 1});
    });

    test('destructive abilities run with DELETE', () async {
      adapter
        ..reply(
          'GET',
          '$root/abilities/demo/wipe',
          MockResponse(
            body: ability('demo/wipe', destructive: true),
          ),
        )
        ..reply(
          'DELETE',
          '$root/abilities/demo/wipe/run',
          const MockResponse(body: true),
        );

      final response = await client.abilities.run('demo/wipe');

      expect((response as WordpressSuccessResponse<dynamic>).data, true);
      expect(adapter.lastRequest!.method, 'DELETE');
    });

    test('other abilities run with POST and an input body', () async {
      final write = Ability.fromJson(ability('demo/save'));
      adapter.reply(
        'POST',
        '$root/abilities/demo/save/run',
        const MockResponse(body: {'saved': true}),
      );

      final response = await client.abilities.runAbility(
        write,
        input: {'title': 'x'},
      );

      expect(response.isSuccessful, isTrue);
      final sent = adapter.lastRequest!;
      expect(sent.method, 'POST');
      expect(sent.body, {
        'input': {'title': 'x'},
      });
    });

    test('an explicit method skips the lookup', () async {
      adapter.reply(
        'POST',
        '$root/abilities/demo/save/run',
        const MockResponse(),
      );

      await client.abilities.run(
        'demo/save',
        input: 1,
        method: HttpMethod.post,
      );

      expect(adapter.callCount(method: 'GET'), 0);
    });

    test('follows the site prefix of a subdirectory install', () async {
      adapter.reply(
        'GET',
        '/blog/wp-json/wp-abilities/v1/categories',
        const MockResponse(body: []),
      );
      final sub = makeClient(
        adapter,
        auth: WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1'),
        baseUrl: Uri.parse('https://example.com/blog/wp-json/wp/v2'),
      );

      final response = await sub.abilities.categories();

      expect(response.isSuccessful, isTrue);
    });
  });

  test('Ability exposes required_capabilities', () {
    final a = Ability.fromJson({
      ...ability('x/y'),
      'required_capabilities': const ['edit_posts', 'upload_files'],
    });

    expect(a.requiredCapabilities, ['edit_posts', 'upload_files']);
    expect(Ability.fromJson(ability('x/y')).requiredCapabilities, isEmpty);
  });
}
