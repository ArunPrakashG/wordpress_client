import 'dart:convert';

import 'package:dio/dio.dart';

import '../../wordpress_client.dart';

/// Interface for the WordPress Abilities API (`/wp-abilities/v1`, WordPress 6.9+).
///
/// Abilities are discoverable, self-describing functions that plugins expose
/// over REST. The endpoints require an authenticated user and only list
/// abilities registered with `show_in_rest`.
///
/// ```dart
/// final abilities = await client.abilities.list();
/// final result = await client.abilities.run(
///   'my-plugin/get-user-info',
///   input: {'user_id': 1},
/// );
/// ```
final class AbilitiesInterface extends IRequestInterface {
  static const _namespace = 'wp-abilities/v1';

  /// The Abilities API root on the client's own origin, e.g.
  /// `https://example.com/wp-json/wp-abilities/v1`.
  Uri get _root {
    final base = baseUrl;
    final segments = base.pathSegments;
    final marker = segments.indexOf('wp-json');
    final prefix = marker >= 0
        ? segments.sublist(0, marker + 1)
        : <String>[...segments.where((s) => s.isNotEmpty), 'wp-json'];

    return Uri(
      scheme: base.scheme,
      userInfo: base.userInfo,
      host: base.host,
      port: base.hasPort ? base.port : null,
      pathSegments: [...prefix, ..._namespace.split('/')],
    );
  }

  WordpressRequest _request(
    List<String> parts, {
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? query,
    dynamic body,
    CancelToken? cancelToken,
  }) {
    final root = _root;

    return WordpressRequest(
      method: method,
      url: RequestUrl.absolute(
        root.replace(pathSegments: [...root.pathSegments, ...parts]),
      ),
      queryParameters: query,
      body: body,
      requireAuth: true,
      cancelToken: cancelToken,
    );
  }

  /// Name segments: `my-plugin/get-info` becomes two path segments.
  List<String> _nameParts(String name) {
    final parts = name.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Ability name must not be empty');
    }

    return parts;
  }

  /// Lists registered abilities, optionally filtered by [category] slug.
  Future<WordpressResponse<List<Ability>>> list({
    int page = 1,
    int perPage = 50,
    String? category,
    CancelToken? cancelToken,
  }) {
    return executor.list<Ability>(
      _request(
        const ['abilities'],
        query: {
          'page': page,
          'per_page': perPage,
          if (category != null) 'category': category,
        },
        cancelToken: cancelToken,
      ),
    );
  }

  /// Fetches every page of [list] and returns all abilities.
  Future<WordpressResponse<List<Ability>>> listAll({
    String? category,
    CancelToken? cancelToken,
  }) async {
    final all = <Ability>[];
    WordpressSuccessResponse<List<Ability>>? first;

    for (var page = 1;; page++) {
      final response = await list(
        page: page,
        perPage: 100,
        category: category,
        cancelToken: cancelToken,
      );

      if (response is! WordpressSuccessResponse<List<Ability>>) {
        return response;
      }

      first ??= response;
      all.addAll(response.data);

      final totalPages = response.totalPagesCount;
      if (totalPages > 0 ? page >= totalPages : response.data.length < 100) {
        break;
      }
    }

    return WordpressSuccessResponse<List<Ability>>(
      headers: first.headers,
      duration: first.duration,
      data: all,
      rawData: null,
      requestHeaders: first.requestHeaders,
      code: first.code,
      extra: first.extra,
      message: first.message,
    );
  }

  /// Fetches one ability by its `namespace/ability` [name].
  Future<WordpressResponse<Ability>> retrieve(
    String name, {
    CancelToken? cancelToken,
  }) {
    return executor.retrieve<Ability>(
      _request(
        ['abilities', ..._nameParts(name)],
        cancelToken: cancelToken,
      ),
    );
  }

  /// Lists ability categories.
  Future<WordpressResponse<List<AbilityCategory>>> categories({
    int page = 1,
    int perPage = 50,
    CancelToken? cancelToken,
  }) {
    return executor.list<AbilityCategory>(
      _request(
        const ['categories'],
        query: {'page': page, 'per_page': perPage},
        cancelToken: cancelToken,
      ),
    );
  }

  /// Fetches one ability category by [slug].
  Future<WordpressResponse<AbilityCategory>> category(
    String slug, {
    CancelToken? cancelToken,
  }) {
    return executor.retrieve<AbilityCategory>(
      _request(['categories', slug], cancelToken: cancelToken),
    );
  }

  /// Runs the ability called [name] and returns its output.
  ///
  /// The REST API wants the HTTP method to match what the ability does:
  /// `GET` for read-only abilities, `DELETE` for destructive ones and `POST`
  /// otherwise. With only a [name] the ability is looked up first to learn
  /// which one applies, unless [method] is given. [runAbility] skips that
  /// lookup when you already hold the [Ability].
  ///
  /// [input] is any JSON encodable value; the output is whatever the ability
  /// returns (object, list, scalar or null).
  Future<WordpressResponse<dynamic>> run(
    String name, {
    Object? input,
    HttpMethod? method,
    CancelToken? cancelToken,
  }) async {
    var chosen = method;

    if (chosen == null) {
      final lookup = await retrieve(name, cancelToken: cancelToken);
      if (lookup is! WordpressSuccessResponse<Ability>) {
        return WordpressFailureResponse<dynamic>(
          error: (lookup as WordpressFailureResponse<Ability>).error,
          code: lookup.code,
          headers: lookup.headers,
          rawData: null,
          duration: lookup.duration,
          message: lookup.message,
          extra: lookup.extra,
          requestHeaders: lookup.requestHeaders,
        );
      }

      chosen = _methodFor(lookup.data);
    }

    return _run(name, input, chosen, cancelToken);
  }

  /// Runs [ability], choosing the HTTP method from its annotations.
  Future<WordpressResponse<dynamic>> runAbility(
    Ability ability, {
    Object? input,
    CancelToken? cancelToken,
  }) {
    return _run(ability.name, input, _methodFor(ability), cancelToken);
  }

  HttpMethod _methodFor(Ability ability) {
    return switch (ability.runMethod) {
      'GET' => HttpMethod.get,
      'DELETE' => HttpMethod.delete,
      _ => HttpMethod.post,
    };
  }

  Future<WordpressResponse<dynamic>> _run(
    String name,
    Object? input,
    HttpMethod method,
    CancelToken? cancelToken,
  ) async {
    final usesQuery = method == HttpMethod.get || method == HttpMethod.delete;

    final raw = await executor.raw(
      _request(
        ['abilities', ..._nameParts(name), 'run'],
        method: method,
        query: usesQuery && input != null ? {'input': jsonEncode(input)} : null,
        body: usesQuery ? null : {'input': input},
        cancelToken: cancelToken,
      ),
    );

    return raw.asResponse<dynamic>(decoder: (data) => data);
  }
}
