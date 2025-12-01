import '../../wordpress_client.dart';

/// Users (wp/v2/users)
///
/// CRUD operations for WordPress users via the REST API.
///
/// Reference: https://developer.wordpress.org/rest-api/reference/users/
///
/// Example:
///
/// ```dart
/// final wp = WordpressClient(baseUrl: 'https://example.com/wp-json');
/// final me = await wp.users.retrieve(RetrieveUserRequest(id: 1));
/// final created = await wp.users.create(CreateUserRequest(
///   username: 'newuser',
///   email: 'newuser@example.com',
///   password: 'strong-password',
///   rolesList: ['author'], // optional
/// ));
///
/// final listed = await wp.users.list(ListUserRequest(
///   rolesList: ['author','editor'],
///   orderBy: OrderBy.name,
/// ));
///
/// await wp.users.update(UpdateUserRequest(id: created.id, firstName: 'Jane'));
/// await wp.users.delete(DeleteUserRequest(id: created.id, reassign: 1, force: true));
/// ```
final class UsersInterface extends IRequestInterface
    with
        CreateOperation<User, CreateUserRequest>,
        DeleteOperation<DeleteUserRequest>,
        RetrieveOperation<User, RetrieveUserRequest>,
        UpdateOperation<User, UpdateUserRequest>,
        ListOperation<User, ListUserRequest> {}
