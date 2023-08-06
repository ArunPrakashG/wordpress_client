import '../../wordpress_client.dart';

final class TagInterface extends IRequestInterface
    with
        CreateOperation<Tag, CreateTagRequest>,
        DeleteOperation<DeleteTagRequest>,
        RetriveOperation<Tag, RetriveTagRequest>,
        UpdateOperation<Tag, UpdateTagRequest>,
        ListOperation<Tag, ListTagRequest> {}
