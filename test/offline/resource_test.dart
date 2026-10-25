import 'dart:convert';

import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

class Event {
  Event(this.id, this.title);

  factory Event.fromJson(Map<String, dynamic> json) =>
      Event(json['id'] as int, json['title'] as String);

  final int id;
  final String title;

  Map<String, dynamic> toJson() => {'title': title};
}

void main() {
  late MockWordpressAdapter adapter;
  late WordpressClient client;

  Map<String, dynamic> bodyOf(RecordedRequest r) {
    final body = r.body;
    return body is String
        ? jsonDecode(body) as Map<String, dynamic>
        : Map<String, dynamic>.from(body as Map);
  }

  setUp(() {
    adapter = MockWordpressAdapter();
    client = makeClient(
      adapter,
      auth: WordpressAuth.appPassword(user: 'a', appPassword: 'b'),
    );
  });

  ResourceInterface<Event> events() => client.resource<Event>(
        'events',
        decoder: Event.fromJson,
        encoder: (e) => e.toJson(),
      );

  test('lists, retrieves and paginates a wp/v2 custom post type', () async {
    adapter
      ..reply(
        'GET',
        '/events',
        MockResponse.paged(
          [
            {'id': 1, 'title': 'A'},
          ],
          total: 2,
          totalPages: 2,
        ),
      )
      ..reply(
        'GET',
        '/events/7',
        const MockResponse(body: {'id': 7, 'title': 'Seven'}),
      );

    final page = await events().list(perPage: 1, query: {'status': 'publish'});
    expect(page.dataOrThrow().single.title, 'A');
    final q = adapter.lastRequest!.uri.queryParameters;
    expect(q['status'], 'publish');
    expect(q['per_page'], '1');
    expect(adapter.lastRequest!.uri.path, '/wp-json/wp/v2/events');

    expect((await events().retrieve(7)).dataOrThrow().title, 'Seven');

    adapter.clearRequests();
    final all = await events().listAll(perPage: 1);
    expect(all.dataOrThrow(), hasLength(2));
    expect(adapter.callCount(method: 'GET', path: '/events'), 2);
  });

  test('creates from a model or a map, updates and deletes', () async {
    adapter
      ..reply(
        'POST',
        '/events',
        const MockResponse(statusCode: 201, body: {'id': 9, 'title': 'New'}),
      )
      ..reply(
        'POST',
        '/events/9',
        const MockResponse(body: {'id': 9, 'title': 'Renamed'}),
      )
      ..reply('DELETE', '/events/9', const MockResponse(body: {'ok': true}));

    final created = await events().create(Event(0, 'New'));
    expect(created.dataOrThrow().id, 9);
    expect(bodyOf(adapter.lastRequest!), {'title': 'New'});

    final updated = await events().update(9, {'title': 'Renamed'});
    expect(updated.dataOrThrow().title, 'Renamed');

    final deleted = await events().delete(9, force: true);
    expect(deleted.isSuccessful, isTrue);
    expect(adapter.lastRequest!.uri.queryParameters['force'], 'true');
  });

  test('plugin namespaces resolve against the site root', () async {
    adapter.reply(
      'GET',
      '/my-plugin/v1/events',
      MockResponse.paged([], total: 0, totalPages: 0),
    );

    final plugin = client.resource<Event>(
      'events',
      namespace: 'my-plugin/v1',
      decoder: Event.fromJson,
    );
    await plugin.list();

    expect(
      adapter.lastRequest!.uri.toString().split('?').first,
      'https://example.com/wp-json/my-plugin/v1/events',
    );
  });

  test('asking twice returns the same interface; models need an encoder', () {
    expect(identical(events(), events()), isTrue);

    final noEncoder = client.resource<Event>(
      'other',
      decoder: Event.fromJson,
    );
    expect(noEncoder.create(Event(0, 'x')), throwsA(isA<StateError>()));
  });
}
