// ignore_for_file: avoid_print

import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final client = WordpressClient.forSite(
    siteUrl: Uri.parse('https://wordpress.org/news'),
  );

  final response = await client.posts.list(ListPostRequest(perPage: 5));

  switch (response) {
    case WordpressSuccessResponse(:final data):
      for (final post in data) {
        print('${post.id}: ${post.title?.rendered}');
      }
    case WordpressFailureResponse():
      print('Failed: ${response.error?.message ?? response.message}');
  }

  client.dispose();
}
