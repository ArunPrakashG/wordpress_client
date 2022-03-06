import 'dart:async';

import '../../wordpress_client.dart';
import '../requests/create/create_media.dart';
import '../requests/delete/delete_media.dart';
import '../requests/list/list_media.dart';
import '../requests/retrive/retrive_media.dart';
import '../requests/update/update_media.dart';
import '../wordpress_client_base.dart';

class MediaInterface extends IInterface
    with
        ICreate<Media, CreateMediaRequest>,
        IDelete<Media, DeleteMediaRequest>,
        IRetrive<Media, RetriveMediaRequest>,
        IUpdate<Media, UpdateMediaRequest>,
        IList<Media, ListMediaRequest> {
  @override
  Future<WordpressResponse<Media?>> create(
    GenericRequest<CreateMediaRequest> request,
  ) async {
    return internalRequester.createRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> delete(
    GenericRequest<DeleteMediaRequest> request,
  ) async {
    return internalRequester.deleteRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<List<Media>?>> list(
    GenericRequest<ListMediaRequest> request,
  ) async {
    return internalRequester.listRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> retrive(
    GenericRequest<RetriveMediaRequest> request,
  ) async {
    return internalRequester.retriveRequest<Media>(request);
  }

  @override
  Future<WordpressResponse<Media?>> update(
    GenericRequest<UpdateMediaRequest> request,
  ) async {
    return internalRequester.updateRequest<Media>(request);
  }
}
