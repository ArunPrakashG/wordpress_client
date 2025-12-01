import 'package:meta/meta.dart';

import '../utilities/helpers.dart';
import '../utilities/self_representive_base.dart';

/// Represents a block directory search item (wp/v2/block-directory/search).
@immutable
class BlockDirectoryItem implements ISelfRespresentive {
  const BlockDirectoryItem({
    required this.name,
    required this.title,
    required this.id,
    required this.self,
    this.description,
    this.rating,
    this.ratingCount,
    this.activeInstalls,
    this.authorBlockRating,
    this.authorBlockCount,
    this.author,
    this.icon,
    this.lastUpdated,
    this.humanizedUpdated,
  });

  factory BlockDirectoryItem.fromJson(Map<String, dynamic> json) =>
      BlockDirectoryItem(
        name: json['name'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        id: json['id'] as String,
        rating: castOrElse(json['rating']),
        ratingCount: castOrElse(json['rating_count']),
        activeInstalls: castOrElse(json['active_installs']),
        authorBlockRating: castOrElse(json['author_block_rating']),
        authorBlockCount: castOrElse(json['author_block_count']),
        author: json['author'] as String?,
        icon: json['icon'] as String?,
        lastUpdated: parseDateIfNotNull(castOrElse(json['last_updated'])),
        humanizedUpdated: json['humanized_updated'] as String?,
        self: json,
      );

  final String name;
  final String title;
  final String? description;
  final String id;
  final num? rating;
  final int? ratingCount;
  final int? activeInstalls;
  final num? authorBlockRating;
  final int? authorBlockCount;
  final String? author;
  final String? icon;
  final DateTime? lastUpdated;
  final String? humanizedUpdated;

  @override
  final Map<String, dynamic> self;
}
