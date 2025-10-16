import 'package:meta/meta.dart';

/// Enhanced cache entry with tag support, size tracking, and access metrics.
@immutable
class AdvancedCacheEntry<T> {
  const AdvancedCacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.sizeBytes,
    this.tags = const {},
    this.expiresAt,
    this.accessCount = 0,
    this.lastAccessedAt,
    this.isCompressed = false,
    this.priority = 5,
  });

  /// The unique key for this entry
  final String key;

  /// The cached data
  final T value;

  /// Set of tags associated with this entry (for group invalidation)
  final Set<String> tags;

  /// Time when entry was created
  final DateTime createdAt;

  /// Time when entry expires (null = never)
  final DateTime? expiresAt;

  /// Size of the entry in bytes (approximate)
  final int sizeBytes;

  /// Number of times this entry has been accessed
  final int accessCount;

  /// Last time this entry was accessed
  final DateTime? lastAccessedAt;

  /// Whether this entry is compressed
  final bool isCompressed;

  /// Priority level (0-10, where 10 is highest)
  final int priority;

  /// Whether this entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;

    final now = DateTime.now();
    return !now.isBefore(expiresAt!);
  }

  /// Age of this entry in seconds
  int get ageSeconds => DateTime.now().difference(createdAt).inSeconds;

  /// Time since last access in seconds (or age if never accessed)
  int get timeSinceLastAccessSeconds {
    if (lastAccessedAt == null) return ageSeconds;
    return DateTime.now().difference(lastAccessedAt!).inSeconds;
  }

  /// Create a copy with updated fields
  AdvancedCacheEntry<T> copyWith({
    String? key,
    T? value,
    Set<String>? tags,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? sizeBytes,
    int? accessCount,
    DateTime? lastAccessedAt,
    bool? isCompressed,
    int? priority,
  }) {
    return AdvancedCacheEntry(
      key: key ?? this.key,
      value: value ?? this.value,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCompressed: isCompressed ?? this.isCompressed,
      priority: priority ?? this.priority,
    );
  }

  /// Create entry with updated access tracking
  AdvancedCacheEntry<T> withAccess() {
    return copyWith(
      accessCount: accessCount + 1,
      lastAccessedAt: DateTime.now(),
    );
  }

  @override
  String toString() => '''AdvancedCacheEntry(
  key: $key,
  age: ${ageSeconds}s,
  accesses: $accessCount,
  priority: $priority,
  size: $sizeBytes bytes,
  tags: $tags,
  expired: $isExpired,
)''';
}
