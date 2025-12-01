import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents site settings accessed via /wp/v2/settings.
@immutable
final class Settings implements ISelfRespresentive {
  const Settings({
    required this.self,
    this.title,
    this.description,
    this.url,
    this.email,
    this.timezone,
    this.dateFormat,
    this.timeFormat,
    this.startOfWeek,
    this.language,
    this.useSmilies,
    this.defaultCategory,
    this.defaultPostFormat,
    this.postsPerPage,
    this.showOnFront,
    this.pageOnFront,
    this.pageForPosts,
    this.defaultPingStatus,
    this.defaultCommentStatus,
    this.siteLogo,
    this.siteIcon,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      title: castOrElse(json['title']),
      description: castOrElse(json['description']),
      url: castOrElse(json['url']),
      email: castOrElse(json['email']),
      timezone: castOrElse(json['timezone']),
      dateFormat: castOrElse(json['date_format']),
      timeFormat: castOrElse(json['time_format']),
      startOfWeek: castOrElse(json['start_of_week']),
      language: castOrElse(json['language']),
      useSmilies: castOrElse(json['use_smilies']),
      defaultCategory: castOrElse(json['default_category']),
      defaultPostFormat: castOrElse(json['default_post_format']),
      postsPerPage: castOrElse(json['posts_per_page']),
      showOnFront: castOrElse(json['show_on_front']),
      pageOnFront: castOrElse(json['page_on_front']),
      pageForPosts: castOrElse(json['page_for_posts']),
      defaultPingStatus: castOrElse(json['default_ping_status']),
      defaultCommentStatus: castOrElse(json['default_comment_status']),
      siteLogo: castOrElse(json['site_logo']),
      siteIcon: castOrElse(json['site_icon']),
      self: json,
    );
  }

  final String? title;
  final String? description;
  final String? url;
  final String? email;
  final String? timezone;
  final String? dateFormat;
  final String? timeFormat;
  final int? startOfWeek;
  final String? language;
  final bool? useSmilies;
  final int? defaultCategory;
  final String? defaultPostFormat;
  final int? postsPerPage;
  final String? showOnFront;
  final int? pageOnFront;
  final int? pageForPosts;
  final String? defaultPingStatus;
  final String? defaultCommentStatus;
  final int? siteLogo;
  final int? siteIcon;

  @override
  final Map<String, dynamic> self;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'url': url,
        'email': email,
        'timezone': timezone,
        'date_format': dateFormat,
        'time_format': timeFormat,
        'start_of_week': startOfWeek,
        'language': language,
        'use_smilies': useSmilies,
        'default_category': defaultCategory,
        'default_post_format': defaultPostFormat,
        'posts_per_page': postsPerPage,
        'show_on_front': showOnFront,
        'page_on_front': pageOnFront,
        'page_for_posts': pageForPosts,
        'default_ping_status': defaultPingStatus,
        'default_comment_status': defaultCommentStatus,
        'site_logo': siteLogo,
        'site_icon': siteIcon,
      };

  @override
  bool operator ==(covariant Settings other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.self, self) &&
        other.title == title &&
        other.description == description &&
        other.url == url &&
        other.email == email &&
        other.timezone == timezone &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.startOfWeek == startOfWeek &&
        other.language == language &&
        other.useSmilies == useSmilies &&
        other.defaultCategory == defaultCategory &&
  other.defaultPostFormat == defaultPostFormat &&
  other.postsPerPage == postsPerPage &&
  other.showOnFront == showOnFront &&
  other.pageOnFront == pageOnFront &&
  other.pageForPosts == pageForPosts &&
  other.defaultPingStatus == defaultPingStatus &&
  other.defaultCommentStatus == defaultCommentStatus &&
  other.siteLogo == siteLogo &&
  other.siteIcon == siteIcon;
  }

  @override
  int get hashCode =>
      self.hashCode ^
      title.hashCode ^
      description.hashCode ^
      url.hashCode ^
      email.hashCode ^
      timezone.hashCode ^
      dateFormat.hashCode ^
      timeFormat.hashCode ^
      startOfWeek.hashCode ^
      language.hashCode ^
      useSmilies.hashCode ^
      defaultCategory.hashCode ^
    defaultPostFormat.hashCode ^
    postsPerPage.hashCode ^
    showOnFront.hashCode ^
    pageOnFront.hashCode ^
    pageForPosts.hashCode ^
    defaultPingStatus.hashCode ^
    defaultCommentStatus.hashCode ^
    siteLogo.hashCode ^
    siteIcon.hashCode;
}
