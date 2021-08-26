part of '../wordpress_client_base.dart';

class MeInterface implements IDeleteOperation<User, MeDeleteBuilder>, IRetriveOperation<User, MeRetriveBuilder>, IUpdateOperation<User, MeUpdateBuilder> {
  @override
  Future<ResponseContainer<User?>> delete({required Request<User>? Function(MeDeleteBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<User>(
      User(),
      builder(
        MeDeleteBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> retrive({required Request<User>? Function(MeRetriveBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<User>(
      User(),
      builder(
        MeRetriveBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<User?>> update({required Request<User>? Function(MeUpdateBuilder) builder, bool shouldWaitWhileClientBusy = false}) async {
    return (await _getInternalRequesterClient(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<User>(
      User(),
      builder(
        MeUpdateBuilder().withEndpoint('users').initializeWithDefaultValues(),
      ),
    );
  }
}
