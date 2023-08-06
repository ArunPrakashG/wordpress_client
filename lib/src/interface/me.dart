import '../../wordpress_client.dart';

final class MeInterface extends IRequestInterface
    with
        DeleteOperation<DeleteMeRequest>,
        RetriveOperation<User, RetriveMeRequest>,
        UpdateOperation<User, UpdateMeRequest> {}
