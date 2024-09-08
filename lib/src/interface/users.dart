import '../../wordpress_client.dart';

/// Represents the user interface for managing WordPress users.
///
/// This class provides methods for creating, deleting, retrieving, updating,
/// and listing users in a WordPress site.
///
/// Example usage:
///
/// ```dart
/// final wordpress = WordPressClient('https://your-site.com');
/// final usersInterface = wordpress.users;
///
/// // Create a new user
/// final newUser = await usersInterface.create(CreateUserRequest(
///   username: 'newuser',
///   email: 'newuser@example.com',
///   password: 'securepassword',
/// ));
///
/// // Retrieve a user
/// final user = await usersInterface.retrieve(RetrieveUserRequest(id: 1));
///
/// // Update a user
/// final updatedUser = await usersInterface.update(UpdateUserRequest(
///   id: 1,
///   firstName: 'John',
///   lastName: 'Doe',
/// ));
///
/// // Delete a user
/// await usersInterface.delete(DeleteUserRequest(id: 1));
///
/// // List users
/// final users = await usersInterface.list(ListUserRequest(
///   page: 1,
///   perPage: 10,
/// ));
/// ```
final class UsersInterface extends IRequestInterface
    with
        CreateOperation<User, CreateUserRequest>,
        DeleteOperation<DeleteUserRequest>,
        RetrieveOperation<User, RetrieveUserRequest>,
        UpdateOperation<User, UpdateUserRequest>,
        ListOperation<User, ListUserRequest> {}
