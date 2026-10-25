import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../wordpress_client.dart';
import '../constants.dart';

/// A registered GraphQL query or mutation that can be reused.
///
/// This class encapsulates the query document, default variables,
/// and the parser function, allowing you to register queries once
/// and execute them multiple times with different variables.
///
/// Example:
/// ```dart
/// final postsQuery = RegisteredQuery<List<Post>>(
///   name: 'getPosts',
///   document: '''
///     query Posts($limit: Int!) {
///       posts(first: $limit) {
///         nodes { id title }
///       }
///     }
///   ''',
///   parseData: (data) {
///     final nodes = (data['posts']?['nodes'] as List<dynamic>? ?? const [])
///         .cast<Map<String, dynamic>>();
///     return nodes.map(Post.fromJson).toList();
///   },
///   defaultVariables: {'limit': 10},
/// );
/// ```
final class RegisteredQuery<T> {
  /// Creates a new registered query.
  const RegisteredQuery({
    required this.name,
    required this.document,
    required this.parseData,
    this.operationName,
    this.defaultVariables,
    this.requireAuth = false,
  });

  /// A unique identifier for this query.
  final String name;

  /// The GraphQL document (query or mutation string).
  final String document;

  /// The operation name within the document (if multiple operations exist).
  final String? operationName;

  /// Function to parse the `data` field from the GraphQL response.
  final T Function(Map<String, dynamic> data) parseData;

  /// Default variables to use when executing this query.
  ///
  /// These can be overridden when calling [GraphQLInterface.executeRegistered].
  final Map<String, dynamic>? defaultVariables;

  /// Whether this query requires authentication by default.
  final bool requireAuth;

  /// Creates a copy of this query with updated properties.
  RegisteredQuery<T> copyWith({
    String? name,
    String? document,
    String? operationName,
    T Function(Map<String, dynamic> data)? parseData,
    Map<String, dynamic>? defaultVariables,
    bool? requireAuth,
  }) {
    return RegisteredQuery<T>(
      name: name ?? this.name,
      document: document ?? this.document,
      operationName: operationName ?? this.operationName,
      parseData: parseData ?? this.parseData,
      defaultVariables: defaultVariables ?? this.defaultVariables,
      requireAuth: requireAuth ?? this.requireAuth,
    );
  }

  @override
  String toString() =>
      'RegisteredQuery<$T>(name: $name, operationName: $operationName)';
}

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
  /// Internal registry for storing registered queries.
  final Map<String, RegisteredQuery<dynamic>> _registry = {};

  /// Path segments set through [setEndpointPath], relative to the site prefix.
  List<String>? _customPathSegments;

  /// The GraphQL endpoint, derived from the client's current base URL.
  ///
  /// It is computed on access so that it follows `reconfigure(baseUri: ...)`.
  ///
  /// For most WordPress setups using WPGraphQL, the endpoint is located at
  /// `/<site-path>/graphql`. If the site is installed in a subdirectory,
  /// the subdirectory is preserved. For example:
  /// - REST: https://example.com/wp-json/wp/v2 -> GraphQL: https://example.com/graphql
  /// - REST: https://example.com/blog/wp-json/wp/v2 -> GraphQL: https://example.com/blog/graphql
  Uri get _graphqlEndpoint {
    final restBase = baseUrl;
    final segments = List<String>.from(restBase.pathSegments);
    final wpJsonIndex = segments.indexOf('wp-json');

    // Keep everything before 'wp-json' as the site path prefix, if present.
    final sitePrefix =
        wpJsonIndex > 0 ? segments.sublist(0, wpJsonIndex) : <String>[];

    return Uri(
      scheme: restBase.scheme,
      userInfo: restBase.userInfo,
      host: restBase.host,
      port: restBase.hasPort ? restBase.port : null,
      pathSegments: <String>[
        ...sitePrefix,
        ..._customPathSegments ?? const ['graphql'],
      ],
    );
  }

  /// Override or customize the GraphQL endpoint path, relative to the site
  /// root, if your site uses a custom path (e.g. `api/graphql`).
  ///
  /// The override is kept when the client is reconfigured with a new base URL.
  /// The endpoint always stays on the client's own origin.
  void setEndpointPath(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;

    _customPathSegments =
        normalized.split('/').where((s) => s.isNotEmpty).toList();
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
    bool useGet = false,
    Map<String, dynamic>? extensions,
    bool omitDocument = false,
  }) async {
    final hasVariables = variables != null && variables.isNotEmpty;
    final hasExtensions = extensions != null && extensions.isNotEmpty;

    if (useGet && _isMutation(document)) {
      throw ArgumentError.value(
        document,
        'document',
        'Mutations must not be sent with GET.',
      );
    }

    final requestHeaders = <String, dynamic>{
      if (!useGet) 'Content-Type': 'application/json',
      ...?headers,
    };

    final request = WordpressRequest(
      method: useGet ? HttpMethod.get : HttpMethod.post,
      url: RequestUrl.absolute(_graphqlEndpoint),
      queryParameters: useGet
          ? <String, dynamic>{
              if (!omitDocument) 'query': document,
              if (operationName != null) 'operationName': operationName,
              if (hasVariables) 'variables': jsonEncode(variables),
              if (hasExtensions) 'extensions': jsonEncode(extensions),
            }
          : null,
      body: useGet
          ? null
          : jsonEncode(<String, dynamic>{
              if (!omitDocument) 'query': document,
              if (operationName != null) 'operationName': operationName,
              if (hasVariables) 'variables': variables,
              if (hasExtensions) 'extensions': extensions,
            }),
      headers: requestHeaders,
      requireAuth: requireAuth,
      authorization: authorization,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      // A query sent over POST is a read, so it must not flush the cache.
      extra: {
        if (!useGet && !_isMutation(document))
          WordpressRequest.metaKeepCache: true,
      },
    );

    return executor.raw(request);
  }

  /// Whether the operation in [document] is a mutation (or subscription).
  static bool _isMutation(String document) {
    final withoutComments = document
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('#'))
        .join('\n');

    return RegExp(r'^\s*(mutation|subscription)\b').hasMatch(withoutComments);
  }

  /// Sends the operation, adding Automatic Persisted Queries when enabled.
  ///
  /// With [useAutomaticPersistedQueries] a read first sends only the SHA-256
  /// of the document. If the server answers `PersistedQueryNotFound` the
  /// full document is sent once so the server can store it.
  Future<WordpressRawResponse> _send({
    required String document,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    bool useGet = false,
  }) async {
    Future<WordpressRawResponse> send({
      Map<String, dynamic>? extensions,
      bool omitDocument = false,
    }) {
      return raw(
        document: document,
        variables: variables,
        operationName: operationName,
        requireAuth: requireAuth,
        authorization: authorization,
        headers: headers,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        useGet: useGet,
        extensions: extensions,
        omitDocument: omitDocument,
      );
    }

    if (!useAutomaticPersistedQueries || _isMutation(document)) {
      return send();
    }

    final extensions = <String, dynamic>{
      'persistedQuery': <String, dynamic>{
        'version': 1,
        'sha256Hash': sha256.convert(utf8.encode(document)).toString(),
      },
    };

    final first = await send(extensions: extensions, omitDocument: true);
    if (!_persistedQueryNotFound(first.data)) {
      return first;
    }

    return send(extensions: extensions);
  }

  static bool _persistedQueryNotFound(dynamic data) {
    if (data is! Map<String, dynamic> || data['errors'] is! List) {
      return false;
    }

    return (data['errors'] as List).whereType<Map<dynamic, dynamic>>().any(
          (e) =>
              e['message'] == 'PersistedQueryNotFound' ||
              (e['extensions'] is Map &&
                  (e['extensions'] as Map)['code'] ==
                      'PERSISTED_QUERY_NOT_FOUND'),
        );
  }

  /// Send reads with Automatic Persisted Queries (APQ).
  ///
  /// Needs server support, for example WPGraphQL Smart Cache. Off by default.
  bool useAutomaticPersistedQueries = false;

  /// Execute a GraphQL query and map the `data` field to type [T].
  ///
  /// - If the response contains `errors`, returns [WordpressFailureResponse].
  /// - Otherwise, parses `data` using [parseData] and returns [WordpressSuccessResponse].
  ///
  /// By default the query is sent with `POST`. Set [useGet] to send it with
  /// `GET` instead, which lets `CacheMiddleware`, HTTP caches and retries
  /// treat it like any other read. The errors of a failed query are available
  /// as `extra[GraphQLInterface.errorsKey]`; use [execute] to also get partial
  /// data.
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
    bool useGet = false,
  }) async {
    return _execute<T>(
      useGet: useGet,
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
  ///
  /// A mutation is always sent with `POST`, is never sent as an Automatic
  /// Persisted Query, and a successful one clears the response cache.
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
    if (!_isMutation(document)) {
      throw ArgumentError.value(
        document,
        'document',
        'mutate() expects a mutation; use query() for reads.',
      );
    }

    return _execute<T>(
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
    bool useGet = false,
  }) async {
    final rawResp = await _send(
      useGet: useGet,
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
        decoder: (_) =>
            throw StateError('Decoder should not be called for failures'),
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
    final hasErrors =
        map['errors'] is List && (map['errors'] as List).isNotEmpty;
    if (hasErrors) {
      final errors =
          (map['errors'] as List).whereType<Map<String, dynamic>>().toList();
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
        extra: <String, dynamic>{
          ...rawResp.extra,
          errorsKey: _parseErrors(map),
        },
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

  /// `extra` key under which a failed query carries its `List<GraphQLError>`.
  static const String errorsKey = 'graphql.errors';

  static List<GraphQLError> _parseErrors(Map<String, dynamic> envelope) {
    final errors = envelope['errors'];
    if (errors is! List) {
      return const [];
    }

    return errors
        .whereType<Map<String, dynamic>>()
        .map(GraphQLError.fromJson)
        .toList();
  }

  WordpressFailureResponse<T> _failure<T>(
    WordpressRawResponse rawResp,
    String code,
    String message,
  ) {
    return WordpressFailureResponse<T>(
      error: WordpressError(code: code, message: message, status: 500),
      code: rawResp.code,
      rawData: rawResp.data,
      headers: rawResp.headers,
      requestHeaders: rawResp.requestHeaders,
      duration: rawResp.duration,
      extra: rawResp.extra,
      message: rawResp.message,
    );
  }

  /// Converts a failure response of one type into another.
  WordpressFailureResponse<T> _refail<T>(WordpressFailureResponse<dynamic> f) {
    return WordpressFailureResponse<T>(
      error: f.error,
      code: f.code,
      rawData: null,
      headers: f.headers,
      requestHeaders: f.requestHeaders,
      duration: f.duration,
      extra: f.extra,
      message: f.message,
    );
  }

  /// Executes an operation and returns its data **and** errors.
  ///
  /// Unlike [query], a response that has `errors` is still a success when the
  /// HTTP exchange worked: GraphQL servers return partial `data` next to
  /// `errors` when only some fields fail. Inspect [GraphQLResult.errors] and
  /// [GraphQLResult.isPartial]. Only transport, HTTP and malformed-envelope
  /// problems are failures.
  ///
  /// If [parseData] throws while there are errors (because a field it needs
  /// is null), the exception is swallowed and [GraphQLResult.data] stays null.
  Future<WordpressResponse<GraphQLResult<T>>> execute<T>({
    required String document,
    required T Function(Map<String, dynamic> data) parseData,
    Map<String, dynamic>? variables,
    String? operationName,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    bool useGet = false,
  }) async {
    final rawResp = await _send(
      document: document,
      variables: variables,
      operationName: operationName,
      requireAuth: requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      useGet: useGet,
    );

    if (rawResp.isFailure) {
      return rawResp.asResponse<GraphQLResult<T>>(
        decoder: (_) =>
            throw StateError('Decoder should not be called for failures'),
      );
    }

    final envelope = rawResp.data;
    if (envelope is! Map<String, dynamic>) {
      return _failure(
        rawResp,
        'graphql_invalid_payload',
        'GraphQL response is not a JSON object.',
      );
    }

    final errors = _parseErrors(envelope);
    final dataNode = envelope['data'];
    T? parsed;

    if (dataNode is Map<String, dynamic>) {
      try {
        parsed = parseData(dataNode);
      } on Object {
        if (errors.isEmpty) {
          rethrow;
        }
      }
    } else if (errors.isEmpty) {
      return _failure(
        rawResp,
        'graphql_missing_data',
        'GraphQL response does not contain a `data` object.',
      );
    }

    final extensions = envelope['extensions'];

    return WordpressSuccessResponse<GraphQLResult<T>>(
      data: GraphQLResult<T>(
        data: parsed,
        errors: errors,
        extensions: extensions is Map<String, dynamic> ? extensions : null,
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

  /// Sends several operations in a single HTTP request (query batching).
  ///
  /// The server must support batching (WPGraphQL does, if enabled in its
  /// settings). The results line up with [operations]; each one carries its
  /// own data and errors.
  Future<WordpressResponse<List<GraphQLResult<Object?>>>> batch(
    List<GraphQLOperation> operations, {
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    if (operations.isEmpty) {
      throw ArgumentError.value(operations, 'operations', 'must not be empty');
    }

    final request = WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.absolute(_graphqlEndpoint),
      body: jsonEncode([
        for (final op in operations)
          <String, dynamic>{
            'query': op.document,
            if (op.operationName != null) 'operationName': op.operationName,
            if (op.variables != null && op.variables!.isNotEmpty)
              'variables': op.variables,
          },
      ]),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        ...?headers,
      },
      requireAuth: requireAuth,
      authorization: authorization,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: {
        if (operations.every((o) => !_isMutation(o.document)))
          WordpressRequest.metaKeepCache: true,
      },
    );

    final rawResp = await executor.raw(request);
    if (rawResp.isFailure) {
      return rawResp.asResponse<List<GraphQLResult<Object?>>>(
        decoder: (_) =>
            throw StateError('Decoder should not be called for failures'),
      );
    }

    final body = rawResp.data;
    if (body is! List || body.length != operations.length) {
      return _failure(
        rawResp,
        'graphql_invalid_batch',
        'Expected a JSON array with ${operations.length} results. '
            'Does the server have query batching enabled?',
      );
    }

    final results = <GraphQLResult<Object?>>[];
    for (var i = 0; i < body.length; i++) {
      final envelope = body[i];
      if (envelope is! Map<String, dynamic>) {
        return _failure(
          rawResp,
          'graphql_invalid_payload',
          'Batch entry $i is not a JSON object.',
        );
      }

      final dataNode = envelope['data'];
      final parse = operations[i].parseData;
      final extensions = envelope['extensions'];

      results.add(
        GraphQLResult<Object?>(
          data: dataNode is Map<String, dynamic>
              ? (parse != null ? parse(dataNode) : dataNode)
              : null,
          errors: _parseErrors(envelope),
          extensions: extensions is Map<String, dynamic> ? extensions : null,
        ),
      );
    }

    return WordpressSuccessResponse<List<GraphQLResult<Object?>>>(
      data: results,
      code: rawResp.code,
      rawData: rawResp.data,
      headers: rawResp.headers,
      requestHeaders: rawResp.requestHeaders,
      duration: rawResp.duration,
      extra: rawResp.extra,
      message: rawResp.message,
    );
  }

  /// Walks a Relay style connection page by page.
  ///
  /// [document] must declare an `$after: String` variable (rename it with
  /// [afterVariable]) and select `pageInfo { hasNextPage endCursor }` plus
  /// `nodes` (or `edges { node }`) on the connection found at
  /// [connectionPath] inside `data`, for example `['posts']`.
  ///
  /// Emits one response per page holding the parsed nodes. A failing page, or
  /// a page with GraphQL errors, is emitted as a failure and ends the stream.
  ///
  /// ```dart
  /// client.graphql.paginate<String>(
  ///   document: r'query($after: String) { posts(first: 50, after: $after) { '
  ///       'nodes { title } pageInfo { hasNextPage endCursor } } }',
  ///   connectionPath: ['posts'],
  ///   parseNode: (node) => node['title'] as String,
  /// );
  /// ```
  Stream<WordpressResponse<List<N>>> paginate<N>({
    required String document,
    required List<String> connectionPath,
    required N Function(Map<String, dynamic> node) parseNode,
    Map<String, dynamic>? variables,
    String? operationName,
    String afterVariable = 'after',
    int? maxPages,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    bool useGet = false,
  }) async* {
    String? cursor;

    for (var page = 1;; page++) {
      final response = await execute<Map<String, dynamic>>(
        document: document,
        parseData: (data) => data,
        variables: {...?variables, if (cursor != null) afterVariable: cursor},
        operationName: operationName,
        requireAuth: requireAuth,
        authorization: authorization,
        headers: headers,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        useGet: useGet,
      );

      if (response
          is! WordpressSuccessResponse<GraphQLResult<Map<String, dynamic>>>) {
        yield _refail<List<N>>(
          response
              as WordpressFailureResponse<GraphQLResult<Map<String, dynamic>>>,
        );
        return;
      }

      final result = response.data;
      if (result.hasErrors) {
        yield WordpressFailureResponse<List<N>>(
          error: WordpressError(
            code: 'graphql_error',
            message: result.errors.map((e) => e.message).join('; '),
            status: response.code,
          ),
          code: response.code,
          rawData: null,
          headers: response.headers,
          requestHeaders: response.requestHeaders,
          duration: response.duration,
          extra: {...?response.extra, errorsKey: result.errors},
          message: response.message,
        );
        return;
      }

      Object? node = result.data;
      for (final key in connectionPath) {
        node = node is Map<String, dynamic> ? node[key] : null;
      }

      if (node is! Map<String, dynamic>) {
        yield _failure<List<N>>(
          WordpressRawResponse(
            data: null,
            code: response.code,
            headers: response.headers,
            requestHeaders: response.requestHeaders,
            duration: response.duration,
            extra: response.extra ?? const {},
            message: response.message,
          ),
          'graphql_connection_not_found',
          'No connection at data.${connectionPath.join('.')}.',
        );
        return;
      }

      final items = node['nodes'] is List
          ? (node['nodes'] as List)
          : (node['edges'] as List? ?? const [])
              .map((e) => e is Map ? e['node'] : null)
              .toList();

      yield WordpressSuccessResponse<List<N>>(
        data: items
            .whereType<Map<String, dynamic>>()
            .map(parseNode)
            .toList(growable: false),
        code: response.code,
        rawData: null,
        headers: response.headers,
        requestHeaders: response.requestHeaders,
        duration: response.duration,
        extra: response.extra,
        message: response.message,
      );

      final info = node['pageInfo'];
      final next = info is Map<String, dynamic> ? info['endCursor'] : null;
      final hasNext =
          info is Map<String, dynamic> && info['hasNextPage'] == true;

      if (!hasNext ||
          next is! String ||
          (maxPages != null && page >= maxPages)) {
        return;
      }

      cursor = next;
    }
  }

  /// Collects every page of [paginate] into one list.
  ///
  /// The first failing page is returned as is; nodes fetched before it are
  /// discarded.
  Future<WordpressResponse<List<N>>> queryAll<N>({
    required String document,
    required List<String> connectionPath,
    required N Function(Map<String, dynamic> node) parseNode,
    Map<String, dynamic>? variables,
    String? operationName,
    String afterVariable = 'after',
    int? maxPages,
    bool requireAuth = false,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
    bool useGet = false,
  }) async {
    final all = <N>[];
    WordpressSuccessResponse<List<N>>? first;
    var duration = Duration.zero;

    await for (final page in paginate<N>(
      document: document,
      connectionPath: connectionPath,
      parseNode: parseNode,
      variables: variables,
      operationName: operationName,
      afterVariable: afterVariable,
      maxPages: maxPages,
      requireAuth: requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      useGet: useGet,
    )) {
      if (page is! WordpressSuccessResponse<List<N>>) {
        return page;
      }

      first ??= page;
      duration += page.duration;
      all.addAll(page.data);
    }

    final head = first!;

    return WordpressSuccessResponse<List<N>>(
      data: all,
      code: head.code,
      rawData: null,
      headers: head.headers,
      requestHeaders: head.requestHeaders,
      duration: duration,
      extra: head.extra,
      message: head.message,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Query Registration & Reuse
  // ──────────────────────────────────────────────────────────────────────────

  /// Registers a query or mutation for later reuse.
  ///
  /// Registered queries can be executed using [executeRegistered] by name,
  /// avoiding the need to repeat the document and parser everywhere.
  ///
  /// Example:
  /// ```dart
  /// client.graphql.register(
  ///   RegisteredQuery<List<Post>>(
  ///     name: 'getPosts',
  ///     document: '''
  ///       query Posts($limit: Int!) {
  ///         posts(first: $limit) { nodes { id title } }
  ///       }
  ///     ''',
  ///     parseData: (data) {
  ///       final nodes = (data['posts']?['nodes'] as List? ?? [])
  ///           .cast<Map<String, dynamic>>();
  ///       return nodes.map(Post.fromJson).toList();
  ///     },
  ///     defaultVariables: {'limit': 10},
  ///   ),
  /// );
  /// ```
  ///
  /// Throws [ArgumentError] if a query with the same name is already registered
  /// and [allowOverwrite] is `false` (default).
  void register<T>(RegisteredQuery<T> query, {bool allowOverwrite = false}) {
    if (_registry.containsKey(query.name) && !allowOverwrite) {
      throw ArgumentError(
        'A query with name "${query.name}" is already registered. '
        'Use allowOverwrite: true to replace it.',
      );
    }
    _registry[query.name] = query;
  }

  /// Registers multiple queries at once.
  ///
  /// This is a convenience method for registering several queries in one call.
  ///
  /// Example:
  /// ```dart
  /// client.graphql.registerAll([
  ///   postsQuery,
  ///   usersQuery,
  ///   settingsQuery,
  /// ]);
  /// ```
  void registerAll(
    Iterable<RegisteredQuery<dynamic>> queries, {
    bool allowOverwrite = false,
  }) {
    for (final query in queries) {
      register(query, allowOverwrite: allowOverwrite);
    }
  }

  /// Unregisters a query by name.
  ///
  /// Returns `true` if a query was removed, `false` if no query with that
  /// name was registered.
  bool unregister(String name) {
    return _registry.remove(name) != null;
  }

  /// Clears all registered queries.
  void clearRegistry() {
    _registry.clear();
  }

  /// Returns `true` if a query with the given [name] is registered.
  bool isRegistered(String name) => _registry.containsKey(name);

  /// Returns the names of all registered queries.
  Iterable<String> get registeredQueryNames => _registry.keys;

  /// Returns the number of registered queries.
  int get registeredQueryCount => _registry.length;

  /// Retrieves a registered query by name.
  ///
  /// Returns `null` if no query with that name is registered.
  /// The caller must cast to the appropriate type if needed.
  RegisteredQuery<T>? getRegistered<T>(String name) {
    final query = _registry[name];
    if (query == null) return null;
    return query as RegisteredQuery<T>;
  }

  /// Executes a registered query by name.
  ///
  /// The [variables] parameter merges with (and overrides) the query's
  /// [RegisteredQuery.defaultVariables].
  ///
  /// Example:
  /// ```dart
  /// // Execute with default variables
  /// final result = await client.graphql.executeRegistered<List<Post>>('getPosts');
  ///
  /// // Override some variables
  /// final result = await client.graphql.executeRegistered<List<Post>>(
  ///   'getPosts',
  ///   variables: {'limit': 20},
  /// );
  /// ```
  ///
  /// Throws [ArgumentError] if no query with [name] is registered.
  Future<WordpressResponse<T>> executeRegistered<T>(
    String name, {
    Map<String, dynamic>? variables,
    IAuthorization? authorization,
    Map<String, dynamic>? headers,
    bool? requireAuth,
    Duration sendTimeout = DEFAULT_REQUEST_TIMEOUT,
    Duration receiveTimeout = DEFAULT_REQUEST_TIMEOUT,
  }) async {
    final query = _registry[name];
    if (query == null) {
      throw ArgumentError(
        'No query registered with name "$name". '
        'Use register() to register a query first.',
      );
    }

    // Merge default variables with provided ones
    final mergedVariables = <String, dynamic>{
      ...?query.defaultVariables,
      ...?variables,
    };

    return _execute<T>(
      document: query.document,
      parseData: query.parseData as T Function(Map<String, dynamic>),
      variables: mergedVariables.isEmpty ? null : mergedVariables,
      operationName: query.operationName,
      requireAuth: requireAuth ?? query.requireAuth,
      authorization: authorization,
      headers: headers,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }
}
