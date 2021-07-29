# WordpressClient

<b>wordpress_client</b> is a library written purely in Dart to interact with Wordpress REST API in a fluent pattern. This library is a port of <b>WordpressCore</b> library written in C#

## Usage

First of all import the library

```dart
import 'package:wordpress_client/wordpress_client.dart';
```

Initializing the client is simple...

```dart
  // Simple Usage
  client = new WordpressClient('https://www.example.com/wp-json', 'wp/v2');
  ResponseContainer<List<Post>> posts = await client.listPost((builder) => builder.withPerPage(20).withPageNumber(1).build());
  print(posts.value.first.id);
```

### or

```dart
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
```

each response is wrapped inside `ResponseContainer< >` instance. ResponseContainer contains the actual value (List< Post > here), response status code, error message (if any), Time taken for the request to complete as `Duration()`, The headers received in the response, total posts count, total pages count.

## Supported REST Methods

|                    | Create  | Read    | Update  | Delete  |
|--------------------|---------|---------|---------|---------|
| **Posts**          | yes     | yes     | yes     | yes     |
| **Pages**          | ---     | ---     | ---     | ---     |
| **Comments**       | yes     | yes     | yes     | yes     |
| **Categories**     | yes     | yes     | yes     | yes     |
| **Tags**           | yes     | yes     | yes     | yes     |
| **Users**          | yes     | yes     | yes     | yes     |
| **Media**          | yes     | yes     | yes     | yes     |
| **Post Revisions** | ---     | ---     | ---     | ---     |
| **Taxonomies**     | ---     | ---     | ---     | ---     |
| **Post Types**     | ---     | ---     | ---     | ---     |
| **Post Statuses**  | ---     | ---     | ---     | ---     |
| **Settings**       | ---     | ---     | ---     | ---     |

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

## NOTE

This library is in no way complete. It has many bugs & it has many pending interfaces to implement. It was initially written to fix authorization and few endpoint support which is non-existent in existing Wordpress libraries.

## License

[MIT](License)

[license]: https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE
[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
