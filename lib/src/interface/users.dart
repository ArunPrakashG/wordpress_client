import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/response_container.dart';
import '../responses/user_response.dart';
import '../wordpress_client_base.dart';

class UsersInterface extends IInterface
    implements
        ICreateOperation<User, UserCreateBuilder>,
        IDeleteOperation<User, UserDeleteBuilder>,
        IRetriveOperation<User, UserRetriveBuilder>,
        IUpdateOperation<User, UserUpdateBuilder>,
        IListOperation<User, UserListBuilder> {
  @override
  Future<ResponseContainer<User?>> create(Request<User>? Function(UserCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<User>(
      User(),
      builder(
        UserCreateBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> delete(Request<User>? Function(UserDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<User>(
      User(),
      builder(
        UserDeleteBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<User?>?>> list(Request<List<User>>? Function(UserListBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<User>(
      User(),
      builder(
        UserListBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> retrive(Request<User>? Function(UserRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<User>(
      User(),
      builder(
        UserRetriveBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> update(Request<User>? Function(UserUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<User>(
      User(),
      builder(
        UserUpdateBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }
}
