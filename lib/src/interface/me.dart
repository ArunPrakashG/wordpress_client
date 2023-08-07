import '../../wordpress_client.dart';

/// Represents the current user interface.
final class MeInterface extends IRequestInterface
    with
        DeleteOperation<DeleteMeRequest>,
        RetriveOperation<User, RetriveMeRequest>,
        UpdateOperation<User, UpdateMeRequest> {}
