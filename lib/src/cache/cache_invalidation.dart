/// Result of an invalidation operation.
class InvalidationResult {
  InvalidationResult({
    required this.count,
    required this.invalidatedKeys,
    required this.reason,
    required this.timestamp,
  });

  /// Number of entries invalidated
  final int count;

  /// Keys that were invalidated
  final List<String> invalidatedKeys;

  /// Reason for invalidation
  final String reason;

  /// Timestamp of invalidation
  final DateTime timestamp;

  @override
  String toString() => 'InvalidationResult('
      'count: $count, '
      'reason: $reason, '
      'timestamp: $timestamp)';
}

/// Matcher interface for finding cache entries to invalidate.
abstract interface class IInvalidationMatcher {
  /// Check if a key matches this invalidation pattern
  bool matches(String key);

  /// Get a description of this matcher
  String get description;
}

/// Exact key matcher - matches only the specific key.
class ExactKeyMatcher implements IInvalidationMatcher {
  ExactKeyMatcher(this.key);
  final String key;

  @override
  bool matches(String key) => this.key == key;

  @override
  String get description => 'exact key: $key';
}

/// Glob pattern matcher - matches keys using glob-like patterns.
/// Supports: * (any characters), ? (single character)
class PatternMatcher implements IInvalidationMatcher {
  PatternMatcher(this.pattern) : _regex = _patternToRegex(pattern);
  final String pattern;
  final RegExp _regex;

  @override
  bool matches(String key) => _regex.hasMatch(key);

  @override
  String get description => 'pattern: $pattern';

  static RegExp _patternToRegex(String pattern) {
    final escaped = pattern
        .replaceAll(RegExp(r'[.+^${}()|[\]\\]'), r'\$&')
        .replaceAll('*', '.*')
        .replaceAll('?', '.');

    return RegExp('^$escaped\$');
  }
}

/// Tag-based matcher - matches entries with specific tags.
class TagMatcher implements IInvalidationMatcher {
  // true = must have all tags, false = must have any

  TagMatcher(this.tag, {this.matchAllTags = false});
  final String tag;
  final bool matchAllTags;

  @override
  bool matches(String key) {
    // This needs to be called with tag set, override in invalidation logic
    throw UnimplementedError('TagMatcher needs tag set context');
  }

  bool matchesTags(Set<String> tags) {
    return tags.contains(tag);
  }

  @override
  String get description => 'tag: $tag';
}

/// Prefix matcher - matches all keys with given prefix.
class PrefixMatcher implements IInvalidationMatcher {
  PrefixMatcher(this.prefix);
  final String prefix;

  @override
  bool matches(String key) => key.startsWith(prefix);

  @override
  String get description => 'prefix: $prefix';
}

/// Suffix matcher - matches all keys with given suffix.
class SuffixMatcher implements IInvalidationMatcher {
  SuffixMatcher(this.suffix);
  final String suffix;

  @override
  bool matches(String key) => key.endsWith(suffix);

  @override
  String get description => 'suffix: $suffix';
}

/// Custom predicate matcher - matches based on custom logic.
class PredicateMatcher implements IInvalidationMatcher {
  PredicateMatcher(
    this.predicate, {
    String description = 'custom predicate',
  }) : _description = description;
  final bool Function(String key) predicate;
  final String _description;

  @override
  bool matches(String key) => predicate(key);

  @override
  String get description => _description;
}

/// Smart invalidation matcher that understands WordPress REST API patterns.
/// Examples:
/// - /posts/* -> invalidates all post-related endpoints
/// - /posts/123 -> invalidates specific post
/// - /posts/123/revisions -> invalidates post revisions
class WordpressPathMatcher implements IInvalidationMatcher {
  WordpressPathMatcher(this.pathPattern)
      : _regex = _buildWordpressRegex(pathPattern);
  final String pathPattern;
  final RegExp _regex;

  @override
  bool matches(String key) => _regex.hasMatch(key);

  @override
  String get description => 'wordpress path: $pathPattern';

  static RegExp _buildWordpressRegex(String pattern) {
    // Handle WordPress-specific patterns
    final regex = pattern
        .replaceAll(RegExp(r'[.+^${}()|[\]\\]'), r'\$&')
        .replaceAll('/**', '/.*')
        .replaceAll('/*', '/[^/]*')
        .replaceAll('*', '.*')
        .replaceAll('?', '.');

    return RegExp('^$regex(\\?|&|\$)');
  }
}

/// Builder for creating complex invalidation matchers.
class InvalidationMatcher {
  /// Match exact key
  static ExactKeyMatcher exact(String key) => ExactKeyMatcher(key);

  /// Match using glob pattern
  static PatternMatcher pattern(String pattern) => PatternMatcher(pattern);

  /// Match by tag
  static TagMatcher tag(String tag) => TagMatcher(tag);

  /// Match by prefix
  static PrefixMatcher prefix(String prefix) => PrefixMatcher(prefix);

  /// Match by suffix
  static SuffixMatcher suffix(String suffix) => SuffixMatcher(suffix);

  /// Match by custom predicate
  static PredicateMatcher predicate(
    bool Function(String key) predicate, {
    String description = 'custom predicate',
  }) =>
      PredicateMatcher(predicate, description: description);

  /// Match WordPress REST API paths
  static WordpressPathMatcher wordpressPath(String pattern) =>
      WordpressPathMatcher(pattern);

  /// Match all keys
  static PredicateMatcher all() => PredicateMatcher(
        (_) => true,
        description: 'all entries',
      );
}
