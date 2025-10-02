import 'dart:async';

import 'package:test/test.dart';
import 'package:wordpress_client/wordpress_client.dart';

final class _CustomRequest extends IRequest {
  const _CustomRequest();

  @override
  FutureOr<WordpressRequest> build(Uri baseUrl) {
    return WordpressRequest(
      url: RequestUrl.relativeParts(const ['custom', 'endpoint']),
      method: HttpMethod.get,
    );
  }
}

final class _CustomInterface extends IRequestInterface
    with CustomOperation<Map<String, dynamic>, _CustomRequest> {
  @override
  Map<String, dynamic> decode(dynamic json) => json as Map<String, dynamic>;
}

void main() {
  group('custom requestStream', () {
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
          if (request.method == HttpMethod.get && path.endsWith('custom/endpoint')) {
            counter++;
            return MiddlewareRawResponse(
              statusCode: 200,
              body: {'ok': counter},
            );
          }
          return MiddlewareRawResponse.defaultInstance();
        },
      );

      client = WordpressClient(
        baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
        bootstrapper: (b) => b.withMiddlewares([mw]).build(),
      );

      client.register<_CustomInterface, Map<String, dynamic>>(
        interface: _CustomInterface(),
        key: 'custom',
        decoder: (json) => json as Map<String, dynamic>,
        encoder: (dynamic m) => m as Map<String, dynamic>,
      );
    });

    tearDown(() => client.dispose());

    test('emits on refetch only (no periodic)', () async {
      final refetch = StreamController<void>.broadcast();
      addTearDown(refetch.close);

      final stream = client
          .get<_CustomInterface>('custom')
          .requestStream(
            const _CustomRequest(),
            interval: const Duration(days: 1),
            emitOnStart: false,
            refetchTrigger: refetch.stream,
          )
          .map((r) => r.asSuccess().data['ok'] as int);

      final values = <int>[];
      final sub = stream.listen(values.add);
      addTearDown(sub.cancel);

    // No emit at start
  await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(values, isEmpty);

      refetch.add(null);
  await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(values, equals([1]));

      refetch.add(null);
  await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(values, equals([1, 2]));
    });
  });
}
