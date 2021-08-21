# WordpressClient

**Downloads |** [Pubspec](https://pub.dev/packages/wordpress_client) 

[![likes](https://badges.bar/wordpress_client/likes)](https://pub.dev/packages/wordpress_client/score) [![popularity](https://badges.bar/wordpress_client/popularity)](https://pub.dev/packages/wordpress_client/score) [![pub points](https://badges.bar/wordpress_client/pub%20points)](https://pub.dev/packages/wordpress_client/score)

**wordpress_client** is a library written purely in Dart to interact with Wordpress REST API in a fluent pattern. This library is a port of [WordpressCore](https://github.com/ArunPrakashG/WordpressCore) library written in C# (also written by me)

## NOTE

**Authorization API has been sligtly changed on 5.1.0 from previous 5.0.4 build.** You can read more about this change in [API Changes](https://github.com/ArunPrakashG/wordpress_client/wiki/API-Changes) Wiki

## Usage

You can use this library just like any other Dart package.

- Add `wordpress_client` as a dependency on `pubspec.yaml` file on your project root. At the time of this writing, the latest package version is 5.1.0. Do check [Package Page](https://pub.dev/packages/wordpress_client) to get latest version.

```dart
dependencies:
  wordpress_client: ^5.1.0
```

- Import the library to your project class in which you want to use the library. 
```dart
import 'package:wordpress_client/wordpress_client.dart';
```

- Initializing the client can be done in two ways. It is recommended to initialize `WordpressClient` once and assign the instance to a variable for later use. Else, if you are using cookies, it may not work properly.

  - Simple method, Initialize with default values.
  - Advanced method (with Bootstrapper to configure various settings like User Agent, Authorization etc)

### Simple method
```dart
WordpressClient client = new WordpressClient('https://www.replaceme.com/wp-json', 'wp/v2');
```
You can read about advanced method in [Advanced Method](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage#advanced-method) wiki page.

- Now you are ready to send requests to Wordpress REST API. For example, to send request to get the latest 20 posts in your Wordpress site:
```dart
ResponseContainer<List<Post>> response = await client.listPost(
    (builder) => builder
        .withPerPage(20)
        .withPageNumber(1)
        .sortResultsBy(FilterPostSortOrder.DATE)
        .build(),
  );
```

Here, the `ResponseContainer<T>` holds result `T` object, in this case, its `List<Post>` as we requested for list of latest posts, with some statistical data, like the time taken for the request to complete (it doesn't count the time taken to process the response information, just the raw request) as a `Duration()` object.

## Supported Authorization methods

This library has 3 authorization methods currently supported:

- `BasicAuth` - [Basic Auth](https://github.com/WP-API/Basic-Auth) by The Wordpress Team
- `BasicJwtAuth` - [Basic JWT Authentication](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/) by Enrique Chavez
- `UsefulJwtAuth` - [Useful JWT Authentication](https://github.com/usefulteam/jwt-auth) by Useful Team

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
| **Post Revisions** | ---    | ---  | ---    | ---    |
| **Taxonomies**     | ---    | ---  | ---    | ---    |
| **Post Types**     | ---    | ---  | ---    | ---    |
| **Post Statuses**  | ---    | ---  | ---    | ---    |
| **Settings**       | ---    | ---  | ---    | ---    |


## Custom Response Types (Custom Requests)
Check out [Custom Response Types](https://github.com/ArunPrakashG/wordpress_client/wiki/Custom-Response-Types-(Custom-Requests)) wiki page.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

## Contributions

Contributions are always welcome! If you find any bugs/errors, open an issue describing about it and how to reproduce it. :D
meanwhile, PR's for new features/bug fixes are always welcome!

## License

[MIT](License)

[license]: https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE
[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
