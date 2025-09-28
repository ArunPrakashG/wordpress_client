import 'dart:convert';

import '../../wordpress_client.dart';
import '../constants.dart';
import '../responses/wordpress_error.dart';

/// A lightweight GraphQL client interface that leverages the existing
/// requester, auth, middlewares, and responses in this package.
///
/// This targets popular WordPress GraphQL plugins, notably WPGraphQL
/// (canonical), which exposes a GraphQL endpoint at `/<site-path>/graphql`.
///
/// Usage:
/// ```dart
/// final result = await client.graphql.query<MyType>(
///   document: """
///     query Posts($limit: Int!) {
///       posts(first: $limit) {
///         nodes { id title }
///       }
///     }
///   """,
///   variables: { 'limit': 5 },
///   parseData: (data) {
///     final nodes = (data['posts']?['nodes'] as List<dynamic>? ?? const [])
///         .cast<Map<String, dynamic>>();
///     // map to your model(s)
///     return nodes.map((e) => MyType.fromJson(e)).toList();
///   },
/// );
/// ```
final class GraphQLInterface extends IRequestInterface {
  late Uri _graphqlEndpoint;

  /// Compute the GraphQL endpoint from the REST base URL.
  ///
  /// For most WordPress setups using WPGraphQL, the endpoint is located at
  /// `/<site-path>/graphql`. If the site is installed in a subdirectory,
  /// the subdirectory is preserved. For example:
  /// - REST: https://example.com/wp-json/wp/v2 -> GraphQL: https://example.com/graphql
  /// - REST: https://example.com/blog/wp-json/wp/v2 -> GraphQL: https://example.com/blog/graphql
  Uri _computeGraphQLEndpoint(Uri restBase) {
    final segments = List<String>.from(restBase.pathSegments);
    final wpJsonIndex = segments.indexOf('wp-json');

    // Keep everything before 'wp-json' as the site path prefix, if present.
    final sitePrefix = wpJsonIndex > 0 ? segments.sublist(0, wpJsonIndex) : <String>[];

    final newPathSegments = <String>[...sitePrefix, 'graphql'];
    return restBase.replace(pathSegments: newPathSegments, queryParameters: {});
  }

  @override
  void onInit() {
    _graphqlEndpoint = _computeGraphQLEndpoint(baseUrl);
  }

  /// Override or customize the GraphQL endpoint if your site uses a custom path
  /// or query-style endpoint (e.g., `/?graphql`).
  void setEndpointPath(String path) {
    // Normalize path, remove leading '/'
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final prefixSegments = _graphqlEndpoint.pathSegments
        .takeWhile((s) => s.isNotEmpty)
        .toList();

    // If previous computation had .../graphql, drop it to only the site prefix
    if (prefixSegments.isNotEmpty && prefixSegments.last == 'graphql') {
      prefixSegments.removeLast();
    }

    final update = _graphqlEndpoint.replace(
      pathSegments: <String>[...prefixSegments, ...normalized.split('/')],
      queryParameters: {},
    );

    _graphqlEndpoint = update;
  }

  /// Execute a raw GraphQL request and get the raw response.
  Future<WordpressRawResponse> raw({
    required String document,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    final body = <String, dynamic>{
      'query': document,
      if (operationName != null) 'operationName': operationName,
      if (variables != null && variables.isNotEmpty) 'variables': variables,
    };

    final requestHeaders = <String, dynamic>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    final request = WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.absolute(_graphqlEndpoint),
      body: jsonEncode(body),
      headers: requestHeaders,
      requireAuth: requireAuth,
      authorization: authorization,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );

    return executor.execute(request);
  }

  /// Execute a GraphQL query and map the `data` field to type [T].
  ///
  /// - If the response contains `errors`, returns [WordpressFailureResponse].
  /// - Otherwise, parses `data` using [parseData] and returns [WordpressSuccessResponse].
  Future<WordpressResponse<T>> query<T>({
    required String document,
    required T Function(Map<String, dynamic> data) parseData,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    return _execute<T>(
      document: document,
      variables: variables,
      operationName: operationName,
      parseData: parseData,
      requireAuth: requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  /// Execute a GraphQL mutation and map the `data` field to type [T].
  Future<WordpressResponse<T>> mutate<T>({
    required String document,
    required T Function(Map<String, dynamic> data) parseData,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    // For GraphQL over HTTP, we still POST, same as query
    return query<T>(
      document: document,
      parseData: parseData,
      variables: variables,
      operationName: operationName,
      requireAuth: requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  Future<WordpressResponse<T>> _execute<T>({
    required String document,
    required T Function(Map<String, dynamic> data) parseData,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    final rawResp = await raw(
      document: document,
      variables: variables,
      operationName: operationName,
      requireAuth: requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );

    // HTTP-level failure => map using existing REST helpers
    if (rawResp.isFailure) {
      return rawResp.asResponse<T>(
        decoder: (_) => throw StateError('Decoder should not be called for failures'),
      );
    }

    // Expect a standard GraphQL envelope: { data: ..., errors?: [...] }
    if (rawResp.data is! Map<String, dynamic>) {
      return WordpressFailureResponse<T>(
        error: const WordpressError(
          code: 'graphql_invalid_payload',
          message: 'GraphQL response is not a JSON object.',
          status: 500,
        ),
        code: rawResp.code,
        rawData: rawResp.data,
        headers: rawResp.headers,
        requestHeaders: rawResp.requestHeaders,
        duration: rawResp.duration,
        extra: rawResp.extra,
        message: rawResp.message,
      );
    }

    final map = rawResp.data as Map<String, dynamic>;
    final hasErrors = map['errors'] is List && (map['errors'] as List).isNotEmpty;
    if (hasErrors) {
      final errors = (map['errors'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
      final message = errors
          .map((e) => e['message']?.toString())
          .whereType<String>()
          .where((m) => m.isNotEmpty)
          .join('; ');

      return WordpressFailureResponse<T>(
        error: WordpressError(
          code: 'graphql_error',
          message: message.isEmpty ? 'GraphQL error' : message,
          status: rawResp.code,
        ),
        code: rawResp.code,
        rawData: rawResp.data,
        headers: rawResp.headers,
        requestHeaders: rawResp.requestHeaders,
        duration: rawResp.duration,
        extra: rawResp.extra,
        message: rawResp.message,
      );
    }

    final dataNode = map['data'];
    if (dataNode is! Map<String, dynamic>) {
      return WordpressFailureResponse<T>(
        error: const WordpressError(
          code: 'graphql_missing_data',
          message: 'GraphQL response does not contain a `data` object.',
          status: 500,
        ),
        code: rawResp.code,
        rawData: rawResp.data,
        headers: rawResp.headers,
        requestHeaders: rawResp.requestHeaders,
        duration: rawResp.duration,
        extra: rawResp.extra,
        message: rawResp.message,
      );
    }

    final parsed = parseData(dataNode);
    return WordpressSuccessResponse<T>(
      data: parsed,
      code: rawResp.code,
      rawData: rawResp.data,
      headers: rawResp.headers,
      requestHeaders: rawResp.requestHeaders,
      duration: rawResp.duration,
      extra: rawResp.extra,
      message: rawResp.message,
    );
  }
}
