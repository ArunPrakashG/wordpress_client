import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class MeInterface extends IInterface
    with
        DeleteMixin<User, DeleteMeRequest>,
        RetriveMixin<User, RetriveMeRequest>,
        UpdateMixin<User, UpdateMeRequest> {}
