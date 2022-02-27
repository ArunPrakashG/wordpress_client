import 'package:wordpress_client/wordpress_client.dart';

import 'custom_interface_example/custom_interface.dart';

void main() async {
  WordpressClient client;

  // Simple Usage
  client = new WordpressClient('https://www.example.com/wp-json', 'wp/v2');

  ResponseContainer<List<Post?>?> posts = await client.posts
      .list((builder) => builder.withPerPage(20).withPageNumber(1).build());
  print(posts.value!.first!.id);

  // Or

  // Advanced Usage
  client = new WordpressClient(
    'https://www.example.com/wp-json',
    'wp/v2',
    bootstrapper: (bootstrapper) => bootstrapper
        .withCookies(true)
        .withDefaultUserAgent('wordpress_client/4.0.0')
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withDefaultAuthorization(
            UsefulJwtAuth('test_user', 'super_secret_password'))
        .withStatisticDelegate(
      (baseUrl, endpoint, count) {
        print('Request send to: $baseUrl ($count times)');
      },
    ).build(),
  );

  ResponseContainer<List<Post?>?> response = await client.posts.list(
    (builder) => builder
        .withPerPage(20)
        .withPageNumber(1)
        .orderResultsBy(FilterOrder.DESCENDING)
        .sortResultsBy(FilterPostSortOrder.DATE)
        .withAuthorization(UsefulJwtAuth('test_user', 'super_secret_password'))
        .withCallback(
          Callback(
            unhandledExceptionCallback: (ex) {
              print('Unhandled Exception: $ex');
            },
            requestErrorCallback: (errorContainer) {
              print('Request Error: ${errorContainer.errorResponse!.message}');
            },
            onSendProgress: (current, total) {
              print('Send Progress: $current/$total');
            },
            onReceiveProgress: (current, total) {
              print('Receive Progress: $current/$total');
            },
          ),
        )
        .withResponseValidationOverride((rawResponse) {
      // ignore: unnecessary_null_comparison
      if (rawResponse.any((element) => element.content!.parsedText == null)) {
        return false;
      }

      return true;
    }).build(),
  );

  print(response.value!.first!.id);

  // initialize custom interface
  await client.initInterface<MyCustomInterface>(
      MyCustomInterface(), 'my_custom_interface');

  // to use it...
  await client
      .getCustomInterface<MyCustomInterface>()
      .create((p1) => p1.build());
}
