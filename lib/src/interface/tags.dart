import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class TagInterface extends IInterface
    with
        CreateMixin<Tag, CreateTagRequest>,
        DeleteMixin<DeleteTagRequest>,
        RetrieveMixin<Tag, RetriveTagRequest>,
        UpdateMixin<Tag, UpdateTagRequest>,
        ListMixin<Tag, ListTagRequest> {}
