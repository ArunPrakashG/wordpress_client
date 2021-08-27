import '../../wordpress_client.dart';
import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/response_container.dart';
import '../responses/tag_response.dart';
import 'interface_base.dart';

class TagInterface extends IInterface
    implements
        ICreateOperation<Tag, TagCreateBuilder>,
        IDeleteOperation<Tag, TagDeleteBuilder>,
        IRetriveOperation<Tag, TagRetriveBuilder>,
        IUpdateOperation<Tag, TagUpdateBuilder>,
        IListOperation<Tag, TagListBuilder> {
  @override
  Future<ResponseContainer<Tag?>> create(Request<Tag>? Function(TagCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).createRequest<Tag>(
      Tag(),
      builder(
        TagCreateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> delete(Request<Tag>? Function(TagDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).deleteRequest<Tag>(
      Tag(),
      builder(
        TagDeleteBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Tag?>?>> list(Request<List<Tag>>? Function(TagListBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).listRequest<Tag>(
      Tag(),
      builder(
        TagListBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> retrive(Request<Tag>? Function(TagRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).retriveRequest<Tag>(
      Tag(),
      builder(
        TagRetriveBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> update(Request<Tag>? Function(TagUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy ? await getInternalRequesterWhenFree() : internalRequester).updateRequest<Tag>(
      Tag(),
      builder(
        TagUpdateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }
}
