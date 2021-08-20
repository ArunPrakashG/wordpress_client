# WordpressClient

**Downloads |** [Pubspec](https://pub.dev/packages/wordpress_client)

<b>wordpress_client</b> is a library written purely in Dart to interact with Wordpress REST API in a fluent pattern. This library is a port of <b>WordpressCore</b> library written in C# (also written by me)

## NOTE

Authorization API has been sligtly changed on 5.1.0 from previous 5.0.4 build.
Checkout [Supported Authorization Methods](https://github.com/ArunPrakashG/wordpress_client/tree/authorization_rework#supported-authorization-methods) section below for the changed API usage.

## Usage

- Import the library to your project

```dart
import 'package:wordpress_client/wordpress_client.dart';
```

- Initializing the client can be done in two ways.

  - Simple Method (initialize the client with default values)

  ```dart
  WordpressClient client = new WordpressClient('https://www.replaceme.com/wp-json', 'wp/v2');
  ```

  - Advanced Method (with Bootstrapper to configure various settings like User Agent, Authorization etc)

  ```dart
  WordpressClient client = new WordpressClient(
    'https://www.replaceme.com/wp-json',
    'wp/v2',
    bootstrapper: (bootstrapper) => bootstrapper
        .withCookies(true) // Save cookies internall
        .withDefaultUserAgent('wordpress_client/4.0.0')
        .withDefaultMaxRedirects(5)
        .withFollowRedirects(true)
        .withDefaultAuthorizationBuilder(
          // You can use this to pass a custom authorization header on all requests
          (builder) => builder
          .withUserName('test_user')
          .withPassword('super_secret_password')
          .withType(AuthorizationType.BASIC_JWT) // authorization type
          .build(),
        )
        .withStatisticDelegate(
          /*
          provided function will be called when a request is made to any endpoint internally.
          [count] is the amount of times that endpoint is called.
          */
        (baseUrl, endpoint, count) {
          print('Request send to: $baseUrl ($count times)');
      },
    ).build(),
  );
  ```

* To fetch all posts:

```dart
ResponseContainer<List<Post>> response = await client.listPost(
    (builder) => builder
        .withPerPage(20)
        .withPageNumber(1)
        .orderResultsBy(FilterOrder.DESCENDING)
        .sortResultsBy(FilterPostSortOrder.DATE)
        .withAuthorization(BasicJwtAuth('username', 'password'))
        .withCallback(
          Callback(
            unhandledExceptionCallback: (ex) {
              // An unhandled internal exception occured
              print('Unhandled Exception: $ex');
            },
            requestErrorCallback: (errorContainer) {
              /*
                The request error, it has two error containers:
                DioError - Error occured due to fail to send request etc (possibly no internet connection)
                ErrorResponse - Error/Failure in the REST api. This is basically what you receive as a fail response from Wordpress REST api.
              */
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
          // Helps to pre validate the received response if required and cancel the request from futher processing
      if (rawResponse.any((element) => element.content.parsedText == null)) {
        return false;
      }

      return true;
    }).build(),
  );
```

- To get the result:
  All responses are wrapped in a `ResponseContainer<T>` which stores various stastical data as well as the response.
  The Response object `T` is stored in the property `value`
  In the above example, its a `List` request, therefore, the response object is a `List<T>`
  To get the first element, which is of type `Post`
  `Post post = response.value.first;`

Structure of `ResponseContainer<T>`:

```dart
  T value; // the actual response object
  int responseCode; // the response code
  Map<String, dynamic> responseHeaders; // the headers returned from the server
  Duration duration; // time taken for the request to complete as [Duration]
  String message; // any messages regarding the request (errors/info, etc)
```

## Supported Authorization methods

This library has 3 authorization methods currently supported:

- `BasicAuth` - [Basic Auth](https://github.com/WP-API/Basic-Auth) by The Wordpress Team
- `BasicJwtAuth` - [Basic JWT Authentication](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/) by Enrique Chavez
- `UsefulJwtAuth` - [Useful JWT Authentication](https://github.com/usefulteam/jwt-auth) by Useful Team

However, you can create custom authorization systems easily.
Check out [UsefulJwtAuth](https://github.com/ArunPrakashG/wordpress_client/blob/255841ad90eff082f2dd8f82cfd89bc7578e2f1c/lib/src/authorization/authorization_methods/useful_jwt.dart) implementation of JWT Authentication for more details.

- Extend your `CustomAuth` class from `IAuthorization` interface.
- Implement the interface and its methods accordingly. An example is given below.

```dart
class CustomAuth extends IAuthorization {
  CustomAuth(String? username, String? password, {Callback? callback}) : super(username, password, callback: callback);

  @override
  FutureOr<bool> authorize() {}

  @override
  FutureOr<String?> generateAuthUrl() {}

  @override
  FutureOr<bool> init(Dio? client) {}

  @override
  FutureOr<bool> isAuthenticated() {}

  @override
  bool get isValidAuth => throw UnimplementedError();

  @override
  FutureOr<bool> validate() {}
}
```

- To use this authorization system with general requests, simply pass `CustomAuth` object as a parameter to `withAuthorization()` of the request builders like so:

```dart
...
.withAuthorization(CustomAuth('username', 'password', callback: Callback(...)))
...
```

To use this authorization with all the requests, you have to set default authorization on the client, or you have to pass `CustomAuth` on all requests manually.
To set as default authorization, you have to use the bootstrap builder:

```dart
WordpressClient(
    'your base url',
    'api path',
    bootstrapper: (builder) => builder
        ...
        .withDefaultAuthorizationBuilder(CustomAuth('username', 'password', callback: Callback(...)))
        ...
        .build(),
  );
```

Sturucture of `IAuthorization` interface:

```dart
abstract class IAuthorization {
  String? userName;
  String? password;
  Callback? callback;
  bool get isValidAuth;
  bool get isDefault => isNullOrEmpty(userName) || isNullOrEmpty(password);

  IAuthorization(this.userName, this.password, {this.callback});
  FutureOr<bool> init(Dio? client);
  FutureOr<bool> validate();
  FutureOr<bool> isAuthenticated();
  FutureOr<bool> authorize();
  FutureOr<String?> generateAuthUrl();
}
```

## Supported REST Methods

|                    | Create | Read | Update | Delete |
| ------------------ | ------ | ---- | ------ | ------ |
| **Posts**          | yes    | yes  | yes    | yes    |
| **Pages**          | ---    | ---  | ---    | ---    |
| **Comments**       | yes    | yes  | yes    | yes    |
| **Categories**     | yes    | yes  | yes    | yes    |
| **Tags**           | yes    | yes  | yes    | yes    |
| **Users**          | yes    | yes  | yes    | yes    |
| **Me**             | yes    | yes  | yes    | yes    |
| **Media**          | yes    | yes  | yes    | yes    |
| **Post Revisions** | ---    | ---  | ---    | ---    |
| **Taxonomies**     | ---    | ---  | ---    | ---    |
| **Post Types**     | ---    | ---  | ---    | ---    |
| **Post Statuses**  | ---    | ---  | ---    | ---    |
| **Settings**       | ---    | ---  | ---    | ---    |

More endpoint support will be added as the time goes by.

## Custom Response Types (Custom Requests)

It is easy to use a custom json model as return type and query an interface through the library. just make sure while writting the json model, you have to extent from `ISerializable<T>` where `T` being the type of the json model. First you have to initialize the interface with a unique interface id and its type. then you can call the interface directly for the requests.

Sample to query `posts` endpoint if it wasn't implemented:

- Initialize the interface with its type and `interfaceId`

```dart
client.initializeCustomInterface<Post>('posts');
```

- Then you can call available methods such as
  - Create
  - Delete
  - Retrive
  - Update
  - List

with parameters:

- `typeResolver` - which is an instance of the specified return object
- `request` - which is request object build using a builder, all builders must inherit from `IQueryBuilder<TBuilderType, YReturnType>` interface
- `requesterClient` - it is the internal client which handles all the request in and out of this `WordpressClient` instance.
  you can fetch the instance of by using the provided function in wordpress_client
  ```dart
  InternalRequester req = await client.getInternalRequesterClient(shouldWaitIfBusy: false);
  ```
  Here, `shouldWaitIfBusy` bool value indicates if it should wait until all requests in the current `WordpressClient` instance finishes processing.

Below are sample requests for some of the request methods

- **Create request**

```dart
client.getCustomInterface<Post>('posts').create(
        typeResolver: Post(),
        request: PostCreateBuilder()
          .initializeWithDefaultValues()
          .withEndpoint('posts')
          .build(),
        requesterClient: await client.getInternalRequesterClient(shouldWaitIfBusy: false),
      );
```

- **Update request**

```dart
  client.getCustomInterface<Post>('posts').update(
        typeResolver: Post(),
        request: PostUpdateBuilder()
          .initializeWithDefaultValues()
          .withEndpoint('posts')
          .build(),
        requesterClient: await client.getInternalRequesterClient(shouldWaitIfBusy: false),
      );
```

- **Retrive request**

```dart
  client.getCustomInterface<Post>('posts').retrive(
        typeResolver: Post(),
        request: PostRetriveBuilder()
          .initializeWithDefaultValues()
          .withEndpoint('posts')
          .build(),
        requesterClient: await client.getInternalRequesterClient(shouldWaitIfBusy: false),
      );
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

## Contributions

Contributions are always welcome! If you find any bugs/errors, open an issue describing about it and how to reproduce it. :D
meanwhile, PR's for new features/bug fixes are always welcome!

## License

[MIT](License)

[license]: https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE
[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
