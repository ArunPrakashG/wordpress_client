import 'dart:convert';

import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

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

  test('sends operations to the site root batch endpoint', () async {
    adapter.reply(
      'POST',
      '/batch/v1',
      const MockResponse(
        body: {
          'failed': false,
          'responses': [
            {
              'body': {'id': 1},
              'status': 201,
            },
            {
              'status': 403,
              'body': {'code': 'rest_forbidden', 'message': 'No'},
            },
          ],
        },
      ),
    );

    final response = await client.batch.run(
      [
        const BatchOperation.create('posts', body: {'title': 'A'}),
        BatchOperation.delete('posts', 13, force: true),
      ],
      validation: BatchValidation.requireAllValidate,
    );

    final request = adapter.lastRequest!;
    expect(request.uri.toString(), 'https://example.com/wp-json/batch/v1');
    final sent = bodyOf(request);
    expect(sent['validation'], 'require-all-validate');
    expect(sent['requests'], [
      {
        'method': 'POST',
        'path': '/wp/v2/posts',
        'body': {'title': 'A'},
      },
      {
        'method': 'DELETE',
        'path': '/wp/v2/posts/13',
        'body': {'force': true},
      },
    ]);

    final result = response.dataOrThrow();
    expect(result.responses, hasLength(2));
    expect(result.succeeded.single.body, {'id': 1});
    expect(result.failures.single.error?.code, 'rest_forbidden');
    expect(result.responses.first.decode((j) => j['id']), 1);
  });

  test('splits large lists into chunks and keeps the order', () async {
    var call = 0;
    adapter.on('POST', '/batch/v1', (req) {
      final requests = bodyOf(req)['requests'] as List;
      final offset = call++ * 25;
      return MockResponse(
        body: {
          'failed': false,
          'responses': [
            for (var i = 0; i < requests.length; i++)
              {
                'status': 200,
                'body': {'n': offset + i},
              },
          ],
        },
      );
    });

    final ops = [
      for (var i = 0; i < 30; i++) BatchOperation.update('posts', i),
    ];
    final result = (await client.batch.run(ops)).dataOrThrow();

    expect(adapter.callCount(method: 'POST', path: '/batch/v1'), 2);
    expect(result.responses.map((r) => (r.body as Map)['n']), [
      for (var i = 0; i < 30; i++) i,
    ]);
  });

  test('a failed transport call is a failure response; bad input throws',
      () async {
    adapter.reply('POST', '/batch/v1', MockResponse.timeout());

    final response =
        await client.batch.run([BatchOperation.update('posts', 1)]);

    expect(response.isFailure, isTrue);
    expect(() => client.batch.run([]), throwsArgumentError);
    expect(
      () => client.batch.run([BatchOperation.update('posts', 1)], chunkSize: 0),
      throwsArgumentError,
    );
  });
}
