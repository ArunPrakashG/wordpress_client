import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// A capability registered with the WordPress Abilities API (WordPress 6.9+).
///
/// An ability is a named, self-describing unit of functionality, such as
/// `my-plugin/get-site-info`, that can be discovered and run over REST.
/// Only abilities registered with `show_in_rest` are visible to the client.
@immutable
final class Ability implements ISelfRespresentive {
  const Ability({
    required this.name,
    required this.self,
    this.label,
    this.description,
    this.category,
    this.inputSchema,
    this.outputSchema,
    this.meta,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: castOrElse(json['name'], orElse: () => '')!,
      label: castOrElse(json['label']),
      description: castOrElse(json['description']),
      category: castOrElse(json['category']),
      inputSchema: castOrElse<Map<String, dynamic>>(json['input_schema']),
      outputSchema: castOrElse<Map<String, dynamic>>(json['output_schema']),
      meta: castOrElse<Map<String, dynamic>>(json['meta']),
      self: json,
    );
  }

  /// Unique identifier in `namespace/ability` form.
  final String name;

  /// Human readable name.
  final String? label;

  /// What the ability does.
  final String? description;

  /// Slug of the [AbilityCategory] this ability belongs to.
  final String? category;

  /// JSON Schema of the accepted input, if the ability takes any.
  final Map<String, dynamic>? inputSchema;

  /// JSON Schema of the returned output.
  final Map<String, dynamic>? outputSchema;

  /// Additional metadata, including `annotations`.
  final Map<String, dynamic>? meta;

  @override
  final Map<String, dynamic> self;

  /// The `meta.annotations` object, or an empty map.
  Map<String, dynamic> get annotations =>
      castOrElse<Map<String, dynamic>>(meta?['annotations']) ??
      const <String, dynamic>{};

  /// The ability only reads data (it can be run with `GET`).
  bool get isReadOnly => annotations['readonly'] == true;

  /// The ability deletes or destroys data (it is run with `DELETE`).
  bool get isDestructive => annotations['destructive'] == true;

  /// Running the ability repeatedly has the same effect as running it once.
  bool get isIdempotent => annotations['idempotent'] == true;

  /// The HTTP method the REST API expects when running this ability:
  /// `GET` for read-only, `DELETE` for destructive, `POST` otherwise.
  String get runMethod {
    if (isReadOnly) {
      return 'GET';
    }

    return isDestructive ? 'DELETE' : 'POST';
  }

  Map<String, dynamic> toJson() => self;

  @override
  bool operator ==(Object other) =>
      other is Ability &&
      const DeepCollectionEquality().equals(other.self, self);

  @override
  int get hashCode => const DeepCollectionEquality().hash(self);

  @override
  String toString() => 'Ability($name)';
}

/// A group of related [Ability] entries.
@immutable
final class AbilityCategory implements ISelfRespresentive {
  const AbilityCategory({
    required this.slug,
    required this.self,
    this.label,
    this.description,
    this.meta,
  });

  factory AbilityCategory.fromJson(Map<String, dynamic> json) {
    return AbilityCategory(
      slug: castOrElse(json['slug'], orElse: () => '')!,
      label: castOrElse(json['label']),
      description: castOrElse(json['description']),
      meta: castOrElse<Map<String, dynamic>>(json['meta']),
      self: json,
    );
  }

  final String slug;
  final String? label;
  final String? description;
  final Map<String, dynamic>? meta;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => self;

  @override
  bool operator ==(Object other) =>
      other is AbilityCategory &&
      const DeepCollectionEquality().equals(other.self, self);

  @override
  int get hashCode => const DeepCollectionEquality().hash(self);

  @override
  String toString() => 'AbilityCategory($slug)';
}
