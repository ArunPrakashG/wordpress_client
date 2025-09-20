import '../../../wordpress_client.dart';

/// Update a Nav_Menu
final class UpdateNavMenuRequest extends IRequest {
  UpdateNavMenuRequest({
    required this.id,
    this.description,
    this.name,
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

  /// Unique identifier for the nav menu.
  int id;

  /// HTML description for the menu.
  String? description;

  /// Name for the menu.
  String? name;

  /// An alphanumeric identifier for the menu.
  String? slug;

  /// Meta fields.
  Map<String, dynamic>? meta;

  /// Locations the menu is assigned to.
  List<String>? locations;

  /// Whether to automatically add top-level pages to this menu.
  bool? autoAdd;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('description', description)
      ..addIfNotNull('name', name)
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
      url: RequestUrl.relativeParts(['menus', id]),
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
