/// The REST root of the site behind [base] with [namespace] appended, on the
/// same origin: `https://example.com/wp-json/<namespace>`.
///
/// [base] is the client's base URL (normally `.../wp-json/wp/v2`); everything
/// from the `wp-json` segment on is replaced.
Uri restRoot(Uri base, String namespace) {
  final segments = base.pathSegments;
  final marker = segments.indexOf('wp-json');
  final prefix = marker >= 0
      ? segments.sublist(0, marker + 1)
      : <String>[...segments.where((s) => s.isNotEmpty), 'wp-json'];

  return Uri(
    scheme: base.scheme,
    userInfo: base.userInfo,
    host: base.host,
    port: base.hasPort ? base.port : null,
    pathSegments: [
      ...prefix,
      ...namespace.split('/').where((s) => s.isNotEmpty),
    ],
  );
}
