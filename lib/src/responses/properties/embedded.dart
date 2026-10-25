import '../../utilities/self_representive_base.dart';
import '../category_response.dart';
import '../comment_response.dart';
import '../media_response.dart';
import '../tag_response.dart';
import '../user_response.dart';

/// Typed view of the `_embedded` object WordPress adds when a request is made
/// with `_embed` (see `withEmbed` on the fluent builders).
///
/// ```dart
/// final post = await client.posts.query.withEmbed().withPerPage(1).execute();
/// final embedded = post.dataOrThrow().first.embedded;
/// print(embedded.author?.name);
/// print(embedded.featuredMedia?.sourceUrl);
/// ```
///
/// Everything is `null` / empty when the response was fetched without
/// `_embed`, or when an embedded item could not be resolved (WordPress embeds
/// an error object in that case, which is skipped).
final class Embedded {
  /// Wraps an `_embedded` map.
  const Embedded(this.raw);

  /// Reads the `_embedded` object of [resource].
  factory Embedded.of(ISelfRespresentive resource) {
    final value = resource.self['_embedded'];
    return Embedded(
      value is Map<String, dynamic> ? value : const <String, dynamic>{},
    );
  }

  /// The untouched `_embedded` map.
  final Map<String, dynamic> raw;

  /// `true` when the response carried embedded data.
  bool get isPresent => raw.isNotEmpty;

  /// The embedded author, if any.
  User? get author => _first('author', User.fromJson);

  /// The embedded featured media, if any.
  Media? get featuredMedia => _first('wp:featuredmedia', Media.fromJson);

  /// The embedded parent / post the resource refers to (`up`), as raw JSON.
  Map<String, dynamic>? get up => _first('up', (json) => json);

  /// Embedded categories.
  List<Category> get categories =>
      _parseAll(terms('category'), Category.fromJson);

  /// Embedded tags.
  List<Tag> get tags => _parseAll(terms('post_tag'), Tag.fromJson);

  /// Embedded replies (comments).
  List<Comment> get replies => _parseAll(items('replies'), Comment.fromJson);

  /// Embedded terms of [taxonomy] (`category`, `post_tag`, or a custom one),
  /// as raw JSON maps.
  List<Map<String, dynamic>> terms(String taxonomy) {
    final value = raw['wp:term'];
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .expand<dynamic>((e) => e is List ? e : [e])
        .whereType<Map<String, dynamic>>()
        .where((term) => _isResolved(term) && term['taxonomy'] == taxonomy)
        .toList(growable: false);
  }

  /// All embedded items of a link relation (for example `wp:attachment`), as
  /// raw JSON maps.
  List<Map<String, dynamic>> items(String relation) {
    final value = raw[relation];
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .expand<dynamic>((e) => e is List ? e : [e])
        .whereType<Map<String, dynamic>>()
        .where(_isResolved)
        .toList(growable: false);
  }

  T? _first<T>(String relation, T Function(Map<String, dynamic>) parse) {
    final list = items(relation);
    return list.isEmpty ? null : _tryParse(list.first, parse);
  }

  // Embedded items can be trimmed (`_fields`) or come from plugins; an item
  // that does not fit the model is skipped instead of throwing.
  static T? _tryParse<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) {
    try {
      return parse(json);
    } catch (_) {
      return null;
    }
  }

  static List<T> _parseAll<T>(
    Iterable<Map<String, dynamic>> items,
    T Function(Map<String, dynamic>) parse,
  ) {
    return items
        .map((json) => _tryParse(json, parse))
        .whereType<T>()
        .toList(growable: false);
  }

  // WordPress embeds `{code, message, data}` for links it could not resolve.
  static bool _isResolved(Map<String, dynamic> json) =>
      !(json.containsKey('code') && json.containsKey('message'));
}

/// Adds [embedded] to every response model.
extension EmbeddedResource on ISelfRespresentive {
  /// Typed access to the `_embedded` data of this resource.
  Embedded get embedded => Embedded.of(this);
}
