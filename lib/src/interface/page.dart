import '../../wordpress_client.dart';
import '../responses/page_response.dart';

/// Represents the page interface.
final class PageInterface extends IRequestInterface
    with
        CreateOperation<Page, CreatePageRequest>,
        DeleteOperation<DeletePageRequest>,
        RetriveOperation<Page, RetrivePageRequest>,
        UpdateOperation<Page, UpdatePageRequest>,
        ListOperation<Page, ListPageRequest> {}
