import '../../wordpress_client.dart';

/// Interface for Classic Nav Menus (/wp/v2/menus)
final class MenusInterface extends IRequestInterface
    with
        ListOperation<NavMenu, ListNavMenuRequest>,
        RetrieveOperation<NavMenu, RetrieveNavMenuRequest>,
        CreateOperation<NavMenu, CreateNavMenuRequest>,
        UpdateOperation<NavMenu, UpdateNavMenuRequest>,
        DeleteOperation<DeleteNavMenuRequest> {}

/// Interface for Classic Nav Menu Items (/wp/v2/menu-items)
final class MenuItemsInterface extends IRequestInterface
    with
        ListOperation<NavMenuItem, ListNavMenuItemRequest>,
        RetrieveOperation<NavMenuItem, RetrieveNavMenuItemRequest>,
        CreateOperation<NavMenuItem, CreateNavMenuItemRequest>,
        UpdateOperation<NavMenuItem, UpdateNavMenuItemRequest>,
        DeleteOperation<DeleteNavMenuItemRequest> {}

/// Interface for Classic Menu Locations (/wp/v2/menu-locations)
final class MenuLocationsInterface extends IRequestInterface
    with
        ListOperation<MenuLocation, ListMenuLocationRequest>,
        RetrieveOperation<MenuLocation, RetrieveMenuLocationRequest> {}
