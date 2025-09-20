import '../../../wordpress_client.dart';

/// Create a Nav Menu Item (POST /wp/v2/menu-items)
final class CreateNavMenuItemRequest extends IRequest {
  CreateNavMenuItemRequest({
    this.title,
    this.type,
    this.status,
    this.parent,
    this.attrTitle,
    this.classes,
    this.description,
    this.menuOrder,
    this.object,
    this.objectId,
    this.target,
    this.url,
    this.xfn,
    this.menus,
    this.meta,
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

  /// The title for the menu item.
  String? title;

  /// The singular type of object.
  /// One of: taxonomy, post_type, post_type_archive, custom.
  String? type; // taxonomy|post_type|post_type_archive|custom

  /// Post status of the menu item.
  ContentStatus? status;

  /// The ID for the parent of the object.
  int? parent;

  /// Text for the title attribute of the link element.
  String? attrTitle;

  /// Class names for the link element.
  List<String>? classes;

  /// The description of the object.
  String? description;

  /// The order of the object in relation to other object of its type.
  int? menuOrder;

  /// The type of object.
  String? object;

  /// The type-specific ID of the object.
  int? objectId;

  /// The target of the link element. Example: _blank.
  String? target; // _blank or empty

  /// The URL to which the link points.
  String? url;

  /// The XFN relationship, as a space separated string.
  List<String>? xfn;

  /// The nav menu IDs this item belongs to.
  List<int>? menus;

  /// Meta fields as arbitrary key/value pairs.
  Map<String, dynamic>? meta;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('title', title)
      ..addIfNotNull('type', type)
      ..addIfNotNull('status', status?.name)
      ..addIfNotNull('parent', parent)
      ..addIfNotNull('attr_title', attrTitle)
      ..addIfNotNull('classes', classes)
      ..addIfNotNull('description', description)
      ..addIfNotNull('menu_order', menuOrder)
      ..addIfNotNull('object', object)
      ..addIfNotNull('object_id', objectId)
      ..addIfNotNull('target', target)
      ..addIfNotNull('url', url)
      ..addIfNotNull('xfn', xfn)
      ..addIfNotNull('menus', menus)
      ..addIfNotNull('meta', meta)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('menu-items'),
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
