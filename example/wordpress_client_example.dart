import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client;

  // Simple Usage
  client = new WordpressClient('https://www.example.com/wp-json', 'wp/v2');
  ResponseContainer<List<Post>> posts = await client.listPost((builder) => builder.withPerPage(20).withPageNumber(1).build());
  print(posts.value.first.id);

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
          // You can use this to pass a custom authorization header on all requests
          (builder) => builder.withUserName('test_user').withPassword('super_secret_password').withType(AuthorizationType.JWT).build(),
        )
        .withStatisticDelegate(
      (baseUrl, endpoint, count) {
        print('Request send to: $baseUrl ($count times)');
      },
    ).build(),
  );

  ResponseContainer<List<Post>> response = await client.listPost(
    (builder) => builder
        .withPerPage(20)
        .withPageNumber(1)
        .orderResultsBy(FilterOrder.DESCENDING)
        .sortResultsBy(FilterPostSortOrder.DATE)
        .withAuthorization( // You can also use this to pass a custom authorization header on this particular request
          Authorization(
            userName: 'test_user',
            password: 'super_secret_password',
            authType: AuthorizationType.JWT,
          ),
        )
        .withCallback(
          Callback(
            unhandledExceptionCallback: (ex) {
              print('Unhandled Exception: $ex');
            },
            requestErrorCallback: (errorContainer) {
              print('Request Error: ${errorContainer.errorResponse.message}');
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
      if (rawResponse.any((element) => element.content.parsedText == null)) {
        return false;
      }

      return true;
    }).build(),
  );

  print(response.value.first.id);
}
