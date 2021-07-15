import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/utilities/callback.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client = WordpressClient('https://www.pathanamthittamedia.com/wp-json', 'wp/v2');
  
  /*
  final postsContainer = await client.fetchPosts(
    (builder) => builder.initializeWithDefaultValues().orderResultsBy(FilterOrder.DESCENDING).withPerPage(20).withPageNumber(1).buildWithCallback(
          Callback(
            unhandledExceptionCallback: (e) {
              print(e.toString());
            },
            responseCallback: (response) {
              print('Response Received');
            },
          ),
        ),
  );

  print('Request completed in ${postsContainer.duration.inSeconds} seconds');
  print('Status Code: ${postsContainer.responseCode}');
  print('Total Posts: ${postsContainer.value.length}');

  for (final post in postsContainer.value) {
    print(post.title.parsedText);
    print(post.content.parsedText);
    break;
  }*/
}
