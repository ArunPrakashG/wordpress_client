import '../../../wordpress_client.dart';

/// Update a Nav Menu Item (POST /wp/v2/menu-items/<id>)
final class UpdateNavMenuItemRequest extends IRequest {
  UpdateNavMenuItemRequest({
    required this.id,
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

  /// Unique identifier for the menu item.
  int id;

  /// The title for the object.
  String? title;

  /// Type of the menu item.
  String? type;

  /// Status of the menu item.
  ContentStatus? status;

  /// The ID of the parent menu item.
  int? parent;

  /// Text for the title attribute of the link.
  String? attrTitle;

  /// CSS classes for the link element.
  List<String>? classes;

  /// Description of the menu item.
  String? description;

  /// The order this item appears in the menu.
  int? menuOrder;

  /// The type of object originally associated with this menu item.
  String? object;

  /// The database ID of the original object this menu item represents.
  int? objectId;

  /// The target attribute of the link element.
  String? target;

  /// The URL to which this menu item links.
  String? url;

  /// The XFN relationship expressed in the link of this menu item.
  List<String>? xfn;

  /// Menu IDs this item belongs to.
  List<int>? menus;

  /// Meta fields.
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
      url: RequestUrl.relativeParts(['menu-items', id]),
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
