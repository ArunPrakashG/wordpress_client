import '../../wordpress_client.dart';

/// Interface for Widgets (/wp/v2/widgets)
final class WidgetsInterface extends IRequestInterface
    with
        ListOperation<Widget, ListWidgetsRequest>,
        RetrieveOperation<Widget, RetrieveWidgetRequest>,
        CreateOperation<Widget, CreateWidgetRequest>,
        UpdateOperation<Widget, UpdateWidgetRequest>,
        DeleteOperation<DeleteWidgetRequest> {}

/// Interface for Sidebars (/wp/v2/sidebars)
final class SidebarsInterface extends IRequestInterface
    with
        ListOperation<Sidebar, ListSidebarsRequest>,
        RetrieveOperation<Sidebar, RetrieveSidebarRequest>,
        UpdateOperation<Sidebar, UpdateSidebarRequest> {}

/// Interface for Widget Types (/wp/v2/widget-types)
final class WidgetTypesInterface extends IRequestInterface
    with
        ListOperation<WidgetType, ListWidgetTypesRequest>,
        RetrieveOperation<WidgetType, RetrieveWidgetTypeRequest> {}
