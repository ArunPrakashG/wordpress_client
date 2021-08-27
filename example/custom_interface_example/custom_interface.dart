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
        IRetriveOperation<MyResponse, MyResponseRetriveBuilder>,
        IUpdateOperation<MyResponse, MyResponseUpdateBuilder>,
        IListOperation<MyResponse, MyResponseListBuilder> {
  @override
  Future<ResponseContainer<MyResponse?>> create(Request<MyResponse>? Function(MyResponseCreateBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<MyResponse>(
      MyResponse(),
      builder(
        // this way, you can assign default values before the user uses this builder from their code.
        // Here, request will be initialized with default values (if any) and
        // my_endpoint as the request endpoint before user starts to build the request in their code
        MyResponseCreateBuilder().withEndpoint('my_endpoint').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> delete(Request<MyResponse>? Function(MyResponseDeleteBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<MyResponse>(
      MyResponse(),
      builder(
        // this way, you can assign default values before the user uses this builder from their code.
        // Here, request will be initialized with default values (if any) and
        // my_endpoint as the request endpoint before user starts to build the request in their code
        MyResponseDeleteBuilder().withEndpoint('my_endpoint').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<MyResponse?>?>> list(Request<List<MyResponse>>? Function(MyResponseListBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<MyResponse>(
      MyResponse(),
      builder(
        // this way, you can assign default values before the user uses this builder from their code.
        // Here, request will be initialized with default values (if any) and
        // my_endpoint as the request endpoint before user starts to build the request in their code
        MyResponseListBuilder().withEndpoint('my_endpoint').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> retrive(Request<MyResponse>? Function(MyResponseRetriveBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<MyResponse>(
      MyResponse(),
      builder(
        // this way, you can assign default values before the user uses this builder from their code.
        // Here, request will be initialized with default values (if any) and
        // my_endpoint as the request endpoint before user starts to build the request in their code
        MyResponseRetriveBuilder().withEndpoint('my_endpoint').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<MyResponse?>> update(Request<MyResponse>? Function(MyResponseUpdateBuilder p1) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<MyResponse>(
      MyResponse(),
      builder(
        // this way, you can assign default values before the user uses this builder from their code.
        // Here, request will be initialized with default values (if any) and
        // my_endpoint as the request endpoint before user starts to build the request in their code
        MyResponseUpdateBuilder().withEndpoint('my_endpoint').initializeWithDefaultValues(),
      ),
    );
  }
}
