import '../../wordpress_client.dart';

/// Represents the application password interface for WordPress.
///
/// This interface provides methods to manage application passwords, including:
/// - Creating new application passwords
/// - Deleting existing application passwords
/// - Listing all application passwords
/// - Retrieving specific application passwords
/// - Updating existing application passwords
///
/// Example usage:
/// ```dart
/// final wpClient = WordpressClient(baseUrl: 'https://your-wordpress-site.com');
/// final appPasswords = wpClient.applicationPasswords;
///
/// // Create a new application password
/// final newPassword = await appPasswords.create(CreateApplicationPasswordRequest(
///   name: 'My App Password',
///   user: 1, // User ID
/// ));
///
/// // List all application passwords
/// final passwords = await appPasswords.list(ListApplicationPasswordRequest());
///
/// // Retrieve a specific application password
/// final password = await appPasswords.retrieve(RetriveApplicationPasswordRequest(
///   id: newPassword.id,
///   user: 1, // User ID
/// ));
///
/// // Update an application password
/// final updatedPassword = await appPasswords.update(UpdateApplicationPasswordRequest(
///   id: newPassword.id,
///   user: 1, // User ID
///   name: 'Updated App Password',
/// ));
///
/// // Delete an application password
/// await appPasswords.delete(DeleteApplicationPasswordRequest(
///   id: newPassword.id,
///   user: 1, // User ID
/// ));
/// ```
final class ApplicationPasswordsInterface extends IRequestInterface
    with
        CreateOperation<ApplicationPassword, CreateApplicationPasswordRequest>,
        DeleteOperation<DeleteApplicationPasswordRequest>,
        ListOperation<ApplicationPassword, ListApplicationPasswordRequest>,
        RetrieveOperation<ApplicationPassword,
            RetriveApplicationPasswordRequest>,
        UpdateOperation<ApplicationPassword,
            UpdateApplicationPasswordRequest> {}
