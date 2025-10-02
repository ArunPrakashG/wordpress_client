// This file contains a snippet to illustrate Riverpod integration.
// It is not a runnable app by itself, but demonstrates typical usage.

import 'package:wordpress_client/wordpress_client.dart';

// pretend providers
abstract class Ref {
  T watch<T>(Provider<T> provider);
}

class Provider<T> {}

final wordpressClientProvider = Provider<WordpressClient>();

final postStreamProvider = Provider<Stream<WordpressResponse<Post>>>();

Stream<WordpressResponse<Post>> buildPostStream(Ref ref, int id) {
  final client = ref.watch(wordpressClientProvider);
  return client.posts.retrieveStream(
    RetrievePostRequest(id: id, context: RequestContext.view),
    interval: const Duration(seconds: 30),
  );
}
