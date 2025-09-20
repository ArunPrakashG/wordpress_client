import '../../wordpress_client.dart';

/// Interface for Navigations (/wp/v2/navigation)
final class NavigationsInterface extends IRequestInterface
    with
        ListOperation<Navigation, ListNavigationsRequest>,
        RetrieveOperation<Navigation, RetrieveNavigationRequest>,
        CreateOperation<Navigation, CreateNavigationRequest>,
        UpdateOperation<Navigation, UpdateNavigationRequest>,
        DeleteOperation<DeleteNavigationRequest> {}

/// Interface for Navigation Revisions (/wp/v2/navigation/{parent}/revisions)
final class NavigationRevisionsInterface extends IRequestInterface
    with
        ListOperation<Revision, ListNavigationRevisionsRequest>,
        RetrieveOperation<Revision, RetrieveNavigationRevisionRequest>,
        DeleteOperation<DeleteNavigationRevisionRequest> {}

/// Interface for Navigation Autosaves (/wp/v2/navigation/{parent}/autosaves)
final class NavigationAutosavesInterface extends IRequestInterface
    with
        ListOperation<Revision, ListNavigationAutosavesRequest>,
        RetrieveOperation<Revision, RetrieveNavigationAutosaveRequest>,
        CreateOperation<Revision, CreateNavigationAutosaveRequest> {}
