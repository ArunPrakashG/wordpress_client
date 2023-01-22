import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class UsersService extends IWordpressService
    with
        CreateMixin<User, CreateUserRequest>,
        DeleteMixin<DeleteUserRequest>,
        RetrieveMixin<User, RetriveUserRequest>,
        UpdateMixin<User, UpdateUserRequest>,
        ListMixin<User, ListUserRequest> {}
