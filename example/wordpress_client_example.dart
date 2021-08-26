import 'package:wordpress_client/src/authorization/authorization_methods/useful_jwt.dart';
import 'package:wordpress_client/wordpress_client.dart';

void main() async {
  WordpressClient client;

  // Simple Usage
  client = new WordpressClient('https://www.example.com/wp-json', 'wp/v2');
  ResponseContainer<List<Post?>?> posts = await client.listPost((builder) => builder.withPerPage(20).withPageNumber(1).build());
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
        .withDefaultAuthorization(UsefulJwtAuth('test_user', 'super_secret_password'))
        .withStatisticDelegate(
      (baseUrl, endpoint, count) {
        print('Request send to: $baseUrl ($count times)');
      },
    ).build(),
  );

  ResponseContainer<List<Post?>?> response = await client.listPost(
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

  client.initializeCustomInterface<TestResponse>('test_interface');
  print(response.value!.first!.id);
}

class TestResponse extends ISerializable<TestResponse> {
  @override
  TestResponse fromJson(Map<String, dynamic>? json) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}
