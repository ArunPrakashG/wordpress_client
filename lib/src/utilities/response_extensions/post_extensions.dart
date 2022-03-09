import '../../../wordpress_client.dart';

extension PostExtensions on Post {
  Future<Media?> getMedia(
    WordpressClient client, {
    Callback? callback,
    CancelToken? cancelToken,
  }) async {
    if (featuredMedia == null || !client.isReady) {
      return null;
    }

    final response = await client.media.retrive(
      WordpressRequest(
        requestData: RetriveMediaRequest(
          id: featuredMedia!,
        ),
        callback: callback,
        cancelToken: cancelToken,
      ),
    );

    return response.data;
  }

  Future<User?> getAuthor(
    WordpressClient client, {
    Callback? callback,
    CancelToken? cancelToken,
  }) async {
    if (author == null || !client.isReady) {
      return null;
    }

    final response = await client.users.retrive(
      WordpressRequest(
        requestData: RetriveUserRequest(
          id: author!,
        ),
        callback: callback,
        cancelToken: cancelToken,
      ),
    );

    return response.data;
  }
}
