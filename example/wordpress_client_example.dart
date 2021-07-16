import 'package:wordpress_client/src/enums.dart';
import 'package:wordpress_client/src/responses/post_response.dart';
import 'package:wordpress_client/src/utilities/callback.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client = WordpressClient(
    'https://www.pathanamthittamedia.com/wp-json',
    'wp/v2',
    bootstrapper: (builder) => builder.withDefaultMaxRedirects(5).withFollowRedirects(true).withRequestTimeout(60).build(),
  );
  var listPostsResponse = await client.listPosts(
    (builder) => builder
        .withPerPage(10)
        .orderResultsBy(FilterOrder.DESCENDING)
        .withResponseValidationOverride((List<Post> response) {
          print('Response received in validator. (${response.length} posts)');
          return true;
        })
        .withCallback(
          Callback(
            unhandledExceptionCallback: (e) {
              print('Unhandled exception: ${e.toString()}');
            },
            responseCallback: (responseRaw) {
              print('Response received in Callback');
            },
          ),
        )
        .build(),
  );

  if (listPostsResponse == null || listPostsResponse.responseCode != 200) {
    print('Error: ' + listPostsResponse.responseCode.toString());
  }

  print('Request completed in ${listPostsResponse.duration.inSeconds} second(s)');
  print('Status Code: ${listPostsResponse.responseCode}');
  print('Total posts count: ${listPostsResponse.totalPostsCount}');
  print('Total pages count: ${listPostsResponse.totalPagesCount}');

  for (var post in listPostsResponse.value) {
    print('ID: ' + post.id.toString());
    print('Title: ' + post.title.parsedText.substring(0, 40) + '...');
    print('Content: ' + post.content.parsedText.substring(0, 40) + '...');
  }

  print('-------------------------------------------------------');

  var retrivePostResponse = await client.retrivePost(
    (builder) => builder
        .withPostId(466206)
        .withResponseValidationOverride((Post response) {
          print('Response received in validator. (${response.id})');
          return true;
        })
        .withCallback(
          Callback(
            unhandledExceptionCallback: (e) {
              print('Unhandled exception: ${e.toString()}');
            },
            responseCallback: (responseRaw) {
              print('Response received in Callback');
            },
          ),
        )
        .build(),
  );

  print('Request completed in ${retrivePostResponse.duration.inSeconds} second(s)');
  print('Status Code: ${retrivePostResponse.responseCode}');

  print('ID: ' + retrivePostResponse.value.id.toString());
  print('Title: ' + retrivePostResponse.value.title.parsedText.substring(0, 40) + '...');
  print('Content: ' + retrivePostResponse.value.content.parsedText.substring(0, 40) + '...');

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
