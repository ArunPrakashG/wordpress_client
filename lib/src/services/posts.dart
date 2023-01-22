import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class PostsService extends IWordpressService
    with
        CreateMixin<Post, CreatePostRequest>,
        DeleteMixin<DeletePostRequest>,
        RetrieveMixin<Post, RetrivePostRequest>,
        UpdateMixin<Post, UpdatePostRequest>,
        ListMixin<Post, ListPostRequest> {}
