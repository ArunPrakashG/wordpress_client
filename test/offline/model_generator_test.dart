@Timeout(Duration(minutes: 2))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wordpress_client/src/codegen/model_generator.dart';

const _schema = {
  'title': 'my-event',
  'properties': {
    'id': {'type': 'integer', 'readonly': true},
    'class': {'type': 'string'},
    'start-date': {
      'type': ['string', 'null'],
      'format': 'date-time',
    },
    'startDate': {'type': 'integer'},
    'price': {'type': 'number'},
    'featured': {'type': 'boolean'},
    'mixed': {
      'type': ['string', 'integer'],
    },
    'title': {
      'type': 'object',
      'properties': {
        'rendered': {'type': 'string'},
      },
    },
    'tickets': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'seat': {'type': 'string'},
          'when': {'type': 'string', 'format': 'date-time'},
        },
      },
    },
    'tags': {
      'type': 'array',
      'items': {'type': 'integer'},
    },
    'meta': {'type': 'object', 'properties': <String, dynamic>{}},
    "it's": {'type': 'string', 'description': r'Costs $5'},
  },
};

void main() {
  test('names follow Dart conventions without collisions', () {
    final source = generateModels([
      const ModelSource(className: 'MyEvent', schema: _schema),
    ]);

    expect(classNameFor('wp_block'), 'WpBlock');
    expect(source, contains('final class MyEvent implements'));
    expect(source, contains('final class MyEventTitle implements'));
    expect(source, contains('final class MyEventTickets implements'));
    expect(source, contains('final String? classValue;'));
    expect(source, contains('final DateTime? startDate;'));
    expect(source, contains('final int? startDate2;'));
    expect(source, contains('final Object? mixed;'));
    expect(source, contains('final List<MyEventTickets>? tickets;'));
    expect(source, contains('final Map<String, dynamic>? meta;'));
  });

  test('the generated file compiles and round-trips JSON', () async {
    // Inside the package, so package:wordpress_client resolves.
    final dir = Directory('.dart_tool/model_generator_test')
      ..createSync(recursive: true);
    addTearDown(() => dir.deleteSync(recursive: true));

    File('${dir.path}/schema.json').writeAsStringSync(
      jsonEncode({'schema': _schema}),
    );
    final generate = await Process.run(Platform.resolvedExecutable, [
      'run',
      'bin/generate.dart',
      '--schema',
      '${dir.path}/schema.json',
      '--out',
      '${dir.path}/models.dart',
    ]);
    expect(generate.exitCode, 0, reason: '${generate.stderr}');

    File('${dir.path}/main.dart').writeAsStringSync('''
import 'dart:convert';
import 'models.dart';

void main() {
  final event = MyEvent.fromJson({
    'id': '7',
    'class': 'vip',
    'start-date': '2024-05-01T10:00:00',
    'startDate': 3,
    'price': '9.5',
    'featured': '1',
    'mixed': 4,
    'title': {'rendered': 'Launch'},
    'tickets': [{'seat': 'A1', 'when': '2024-05-01T10:00:00'}, 'junk'],
    'tags': [1, '2', 'x'],
    "it's": 'q',
  });
  print(jsonEncode({
    'id': event.id,
    'title': event.title?.rendered,
    'seat': event.tickets?.single.seat,
    'tags': event.tags,
    'featured': event.featured,
    'json': event.toJson(),
  }));
}
''');

    final analyze = await Process.run(Platform.resolvedExecutable, [
      'analyze',
      '--fatal-infos',
      '${dir.path}/models.dart',
    ]);
    expect(analyze.exitCode, 0, reason: '${analyze.stdout}');

    final run = await Process.run(
      Platform.resolvedExecutable,
      ['run', '${dir.path}/main.dart'],
    );
    expect(run.exitCode, 0, reason: '${run.stderr}');

    final out = jsonDecode('${run.stdout}'.trim()) as Map<String, dynamic>;
    expect(out['id'], 7);
    expect(out['title'], 'Launch');
    expect(out['seat'], 'A1');
    expect(out['tags'], [1, 2]);
    expect(out['featured'], isTrue);
    expect(out['json'], containsPair('start-date', '2024-05-01T10:00:00.000'));
    expect(out['json'], containsPair("it's", 'q'));
    expect(out['json'], containsPair('price', 9.5));
  });
}
