import 'dart:async';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

final class _PingRequest extends IRequest {
  const _PingRequest();

  @override
  FutureOr<WordpressRequest> build(Uri baseUrl) {
    return WordpressRequest(
      url: RequestUrl.relativeParts(const ['test', 'ping']),
      method: HttpMethod.get,
    );
  }
}

final class _RetrieveMapInterface extends IRequestInterface
    with RetrieveOperation<Map<String, dynamic>, _PingRequest> {}

void main() {
  group('retrieveStream', () {
    late WordpressClient client;
    late int counter;
    late DelegatedMiddleware mw;

    setUp(() {
      counter = 0;
      mw = DelegatedMiddleware(
        onRequestDelegate: (r) async => r,
        onResponseDelegate: (r) async => r,
        onExecuteDelegate: (request) async {
          final path = request.url.toString();
          if (request.method == HttpMethod.get && path.endsWith('test/ping')) {
            counter += 1;
            return MiddlewareRawResponse(
              statusCode: 200,
              body: <String, dynamic>{'value': counter},
            );
          }
          return MiddlewareRawResponse.defaultInstance();
        },
      );

      client = WordpressClient(
        baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
        bootstrapper: (b) => b.withMiddlewares([mw]).build(),
      );

      client.register<_RetrieveMapInterface, Map<String, dynamic>>(
        interface: _RetrieveMapInterface(),
        key: 'test',
        decoder: (json) => json as Map<String, dynamic>,
        encoder: (dynamic m) => m as Map<String, dynamic>,
      );
    });

    tearDown(() {
      client.dispose();
    });

    test('emits on start and on refetch (distinct by data)', () async {
      final refetch = StreamController<void>.broadcast();
      addTearDown(() async => refetch.close());

      final stream = client
          .get<_RetrieveMapInterface>('test')
          .retrieveStream(
            const _PingRequest(),
            // large interval so only refetch triggers drive emissions
            interval: const Duration(days: 1),
            refetchTrigger: refetch.stream,
            emitOnStart: true,
            distinctData: true,
          )
          .map((r) => r.asSuccess().data['value'] as int);

      final values = <int>[];
  final sub = stream.listen(values.add);
      addTearDown(sub.cancel);

  // First emission due to emitOnStart
  await Future<void>.delayed(const Duration(milliseconds: 250));
  expect(values, equals([1]));

      // Trigger refetch => data changes (2), emits
      refetch.add(null);
  await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(values, equals([1, 2]));
    });

    test('external CancelToken cancels stream', () async {
      final token = CancelToken();
      final stream = client
          .get<_RetrieveMapInterface>('test')
          .retrieveStream(
            const _PingRequest(),
            interval: const Duration(days: 1),
            cancelToken: token,
            emitOnStart: true,
          )
          .map((r) => r.asSuccess().data['value'] as int);

      final values = <int>[];
      final c = Completer<void>();
  final sub = stream.listen(values.add, onDone: c.complete);

  // First emission
  await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(values, equals([1]));

      // Cancel and ensure stream completes
      token.cancel('stop');
      await c.future.timeout(const Duration(seconds: 1));
      await sub.cancel();
    });
  });
}
