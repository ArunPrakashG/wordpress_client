<div align="center">
<h1>wordpress_client</h1>

[![Pub Version](https://img.shields.io/pub/v/wordpress_client?color=blueviolet)](https://pub.dev/packages/wordpress_client)

![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![WordPress](https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white)

A library to interact with the Wordpress REST API. Supports most of the common endpoints and all of the CRUD operations on the endpoints.

</div>

---

## Features

- Support for 3 widely used authorization methods.
- Events for preprocessing operations on the response
- Provides statistics such as time taken for the request to complete.
- Support for Custom Requests & Authorization systems.
- Request Synchronization
- And many more!

## Usage

You can use this library just like any other Dart package.

- Add `wordpress_client` as a dependency on `pubspec.yaml` file on your project root. At the time of this writing, the latest package version is 6.3.3. Do check [Package Page](https://pub.dev/packages/wordpress_client) to get latest version.

```dart
dependencies:
  wordpress_client: ^8.0.3
```

- Import the library to your project class in which you want to use the library.

```dart
import 'package:wordpress_client/wordpress_client.dart';
```

- Initializing the client can be done in two ways. It is recommended to initialize `WordpressClient` once and assign the instance to a variable for later use. State of the properties are stored only in that particular instance of the client.

  - Simple method, Initialize with default values.
  - Advanced method (with Bootstrapper to configure various settings like User Agent, Authorization etc)

### Simple method

```dart
final baseUrl = Uri.parse('https://example.com/wp-json/wp/v2');
final client = WordpressClient(baseUrl: baseUrl);

// Call this on splash screen / or anywhere where you have your initializing logic
client.initialize();
```

You can read about advanced method in [Advanced Method](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage#advanced-method) wiki page.

- You are now prepared to send requests to the WordPress REST API. For instance, to retrieve the 20 most recent posts from your WordPress site in ascending order, you can use the following code snippet:

```dart
final request = ListPostRequest(
  page: 1,
  perPage: 20,
  order = Order.asc,
);

final wpResponse = await client.posts.list(request);

// Dart 3 style
switch (wpResponse) {
    case WordpressSuccessResponse():
      final data = wpResponse.data; // List<Post>
      break;
    case WordpressFailureResponse():
      final error = wpResponse.error; // WordpressError
      break;
}

// or
// wordpress_client style
final result = postsResponse.map(
    onSuccess: (response) {
      print(response.message);
      return response.data;
    },
    onFailure: (response) {
      print(response.error.toString());
      return <Post>[];
    },
);
```

`WordpressResponse` is a class that encapsulates the actual result object (or error, depending on the result) and provides access to statistical data related to the response, such as the time taken for the request to complete, status codes, and the total number of pages.

Once `WordpressResponse` is received, It is important to compare the underlying type to `WordpressSuccessResponse` or `WordpressFailureResponse` to determine the actual result of the request. In order to do this, there are various getters and methods available on the type.

Once mapped, if the response is of type `WordpressSuccessResponse`, the resuling data of the response can be accessed on the `data` property. If the result is of type `WordpressFailureResponse`, the error details can be accessed on the `error` property.

## Supported Authorization methods

This library has 3 authorization methods currently supported:

- **BasicAuth** - [Basic Auth](https://github.com/WP-API/Basic-Auth) by The Wordpress Team
- **BasicJwtAuth** - [Basic JWT Authentication](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/) by Enrique Chavez
- **UsefulJwtAuth** - [Useful JWT Authentication](https://github.com/usefulteam/jwt-auth) by Useful Team

For Custom Authorization implementation, Check out [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization#custom-authorization) wiki page.

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
| **Search**         | ---    | yes  | ---    | ---    |
| **Post Revisions** | ---    | ---  | ---    | ---    |
| **Taxonomies**     | ---    | ---  | ---    | ---    |
| **Post Types**     | ---    | ---  | ---    | ---    |
| **Post Statuses**  | ---    | ---  | ---    | ---    |
| **Settings**       | ---    | ---  | ---    | ---    |

## Custom Response Types (Custom Requests)

Check out [Custom Response Types](https://github.com/ArunPrakashG/wordpress_client/wiki/Custom-Requests) wiki page.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

## Contributions

Contributions are always welcome! If you find any bugs/errors, open an issue describing about it and how to reproduce it. :D
meanwhile, PR's for new features/bug fixes are always welcome!

## License

[MIT](License)

[license]: https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE
[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues

<a href="https://www.buymeacoffee.com/arunprakashg" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
