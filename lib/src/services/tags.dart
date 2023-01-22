import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class TagService extends IWordpressService
    with
        CreateMixin<Tag, CreateTagRequest>,
        DeleteMixin<DeleteTagRequest>,
        RetrieveMixin<Tag, RetriveTagRequest>,
        UpdateMixin<Tag, UpdateTagRequest>,
        ListMixin<Tag, ListTagRequest> {}
