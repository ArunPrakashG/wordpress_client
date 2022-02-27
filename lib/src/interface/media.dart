import 'dart:async';

import '../../wordpress_client.dart';
import '../builders_import.dart';

class MediaInterface extends IInterface
    implements
        ICreateOperation<Media, MediaCreateBuilder>,
        IDeleteOperation<Media, MediaDeleteBuilder>,
        IRetrieveOperation<Media, MediaRetriveBuilder>,
        IUpdateOperation<Media, MediaUpdateBuilder>,
        IListOperation<Media, MediaListBuilder> {
  @override
  Future<ResponseContainer<Media?>> create(
      Request<Media>? Function(MediaCreateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .createRequest<Media>(
      Media(),
      builder(
        MediaCreateBuilder()
            .withEndpoint('media')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> delete(
      Request<Media>? Function(MediaDeleteBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .deleteRequest<Media>(
      Media(),
      builder(
        MediaDeleteBuilder()
            .withEndpoint('media')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<List<Media>?>> list(
      Request<List<Media>>? Function(MediaListBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .listRequest<Media>(
      Media(),
      builder(
        MediaListBuilder().withEndpoint('media').initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> retrive(
      Request<Media>? Function(MediaRetriveBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .retriveRequest<Media>(
      Media(),
      builder(
        MediaRetriveBuilder()
            .withEndpoint('media')
            .initializeWithDefaultValues(),
      ),
    );
  }

  @override
  Future<ResponseContainer<Media?>> update(
      Request<Media>? Function(MediaUpdateBuilder) builder,
      {bool shouldWaitWhileClientBusy = false}) async {
    return (shouldWaitWhileClientBusy
            ? await getInternalRequesterWhenFree()
            : internalRequester)
        .updateRequest<Media>(
      Media(),
      builder(
        MediaUpdateBuilder()
            .withEndpoint('media')
            .initializeWithDefaultValues(),
      ),
    );
  }
}
