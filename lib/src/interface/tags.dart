import '../../wordpress_client.dart';
import '../builders_import.dart';

class TagInterface extends IInterface
    implements
        ICreateOperation<Tag, TagCreateBuilder>,
        IDeleteOperation<Tag, TagDeleteBuilder>,
        IRetrieveOperation<Tag, TagRetriveBuilder>,
        IUpdateOperation<Tag, TagUpdateBuilder>,
        IListOperation<Tag, TagListBuilder> {
  @override
  Future<ResponseContainer<Tag?>> create(
      Request<Tag>? Function(TagCreateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .createRequest<Tag>(
      Tag(),
      builder(
        TagCreateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> delete(
      Request<Tag>? Function(TagDeleteBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .deleteRequest<Tag>(
      Tag(),
      builder(
        TagDeleteBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Tag>?>> list(
      Request<List<Tag>>? Function(TagListBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .listRequest<Tag>(
      Tag(),
      builder(
        TagListBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> retrive(
      Request<Tag>? Function(TagRetriveBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .retriveRequest<Tag>(
      Tag(),
      builder(
        TagRetriveBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Tag?>> update(
      Request<Tag>? Function(TagUpdateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .updateRequest<Tag>(
      Tag(),
      builder(
        TagUpdateBuilder().withEndpoint('tags').initializeWithDefaultValues(),
      ),
    );
  }
}
