import '../../wordpress_client.dart';

final class MenusExtensions implements IInterfaceExtensions<NavMenu, int> {
  MenusExtensions(this._iface);
  final MenusInterface _iface;

  @override
  Future<WordpressResponse<NavMenu>> getById(
    int id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveNavMenuRequest(id: id, context: context),
    );
  }
}

final class MenuItemsExtensions
    implements IInterfaceExtensions<NavMenuItem, int> {
  MenuItemsExtensions(this._iface);
  final MenuItemsInterface _iface;

  @override
  Future<WordpressResponse<NavMenuItem>> getById(
    int id, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveNavMenuItemRequest(id: id, context: context),
    );
  }
}

final class MenuLocationsExtensions
    implements IInterfaceExtensions<MenuLocation, String> {
  MenuLocationsExtensions(this._iface);
  final MenuLocationsInterface _iface;

  @override
  Future<WordpressResponse<MenuLocation>> getById(
    String location, {
    RequestContext? context,
  }) {
    return _iface.retrieve(
      RetrieveMenuLocationRequest(location: location, context: context),
    );
  }
}

extension MenusInterfaceExtensions on MenusInterface {
  MenusExtensions get extensions => MenusExtensions(this);
}

extension MenuItemsInterfaceExtensions on MenuItemsInterface {
  MenuItemsExtensions get extensions => MenuItemsExtensions(this);
}

extension MenuLocationsInterfaceExtensions on MenuLocationsInterface {
  MenuLocationsExtensions get extensions => MenuLocationsExtensions(this);
}
