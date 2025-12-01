import '../../../wordpress_client.dart';

/// Create a Nav_Menu
final class CreateNavMenuRequest extends IRequest {
  CreateNavMenuRequest({
    required this.name,
    this.description,
    this.slug,
    this.meta,
    this.locations,
    this.autoAdd,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// The name of the menu.
  String name;

  /// HTML description of the menu.
  String? description;

  /// An alphanumeric identifier for the menu unique to its type.
  String? slug;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  /// Locations in which the menu is assigned.
  List<String>? locations;

  /// Whether to auto-add top-level pages to this menu.
  bool? autoAdd;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('name', name)
      ..addIfNotNull('description', description)
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('meta', meta)
      ..addIfNotNull('locations', locations)
      ..addIfNotNull('auto_add', autoAdd)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('menus'),
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
