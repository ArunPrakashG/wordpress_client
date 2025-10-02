import 'dart:async';
import 'package:dio/dio.dart';

import 'package:wordpress_client/wordpress_client.dart';

/// Example: Poll a single resource as a Stream and integrate with Riverpod's StreamProvider
/// Note: Avoid using this pattern for list endpoints due to pagination; prefer a specific resource.
Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  // Sample: poll a single Post by id every minute
  final postId = 1;
  final token = CancelToken();

  final refetchController = StreamController<void>.broadcast();

  final stream = client.posts
      .retrieveStream(
        RetrievePostRequest(id: postId, context: RequestContext.view),
        interval: const Duration(seconds: 30),
        emitOnStart: true,
        distinctData: true,
        cancelToken: token,
        refetchTrigger: refetchController.stream,
      )
      .map(
        (r) => r.map(
          onSuccess: (s) => 'Post ${s.data.id} updated at ${DateTime.now()}',
          onFailure: (f) => 'Failed: code=${f.code} msg=${f.message}',
        ),
      );

  final sub = stream.listen(print);

  // run for demonstration then cancel
  // Signal an on-demand refetch (one-off)
  refetchController.add(null);

  await Future<void>.delayed(const Duration(minutes: 2));
  await sub.cancel();
  token.cancel('Stopped example');
  await refetchController.close();
  client.dispose();
}
