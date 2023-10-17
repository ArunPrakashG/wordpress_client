import '../../wordpress_client.dart';
import '../requests/create/create_application_password.dart';
import '../requests/delete/delete_application_password.dart';
import '../requests/list/list_application_password.dart';

/// Represents the application password interface.
final class ApplicationPasswordsInterface extends IRequestInterface
    with
        CreateOperation<ApplicationPassword, CreateApplicationPasswordRequest>,
        DeleteOperation<DeleteApplicationPasswordRequest>,
        ListOperation<ApplicationPassword, ListApplicationPasswordRequest> {}
