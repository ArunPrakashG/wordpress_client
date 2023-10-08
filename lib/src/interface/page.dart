import '../../wordpress_client.dart';
import '../responses/page_response.dart';

/// Represents the page interface.
final class PageInterface extends IRequestInterface
    with
        CreateOperation<Page, CreatePostRequest>,
        DeleteOperation<DeletePostRequest>,
        RetriveOperation<Page, RetrivePostRequest>,
        UpdateOperation<Page, UpdatePostRequest>,
        ListOperation<Page, ListPostRequest> {}
