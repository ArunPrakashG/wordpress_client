import '../../wordpress_client.dart';

/// Represents the current user interface for interacting with the WordPress API.
///
/// This class provides operations to manage the current user's account, including:
/// - Retrieving user information
/// - Updating user details
/// - Deleting the user account
///
/// Usage examples:
///
/// Retrieve current user information:
/// ```dart
/// final user = await interface.retrieve(RetrieveMeRequest());
/// print(user.username);
/// ```
///
/// Update user information:
/// ```dart
/// final updatedUser = await interface.update(UpdateMeRequest(
///   firstName: 'John',
///   lastName: 'Doe',
/// ));
/// print('Updated name: ${updatedUser.firstName} ${updatedUser.lastName}');
/// ```
///
/// Delete user account:
/// ```dart
/// await interface.delete(DeleteMeRequest());
/// print('User account deleted');
/// ```
final class MeInterface extends IRequestInterface
    with
        DeleteOperation<DeleteMeRequest>,
        RetrieveOperation<User, RetrieveMeRequest>,
        UpdateOperation<User, UpdateMeRequest> {}
