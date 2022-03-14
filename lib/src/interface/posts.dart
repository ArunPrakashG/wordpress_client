import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class PostsInterface extends IInterface
    with
        CreateMixin<Post, CreatePostRequest>,
        DeleteMixin<Post, DeletePostRequest>,
        RetriveMixin<Post, RetrivePostRequest>,
        UpdateMixin<Post, UpdatePostRequest>,
        ListMixin<Post, ListPostRequest> {}
