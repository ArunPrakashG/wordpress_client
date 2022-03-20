import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class UsersInterface extends IInterface
    with
        CreateMixin<User, CreateUserRequest>,
        DeleteMixin<DeleteUserRequest>,
        RetrieveMixin<User, RetriveUserRequest>,
        UpdateMixin<User, UpdateUserRequest>,
        ListMixin<User, ListUserRequest> {}
