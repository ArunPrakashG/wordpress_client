import '../../../wordpress_client.dart';

extension PostExtensions on Post {
  Future<Media?> getMedia(
    WordpressClient client, {
    WordpressEvents? callback,
    CancelToken? cancelToken,
  }) async {
    if (featuredMedia == null || !client.isReady) {
      return null;
    }

    final response = await client.media.retrive(
      RetriveMediaRequest(
        id: featuredMedia!,
        events: callback,
        cancelToken: cancelToken,
      ),
    );

    return response.mapOrNull<Media>(
      onSuccess: (response) => response.data,
    );
  }

  Future<User?> getAuthor(
    WordpressClient client, {
    WordpressEvents? callback,
    CancelToken? cancelToken,
  }) async {
    if (!client.isReady) {
      return null;
    }

    final response = await client.users.retrive(
      RetriveUserRequest(
        id: author,
        events: callback,
        cancelToken: cancelToken,
      ),
    );

    return response.mapOrNull<User>(
      onSuccess: (response) => response.data,
    );
  }
}
