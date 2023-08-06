import 'package:meta/meta.dart';
import 'package:path/path.dart';

@immutable
class RequestUrl {
  const RequestUrl._(this._uri, this._endpoint);

  factory RequestUrl.relative(String endpoint) {
    return RequestUrl._(null, endpoint);
  }

  factory RequestUrl.relativeParts(Iterable<dynamic> parts) {
    return RequestUrl._(null, joinAll(parts.map((e) => e.toString())));
  }

  factory RequestUrl.absolute(Uri uri) {
    return RequestUrl._(uri, null);
  }

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

  bool get isRelative {
    return _uri == null && _endpoint != null && _endpoint!.isNotEmpty;
  }

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
