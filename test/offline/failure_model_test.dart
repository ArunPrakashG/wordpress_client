import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

import 'support.dart';

void main() {
  late MockWordpressAdapter adapter;

  setUp(() {
    adapter = MockWordpressAdapter();
  });

  Future<WordpressFailure> failureOf(
    WordpressClient client, {
    ListPostRequest? request,
  }) async {
    final response = await client.posts.list(request ?? ListPostRequest());

    return response.asFailure().failure;
  }

  group('transport failures', () {
    test('connection errors are NetworkFailure.connection', () async {
      adapter.reply('GET', '/posts', MockResponse.connectionError());

      final failure = await failureOf(makeClient(adapter));

      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).kind, NetworkFailureKind.connection);
      expect(failure.cause, isA<DioException>());
      expect(failure.stackTrace, isNotNull);
    });

    test('timeouts are NetworkFailure.timeout', () async {
      adapter.reply('GET', '/posts', MockResponse.timeout());

      final failure = await failureOf(makeClient(adapter));

      expect((failure as NetworkFailure).kind, NetworkFailureKind.timeout);
    });

    test('a cancelled request is NetworkFailure.cancelled', () async {
      adapter.reply('GET', '/posts', const MockResponse(body: []));
      final token = CancelToken()..cancel();

      final failure = await failureOf(
        makeClient(adapter),
        request: ListPostRequest(cancelToken: token),
      );

      expect((failure as NetworkFailure).kind, NetworkFailureKind.cancelled);
    });
  });

  group('HTTP failures', () {
    test('404 is an ApiFailure carrying the WordPress error', () async {
      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(
          statusCode: 404,
          code: 'rest_post_invalid_id',
          message: 'Invalid post ID.',
        ),
      );

      final failure = await failureOf(makeClient(adapter));

      expect(failure, isA<ApiFailure>());
      failure as ApiFailure;
      expect(failure.statusCode, 404);
      expect(failure.error?.code, 'rest_post_invalid_id');
      expect(failure.message, 'Invalid post ID.');
    });

    test('500 without a WordPress payload keeps the body', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(statusCode: 500, body: 'Internal Server Error'),
      );

      final failure = await failureOf(makeClient(adapter));

      expect((failure as ApiFailure).statusCode, 500);
      expect(failure.error, isNull);
      expect(failure.body, 'Internal Server Error');
    });

    test('401 and 403 are AuthFailures', () async {
      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(statusCode: 403, code: 'rest_forbidden'),
      );
      final forbidden = await failureOf(makeClient(adapter));
      expect((forbidden as AuthFailure).reason, AuthFailureReason.forbidden);
      expect(forbidden.error?.code, 'rest_forbidden');

      adapter.reply(
        'GET',
        '/posts',
        MockResponse.wpError(statusCode: 401, code: 'rest_not_logged_in'),
      );
      final unauthorized = await failureOf(makeClient(adapter));
      expect(
        (unauthorized as AuthFailure).reason,
        AuthFailureReason.unauthorized,
      );
    });
  });

  group('local failures', () {
    test('auth required but none configured', () async {
      final failure = await failureOf(
        makeClient(adapter),
        request: ListPostRequest(requireAuth: true),
      );

      expect(
        (failure as AuthFailure).reason,
        AuthFailureReason.noAuthorization,
      );
      expect(adapter.requests, isEmpty);
    });

    test('an undecodable 200 is a DecodeFailure with the HTTP status',
        () async {
      adapter.reply('GET', '/posts', const MockResponse(body: {'a': 1}));

      final failure = await failureOf(makeClient(adapter));

      expect(failure, isA<DecodeFailure>());
      failure as DecodeFailure;
      expect(failure.statusCode, 200);
      expect(failure.rawData, {'a': 1});
      expect(failure.cause, isNotNull);
    });

    test('a middleware abort is MiddlewareFailure(aborted: true)', () async {
      final client = makeClient(
        adapter,
        middlewares: [
          DelegatedMiddleware(
            onRequestDelegate: (_) =>
                throw const MiddlewareAbortedException(message: 'nope'),
            onResponseDelegate: (r) async => r,
            onExecuteDelegate: (_) async =>
                MiddlewareRawResponse.defaultInstance(),
          ),
        ],
      );

      final failure = await failureOf(client);

      expect(failure, isA<MiddlewareFailure>());
      expect((failure as MiddlewareFailure).aborted, isTrue);
      expect(failure.message, 'nope');
    });

    test('a body that lies about being JSON is a DecodeFailure', () async {
      adapter.reply(
        'GET',
        '/posts',
        const MockResponse(
          body: 'Notice: oops {"id": 1',
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final failure = await failureOf(makeClient(adapter));

      expect(failure, isA<DecodeFailure>());
      expect((failure as DecodeFailure).cause, isA<FormatException>());
    });

    test('origin mismatch is a ClientFailure', () async {
      final raw = await makeClient(adapter).raw(
        WordpressRequest(
          url: RequestUrl.absolute(Uri.parse('https://evil.test/x')),
          method: HttpMethod.get,
        ),
      );
      final response = raw.asResponse<dynamic>(decoder: (d) => d);

      final failure = response.asFailure().failure;
      expect(failure, isA<ClientFailure>());
      expect(
        (failure as ClientFailure).type,
        RequestErrorType.originMismatch,
      );
    });
  });

  test('the failure hierarchy can be switched over exhaustively', () {
    String describe(WordpressFailure f) => switch (f) {
          NetworkFailure() => 'network',
          AuthFailure() => 'auth',
          ApiFailure() => 'api',
          DecodeFailure() => 'decode',
          MiddlewareFailure() => 'middleware',
          ClientFailure() => 'client',
        };

    expect(
      describe(const ApiFailure(statusCode: 500, message: 'x')),
      'api',
    );
  });
}
