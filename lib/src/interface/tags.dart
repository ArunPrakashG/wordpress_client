import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/response_container.dart';
import '../responses/tag_response.dart';
import '../wordpress_client_base.dart';

class TagInterface extends IInterface
    implements
        ICreateOperation<Tag, TagCreateBuilder>,
        IDeleteOperation<Tag, TagDeleteBuilder>,
        IRetriveOperation<Tag, TagRetriveBuilder>,
        IUpdateOperation<Tag, TagUpdateBuilder>,
        IListOperation<Tag, TagListBuilder> {
  @override
  Future<ResponseContainer<Tag?>> create(Request<Tag>? Function(TagCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Tag>(
      Tag(),
      builder(
        TagCreateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> delete(Request<Tag>? Function(TagDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Tag>(
      Tag(),
      builder(
        TagDeleteBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Tag?>?>> list(Request<List<Tag>>? Function(TagListBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Tag>(
      Tag(),
      builder(
        TagListBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> retrive(Request<Tag>? Function(TagRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Tag>(
      Tag(),
      builder(
        TagRetriveBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> update(Request<Tag>? Function(TagUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Tag>(
      Tag(),
      builder(
        TagUpdateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }
}
