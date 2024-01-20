import '../../wordpress_client.dart';

/// Represents the application password interface.
final class ApplicationPasswordsInterface extends IRequestInterface
    with
        CreateOperation<ApplicationPassword, CreateApplicationPasswordRequest>,
        DeleteOperation<DeleteApplicationPasswordRequest>,
        ListOperation<ApplicationPassword, ListApplicationPasswordRequest>,
        RetrieveOperation<ApplicationPassword,
            RetriveApplicationPasswordRequest>,
        UpdateOperation<ApplicationPassword,
            UpdateApplicationPasswordRequest> {}
