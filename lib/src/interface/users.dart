import '../../wordpress_client.dart';

/// Represents the user interface.
final class UsersInterface extends IRequestInterface
    with
        CreateOperation<User, CreateUserRequest>,
        DeleteOperation<DeleteUserRequest>,
        RetrieveOperation<User, RetrieveUserRequest>,
        UpdateOperation<User, UpdateUserRequest>,
        ListOperation<User, ListUserRequest> {}
