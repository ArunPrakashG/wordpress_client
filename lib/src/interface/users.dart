import '../../wordpress_client.dart';

/// Represents the user interface.
final class UsersInterface extends IRequestInterface
    with
        CreateOperation<User, CreateUserRequest>,
        DeleteOperation<DeleteUserRequest>,
        RetriveOperation<User, RetriveUserRequest>,
        UpdateOperation<User, UpdateUserRequest>,
        ListOperation<User, ListUserRequest> {}
