import '../builders_import.dart';
import '../operations/delete.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/response_container.dart';
import '../responses/user_response.dart';
import '../wordpress_client_base.dart';

class MeInterface extends IInterface
    implements IDeleteOperation<User, MeDeleteBuilder>, IRetriveOperation<User, MeRetriveBuilder>, IUpdateOperation<User, MeUpdateBuilder> {
  @override
  Future<ResponseContainer<User?>> delete(Request<User>? Function(MeDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<User>(
      User(),
      builder(
        MeDeleteBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> retrive(Request<User>? Function(MeRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<User>(
      User(),
      builder(
        MeRetriveBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> update(Request<User>? Function(MeUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<User>(
      User(),
      builder(
        MeUpdateBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }
}
