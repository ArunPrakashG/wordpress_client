// ignore_for_file: comment_references

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

@immutable

/// A helper class that wraps around URI to provide a more flexible way of building request URLs.
///
/// This class allows you to create and manipulate URLs for API requests, supporting both relative
/// and absolute URLs. It provides methods to create URLs from various inputs and can merge
/// relative URLs with a base URL.
class RequestUrl {
  const RequestUrl._(this._uri, this._endpoint);

  /// Creates a new [RequestUrl] instance from the given relative endpoint.
  ///
  /// Use this when you have a relative path that needs to be combined with a base URL later.
  ///
  /// Example:
  /// ```dart
  /// final url = RequestUrl.relative('/api/users');
  /// ```
  factory RequestUrl.relative(String endpoint) {
    return RequestUrl._(null, endpoint);
  }

  /// Creates a new [RequestUrl] instance from the given relative endpoint parts.
  ///
  /// The parts are joined together using [joinAll] from the `path` package.
  /// This is useful when you want to construct a path from multiple segments.
  ///
  /// Example:
  /// ```dart
  /// final url = RequestUrl.relativeParts(['api', 'users', 123]);
  /// ```
  factory RequestUrl.relativeParts(Iterable<dynamic> parts) {
    // Always use URL-style forward slashes regardless of OS path separator
    final endpoint = parts.map((e) => e.toString()).join('/');
    return RequestUrl._(null, endpoint);
  }

  /// Creates a new [RequestUrl] instance from the given absolute [Uri].
  ///
  /// Use this when you have a complete URL and don't need to combine it with a base URL.
  ///
  /// Example:
  /// ```dart
  /// final url = RequestUrl.absolute(Uri.parse('https://api.example.com/users'));
  /// ```
  factory RequestUrl.absolute(Uri uri) {
    return RequestUrl._(uri, null);
  }

  /// Creates a new [RequestUrl] instance by merging the given [uri] with an optional [base] [Uri].
  ///
  /// If [base] is provided, it combines the path segments of both URIs.
  /// If [base] is null, it returns the [uri] as is.
  ///
  /// This is useful when you want to combine a relative URL with a base URL.
  ///
  /// Example:
  /// ```dart
  /// final baseUri = Uri.parse('https://api.example.com');
  /// final relativeUri = Uri.parse('/users/123');
  /// final url = RequestUrl.absoluteMerge(relativeUri, baseUri);
  /// ```
  factory RequestUrl.absoluteMerge(Uri uri, [Uri? base]) {
    if (base == null) {
      return RequestUrl._(uri, null);
    }

    final newPathSegments = base.pathSegments..addAll(uri.pathSegments);

    return RequestUrl._(
      uri.replace(pathSegments: newPathSegments),
      null,
    );
  }

  final Uri? _uri;
  final String? _endpoint;

  /// Returns true if this instance holds a relative URL, false otherwise.
  bool get isRelative {
    return _uri == null && _endpoint != null && _endpoint!.isNotEmpty;
  }

  /// Returns true if this instance holds an absolute URL, false otherwise.
  bool get isAbsolute => !isRelative;

  /// Returns the absolute [Uri] if this instance holds one.
  ///
  /// Throws a [StateError] if this instance holds a relative URL.
  Uri get uri {
    if (isRelative) {
      throw StateError('This instance holds a relative URL.');
    }

    return _uri!;
  }

  @override
  String toString() {
    if (isRelative) {
      return _endpoint!;
    }

    return _uri.toString();
  }

  @override
  bool operator ==(covariant RequestUrl other) {
    if (identical(this, other)) {
      return true;
    }

    return other._uri == _uri && other._endpoint == _endpoint;
  }

  @override
  int get hashCode => _uri.hashCode ^ _endpoint.hashCode;
}
