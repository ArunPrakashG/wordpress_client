// ignore_for_file: avoid_redundant_argument_values, omit_local_variable_types, avoid_print

import 'package:wordpress_client/requests.dart';
import 'package:wordpress_client/responses.dart';
import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  WordpressClient client;

  // Simple Usage
  client = WordpressClient.initialize(
    'https://www.pathanamthittamedia.com/',
    'wp-json/wp/v2',
    bootstrapper: (bootstrapper) => bootstrapper
        .withStatisticDelegate((baseUrl, endpoint, requestCount) {
          print('$baseUrl $endpoint $requestCount');
        })
        .withDioInterceptor(
          LogInterceptor(
            error: true,
            requestBody: true,
            responseBody: true,
          ),
        )
        .build(),
  );

  await Future<void>.delayed(const Duration(seconds: 2));
  WordpressResponse<List<Post>?> postsResponse = await client.posts.list(
    WordpressRequest(
      requestData: ListPostRequest(
        perPage: 10,
        page: 1,
        order: Order.asc,
      ),
    ),
  );

  if (postsResponse.isSuccess) {
    for (final post in postsResponse.data!) {
      print(post.title?.parsedText);
    }
  } else {
    print(postsResponse.message);
  }

  // Or

  // Advanced Usage
  // client = WordpressClient(
  //   'https://www.example.com/wp-json',
  //   'wp/v2',
  //   bootstrapper: (bootstrapper) => bootstrapper
  //       .withCookies(true)
  //       .withDefaultUserAgent('wordpress_client/6.1.0')
  //       .withDefaultMaxRedirects(5)
  //       .withFollowRedirects(true)
  //       .withDefaultAuthorization(
  //           UsefulJwtAuth('test_user', 'super_secret_password'))
  //       .withStatisticDelegate(
  //     (baseUrl, endpoint, count) {
  //       print('Request send to: $baseUrl ($count times)');
  //     },
  //   ).build(),
  // );

  // postsResponse = await client.posts.list(
  //   WordpressRequest(
  //     requestData: ListPostRequest(
  //       perPage: 10,
  //       page: 1,
  //       order: Order.desc,
  //     ),
  //     responseValidationCallback: (dynamic response) {
  //       if (response is! List<Post>) {
  //         return false;
  //       }

  //       return true;
  //     },
  //     authorization: UsefulJwtAuth(
  //       'test_user',
  //       'super_secret_password',
  //     ),
  //     callback: Callback(
  //       unhandledExceptionCallback: (dynamic ex) {
  //         print('Unhandled Exception: $ex');
  //       },
  //       requestErrorCallback: (errorContainer) {
  //         print('Request Error: ${errorContainer.errorResponse!.message}');
  //       },
  //       onSendProgress: (current, total) {
  //         print('Send Progress: $current/$total');
  //       },
  //       onReceiveProgress: (current, total) {
  //         print('Receive Progress: $current/$total');
  //       },
  //     ),
  //   ),
  // );

  // if (postsResponse.isSuccess) {
  //   for (final post in postsResponse.data!) {
  //     print(post.title?.parsedText);
  //   }

  //   // You access total pages & total count headers directly
  //   print('Per Page: ${postsResponse.totalPagesCount}');
  //   print('Total Count: ${postsResponse.totalCount}');

  //   // You can also access the headers directly
  //   print('X-WP-Total: ${postsResponse.responseHeaders['X-WP-Total']}');

  //   // You can also check how much time the request took easily.
  //   print('Request took: ${postsResponse.requestDuration?.inMilliseconds} ms');
  // } else {
  //   print(postsResponse.message);
  // }
}
