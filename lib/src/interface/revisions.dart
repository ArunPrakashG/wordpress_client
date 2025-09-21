import '../../wordpress_client.dart';

/// Interface for Post Revisions (/wp/v2/posts/{id}/revisions)
final class PostRevisionsInterface extends IRequestInterface
    with
        ListOperation<Revision, ListPostRevisionsRequest>,
        RetrieveOperation<Revision, RetrievePostRevisionRequest> {}

/// Interface for Page Revisions (/wp/v2/pages/{id}/revisions)
final class PageRevisionsInterface extends IRequestInterface
    with
        ListOperation<Revision, ListPageRevisionsRequest>,
        RetrieveOperation<Revision, RetrievePageRevisionRequest> {}
