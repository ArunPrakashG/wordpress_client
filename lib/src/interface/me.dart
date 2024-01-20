import '../../wordpress_client.dart';

/// Represents the current user interface.
final class MeInterface extends IRequestInterface
    with
        DeleteOperation<DeleteMeRequest>,
        RetrieveOperation<User, RetrieveMeRequest>,
        UpdateOperation<User, UpdateMeRequest> {}
