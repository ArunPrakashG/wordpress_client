// ignore_for_file: avoid_print

import 'package:wordpress_client/src/utilities/extensions/response_extensions.dart';
import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final baseUrl = Uri.parse('https://pathanamthittamedia.com/wp-json/wp/v2');

  // Simple Usage
  final client = WordpressClient(
    baseUrl: baseUrl,
    bootstrapper: (bootstrapper) => bootstrapper.withDebugMode(false).build(),
  );

  client.initialize();

  final postsResponse = await client.media.list(
    ListMediaRequest(
      events: WordpressEvents(
        onError: (error) {
          print(error.toString());
        },
      ),
    ),
  );

  postsResponse.map<void>(
    onSuccess: (response) {
      print(response.message);
    },
    onFailure: (response) {
      print(response.error.toString());
    },
  );
}
