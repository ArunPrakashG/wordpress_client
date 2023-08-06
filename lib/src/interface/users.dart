import '../../wordpress_client.dart';

final class UsersInterface extends IRequestInterface
    with
        CreateOperation<User, CreateUserRequest>,
        DeleteOperation<DeleteUserRequest>,
        RetriveOperation<User, RetriveUserRequest>,
        UpdateOperation<User, UpdateUserRequest>,
        ListOperation<User, ListUserRequest> {}
