import '../builders_import.dart';
import '../operations/create.dart';
import '../operations/delete.dart';
import '../operations/list.dart';
import '../operations/retrive.dart';
import '../operations/update.dart';
import '../responses/media_response.dart';
import '../responses/response_container.dart';
import '../wordpress_client_base.dart';

class MediaInterface extends IInterface
    implements
        ICreateOperation<Media, MediaCreateBuilder>,
        IDeleteOperation<Media, MediaDeleteBuilder>,
        IRetriveOperation<Media, MediaRetriveBuilder>,
        IUpdateOperation<Media, MediaUpdateBuilder>,
        IListOperation<Media, MediaListBuilder> {
  @override
  Future<ResponseContainer<Media?>> create(Request<Media>? Function(MediaCreateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).createRequest<Media>(
      Media(),
      builder(
        MediaCreateBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> delete(Request<Media>? Function(MediaDeleteBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).deleteRequest<Media>(
      Media(),
      builder(
        MediaDeleteBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Media?>?>> list(Request<List<Media>>? Function(MediaListBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).listRequest<Media>(
      Media(),
      builder(
        MediaListBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> retrive(Request<Media>? Function(MediaRetriveBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).retriveRequest<Media>(
      Media(),
      builder(
        MediaRetriveBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> update(Request<Media>? Function(MediaUpdateBuilder) builder, {bool shouldWaitWhileClientBusy = false}) async {
    return (await getInternalRequester(shouldWaitIfBusy: shouldWaitWhileClientBusy)).updateRequest<Media>(
      Media(),
      builder(
        MediaUpdateBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }
}
