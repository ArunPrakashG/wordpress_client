// ignore_for_file: comment_references

import 'package:meta/meta.dart';
import 'package:path/path.dart';

@immutable

/// An helper class which wraps around URI to provide a more flexible way of building request URLs.
class RequestUrl {
  const RequestUrl._(this._uri, this._endpoint);

  /// Creates a new [RequestUrl] instance from the given relative endpoint.
  ///
  /// This URL is then merged internally with the [baseUrl] to create the final request URL.
  factory RequestUrl.relative(String endpoint) {
    return RequestUrl._(null, endpoint);
  }

  /// Creates a new [RequestUrl] instance from the given relative endpoint parts. The parts are joined together using [joinAll].
  ///
  /// This URL is then merged internally with the [baseUrl] to create the final request URL.
  factory RequestUrl.relativeParts(Iterable<dynamic> parts) {
    return RequestUrl._(null, joinAll(parts.map((e) => e.toString())));
  }

  /// Creates a new [RequestUrl] instance from the given absolute [Uri].
  factory RequestUrl.absolute(Uri uri) {
    return RequestUrl._(uri, null);
  }

  /// Creates a new [RequestUrl] instance from the given absolute [Uri] and merges it with the given [base] [Uri].
  ///
  /// If the [base] is null, the [uri] is returned as is.
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

  /// Gets if this instance holds a relative URL.
  bool get isRelative {
    return _uri == null && _endpoint != null && _endpoint!.isNotEmpty;
  }

  /// Gets if this instance holds an absolute URL.
  bool get isAbsolute => !isRelative;

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
