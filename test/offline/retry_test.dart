import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;
  late List<Duration> sleeps;

  RetryPolicy policy({int maxAttempts = 3, Set<int>? statusCodes}) {
    return RetryPolicy(
      maxAttempts: maxAttempts,
      jitter: false,
      statusCodes: statusCodes ?? const {429, 502, 503, 504},
      sleep: (d) async => sleeps.add(d),
    );
  }

  setUp(() {
    adapter = MockWordpressAdapter();
    sleeps = [];
  });

  group('retry (#96)', () {
    test('does not retry by default', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(statusCode: 503, body: 'down'),
      );
      final client = makeClient(adapter);

      final response = await client.posts.list(ListPostRequest());

      expect(response.isFailure, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
    });

    test('succeeds on the third attempt with exponential backoff', () async {
      adapter.replySequence('GET', '/posts', const [
        MockResponse(statusCode: 503, body: 'down'),
        MockResponse(statusCode: 502, body: 'bad gateway'),
        MockResponse(body: [onePost]),
      ]);
      final client = makeClient(adapter, retryPolicy: policy());

      final response = await client.posts.list(ListPostRequest());

      expect(response.isSuccessful, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 3);
      expect(sleeps, const [
        Duration(milliseconds: 500),
        Duration(milliseconds: 1000),
      ]);
      expect(response.extra?[WordpressRequest.metaAttempts], 3);
    });

    test('gives up after maxAttempts and returns the last failure', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(statusCode: 503, body: 'down'),
      );
      final client = makeClient(adapter, retryPolicy: policy());

      final response = await client.posts.list(ListPostRequest());

      expect(response.isFailure, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 3);
      expect(response.extra?[WordpressRequest.metaAttempts], 3);
    });

    test('does not retry statuses outside the policy', () async {
      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(statusCode: 404, code: 'rest_no_route'),
      );
      final client = makeClient(adapter, retryPolicy: policy());

      await client.posts.list(ListPostRequest());

      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
      expect(sleeps, isEmpty);
    });

    test('honors Retry-After in seconds', () async {
      adapter.replySequence('GET', '/posts', const [
        MockResponse(statusCode: 429, headers: {'Retry-After': '7'}),
        MockResponse(body: [onePost]),
      ]);
      final client = makeClient(adapter, retryPolicy: policy());

      final response = await client.posts.list(ListPostRequest());

      expect(response.isSuccessful, isTrue);
      expect(sleeps, const [Duration(seconds: 7)]);
    });

    test('gives up when Retry-After exceeds maxRetryAfter', () async {
      adapter.replySequence('GET', '/posts', const [
        MockResponse(statusCode: 429, headers: {'Retry-After': '3600'}),
        MockResponse(body: [onePost]),
      ]);
      final client = makeClient(adapter, retryPolicy: policy());

      final response = await client.posts.list(ListPostRequest());

      expect(response.isFailure, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
      expect(sleeps, isEmpty);
    });

    test('retries timeouts and connection errors', () async {
      adapter.replySequence('GET', '/posts', [
        MockResponse.timeout(),
        MockResponse.connectionError(),
        const MockResponse(body: [onePost]),
      ]);
      final client = makeClient(adapter, retryPolicy: policy());

      final response = await client.posts.list(ListPostRequest());

      expect(response.isSuccessful, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 3);
    });

    test('network errors surface as typed failures once exhausted', () async {
      adapter.reply('GET', '/posts', MockResponse.timeout());
      final client = makeClient(adapter, retryPolicy: policy(maxAttempts: 2));

      final response = await client.posts.list(ListPostRequest());

      expect(response.isFailure, isTrue);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 2);
      final failure = (response as WordpressFailureResponse).failure;
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).kind, NetworkFailureKind.timeout);
    });

    test('never retries POST by default', () async {
      adapter.reply(
        'POST',
        '/posts',
        const MockResponse(statusCode: 503, body: 'down'),
      );
      final client = makeClient(
        adapter,
        retryPolicy: policy(),
        auth: WordpressAuth.appPassword(user: 'a', appPassword: 'pw1 pw1'),
      );

      await client.posts.create(
        CreatePostRequest(title: 'x', content: 'y', status: 'draft'),
      );

      expect(adapter.callCount(method: 'POST', path: '/posts'), 1);
    });

    test('a request can opt out of the client policy', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(statusCode: 503, body: 'down'),
      );
      final client = makeClient(adapter, retryPolicy: policy());

      await client.raw(
        WordpressRequest(
          url: RequestUrl.relative('posts'),
          method: HttpMethod.get,
          retryPolicy: RetryPolicy.none,
        ),
      );

      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
    });

    test('cancelling during backoff aborts the retry', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(statusCode: 503, body: 'down'),
      );
      final token = CancelToken();
      final client = makeClient(
        adapter,
        retryPolicy: RetryPolicy(
          jitter: false,
          sleep: (_) async {
            token.cancel('stop');
            await Future<void>.delayed(const Duration(seconds: 5));
          },
        ),
      );

      final response = await client.raw(
        WordpressRequest(
          url: RequestUrl.relative('posts'),
          method: HttpMethod.get,
          cancelToken: token,
        ),
      );

      expect(response.isFailure, isTrue);
      expect(response.code, -RequestErrorType.requestCancelled.index);
      expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
    });
  });

  group('RetryPolicy', () {
    test('parses delta-seconds and HTTP dates', () {
      expect(RetryPolicy.parseRetryAfter('5'), const Duration(seconds: 5));
      expect(RetryPolicy.parseRetryAfter('-1'), isNull);
      expect(RetryPolicy.parseRetryAfter('soon'), isNull);
      expect(RetryPolicy.parseRetryAfter(null), isNull);
      expect(
        RetryPolicy.parseRetryAfter(
          'Wed, 21 Oct 2026 07:28:30 GMT',
          now: DateTime.utc(2026, 10, 21, 7, 28),
        ),
        const Duration(seconds: 30),
      );
    });

    test('caps the backoff at maxDelay', () {
      const p = RetryPolicy(jitter: false, maxDelay: Duration(seconds: 2));

      expect(p.nextDelay(10), const Duration(seconds: 2));
    });

    test('jitter stays within 50-100% of the computed delay', () {
      const p = RetryPolicy();

      for (var i = 0; i < 50; i++) {
        final d = p.nextDelay(1)!;
        expect(d, greaterThanOrEqualTo(const Duration(milliseconds: 250)));
        expect(d, lessThanOrEqualTo(const Duration(milliseconds: 500)));
      }
    });
  });
}
