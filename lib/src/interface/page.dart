import '../../wordpress_client.dart';

/// Represents the page interface.
final class PagesInterface extends IRequestInterface
    with
        CreateOperation<Page, CreatePageRequest>,
        DeleteOperation<DeletePageRequest>,
        RetriveOperation<Page, RetrivePageRequest>,
        UpdateOperation<Page, UpdatePageRequest>,
        ListOperation<Page, ListPageRequest> {}
