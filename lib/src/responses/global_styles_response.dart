import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';
import 'properties/content.dart';

/// Represents Global Styles (wp/v2/global-styles).
@immutable
final class GlobalStyles implements ISelfRespresentive {
  const GlobalStyles({
    required this.id,
    required this.self,
    this.styles,
    this.settings,
    this.title,
  });

  factory GlobalStyles.fromJson(Map<String, dynamic> json) {
    return GlobalStyles(
      id: castOrElse(json['id'], orElse: () => '')!,
      styles: castOrElse<Map<String, dynamic>>(json['styles']),
      settings: castOrElse<Map<String, dynamic>>(json['settings']),
      title: castOrElse(
        json['title'],
        transformer: (v) => v is String
            ? Content(protected: false, rendered: v)
            : Content.fromJson(v as Map<String, dynamic>),
      ),
      self: json,
    );
  }

  /// ID of global styles config.
  final String id;

  /// Global styles object.
  final Map<String, dynamic>? styles;

  /// Global settings object.
  final Map<String, dynamic>? settings;

  /// Title of the global styles variation.
  final Content? title;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'styles': styles,
        'settings': settings,
        'title': title?.toJson(),
      };

  @override
  bool operator ==(covariant GlobalStyles other) {
    if (identical(this, other)) return true;
    final eq = const DeepCollectionEquality().equals;
    return other.id == id &&
        eq(other.styles, styles) &&
        eq(other.settings, settings) &&
        eq(other.title?.toJson(), title?.toJson()) &&
        eq(other.self, self);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      (styles?.hashCode ?? 0) ^
      (settings?.hashCode ?? 0) ^
      (title?.hashCode ?? 0) ^
      self.hashCode;
}
