import 'dart:async';

import 'package:wordpress_client/wordpress_client.dart';
import 'builders/my_response_create_builder.dart';
import 'builders/my_response_delete_builder.dart';
import 'builders/my_response_list_builder.dart';
import 'builders/my_response_retrive_builder.dart';
import 'builders/my_response_update_builder.dart';
import 'respones/my_response.dart';

class MyCustomInterface extends IInterface
    implements
        ICreateOperation<MyResponse, MyResponseCreateBuilder>,
        IDeleteOperation<MyResponse, MyResponseDeleteBuilder>,
        IRetrieveOperation<MyResponse, MyResponseRetriveBuilder>,
        IUpdateOperation<MyResponse, MyResponseUpdateBuilder>,
        IListOperation<MyResponse, MyResponseListBuilder> {
  @override
  Future<ResponseContainer<MyResponse?>> create(
      Request<MyResponse>? Function(MyResponseCreateBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .createRequest<MyResponse>(
      MyResponse(),
      builder(
        MyResponseCreateBuilder()
            .withEndpoint('my_endpoint')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> delete(
      Request<MyResponse>? Function(MyResponseDeleteBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .deleteRequest<MyResponse>(
      MyResponse(),
      builder(
        MyResponseDeleteBuilder()
            .withEndpoint('my_endpoint')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<MyResponse>?>> list(
      Request<List<MyResponse>>? Function(MyResponseListBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .listRequest<MyResponse>(
      MyResponse(),
      builder(
        MyResponseListBuilder()
            .withEndpoint('my_endpoint')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> retrive(
      Request<MyResponse>? Function(MyResponseRetriveBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .retriveRequest<MyResponse>(
      MyResponse(),
      builder(
        MyResponseRetriveBuilder()
            .withEndpoint('my_endpoint')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> update(
      Request<MyResponse>? Function(MyResponseUpdateBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .updateRequest<MyResponse>(
      MyResponse(),
      builder(
        MyResponseUpdateBuilder()
            .withEndpoint('my_endpoint')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  void init(InternalRequester requester, String? interfaceKey) {
    super.init(requester, interfaceKey);
  }
}
