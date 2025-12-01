import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a WordPress Post Status (e.g., publish, draft).
@immutable
final class PostStatus implements ISelfRespresentive {
  const PostStatus({
    required this.slug,
    required this.self,
    this.name,
    this.public,
    this.private,
    this.protected,
    this.queryable,
    this.excludeFromSearch,
    this.showInList,
    this.showInAdminAllList,
    this.showInAdminStatusList,
    this.dateFloating,
    this.links,
  });

  factory PostStatus.fromJson(Map<String, dynamic> json) {
    return PostStatus(
      slug: castOrElse(json['slug'], orElse: () => '')!,
      name: castOrElse(json['name']),
      public: castOrElse(json['public']),
      private: castOrElse(json['private']),
      protected: castOrElse(json['protected']),
      queryable: castOrElse(json['queryable']),
      excludeFromSearch: castOrElse(json['exclude_from_search']),
      showInList: castOrElse(json['show_in_list']),
      showInAdminAllList: castOrElse(json['show_in_admin_all_list']),
      showInAdminStatusList: castOrElse(json['show_in_admin_status_list']),
      dateFloating: castOrElse(json['date_floating']),
      links: castOrElse<Map<String, dynamic>>(json['_links']),
      self: json,
    );
  }

  final String slug;
  final String? name;
  final bool? public;
  final bool? private;
  final bool? protected;
  final bool? queryable;
  final bool? excludeFromSearch;
  final bool? showInList;
  final bool? showInAdminAllList;
  final bool? showInAdminStatusList;
  final bool? dateFloating;
  final Map<String, dynamic>? links;
  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'slug': slug,
        'name': name,
        'public': public,
        'private': private,
        'protected': protected,
        'queryable': queryable,
        'exclude_from_search': excludeFromSearch,
        'show_in_list': showInList,
        'show_in_admin_all_list': showInAdminAllList,
        'show_in_admin_status_list': showInAdminStatusList,
        'date_floating': dateFloating,
        '_links': links,
      };

  @override
  bool operator ==(covariant PostStatus other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;
    return other.slug == slug &&
        other.name == name &&
        other.public == public &&
        other.private == private &&
        other.protected == protected &&
        other.queryable == queryable &&
        other.excludeFromSearch == excludeFromSearch &&
        other.showInList == showInList &&
        other.showInAdminAllList == showInAdminAllList &&
        other.showInAdminStatusList == showInAdminStatusList &&
        other.dateFloating == dateFloating &&
        mapEquals(other.links, links) &&
        mapEquals(other.self, self);
  }

  @override
  int get hashCode =>
      slug.hashCode ^
      name.hashCode ^
      public.hashCode ^
      private.hashCode ^
      protected.hashCode ^
      queryable.hashCode ^
      excludeFromSearch.hashCode ^
      showInList.hashCode ^
      showInAdminAllList.hashCode ^
      showInAdminStatusList.hashCode ^
      dateFloating.hashCode ^
      links.hashCode ^
      self.hashCode;
}
