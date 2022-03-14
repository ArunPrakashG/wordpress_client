import 'dart:async';

import '../../operations.dart';
import '../../requests.dart';
import '../../responses.dart';
import '../../wordpress_client.dart';

class MediaInterface extends IInterface
    with
        ICreate<Media, CreateMediaRequest>,
        IDelete<Media, DeleteMediaRequest>,
        IRetrive<Media, RetriveMediaRequest>,
        IUpdate<Media, UpdateMediaRequest>,
        IList<Media, ListMediaRequest> {
  @override
  Future<WordpressResponse<Media?>> create(
    WordpressRequest<CreateMediaRequest> request,
  ) async {
    return internalRequester.createRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> delete(
    WordpressRequest<DeleteMediaRequest> request,
  ) async {
    return internalRequester.deleteRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<List<Media>?>> list(
    WordpressRequest<ListMediaRequest> request,
  ) async {
    return internalRequester.listRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> retrive(
    WordpressRequest<RetriveMediaRequest> request,
  ) async {
    return internalRequester.retriveRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> update(
    WordpressRequest<UpdateMediaRequest> request,
  ) async {
    return internalRequester.updateRequest<Media>(request);
  }
}
