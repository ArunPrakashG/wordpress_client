import 'dart:async';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

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

final class _Pong {
  const _Pong(this.decodedBy);

  final String decodedBy;
}

final class _PingInterface extends IRequestInterface
    with RetrieveOperation<_Pong, _PingRequest> {}

WordpressClient _clientWithDecoder(
  MockWordpressAdapter adapter,
  String label, {
  void Function(String url, int count)? statistics,
}) {
  final client = WordpressClient.fromDioInstance(
    baseUrl: testBaseUrl,
    instance: Dio()..httpClientAdapter = adapter,
    bootstrapper: (b) {
      if (statistics != null) {
        b.withStatisticDelegate(statistics);
      }
      return b.build();
    },
  );

  client.register<_PingInterface, _Pong>(
    interface: _PingInterface(),
    key: 'test',
    decoder: (_) => _Pong(label),
    encoder: (dynamic p) => <String, dynamic>{},
  );

  return client;
}

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter()
      ..reply('GET', '/test/ping', const MockResponse(body: {'value': 1}));
  });

  test('clients keep their own decoders for the same type', () async {
    final a = _clientWithDecoder(adapter, 'A');
    final b = _clientWithDecoder(adapter, 'B');

    final fromA =
        await a.get<_PingInterface>('test').retrieve(const _PingRequest());
    final fromB =
        await b.get<_PingInterface>('test').retrieve(const _PingRequest());

    expect(fromA.asSuccess().data.decodedBy, 'A');
    expect(fromB.asSuccess().data.decodedBy, 'B');
  });

  test('disposing one client does not break another', () async {
    final a = _clientWithDecoder(adapter, 'A');
    final b = _clientWithDecoder(adapter, 'B');

    a.dispose();

    final fromB =
        await b.get<_PingInterface>('test').retrieve(const _PingRequest());
    expect(fromB, isA<WordpressSuccessResponse<_Pong>>());
  });

  test('statistics callbacks and counts are per client', () async {
    final seenA = <int>[];
    final seenB = <int>[];
    final a =
        _clientWithDecoder(adapter, 'A', statistics: (_, c) => seenA.add(c));
    final b =
        _clientWithDecoder(adapter, 'B', statistics: (_, c) => seenB.add(c));

    await a.get<_PingInterface>('test').retrieve(const _PingRequest());
    await a.get<_PingInterface>('test').retrieve(const _PingRequest());
    await b.get<_PingInterface>('test').retrieve(const _PingRequest());

    expect(seenA, [1, 2]);
    expect(seenB, [1]);
  });
}
