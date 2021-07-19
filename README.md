# WordpressClient

<b>wordpress_client</b> is a library written purely in Dart to interact with Wordpress REST API in a fluent pattern. This library is a port of <b>WordpressCore</b> library written in C#

## Usage

A simple usage example:

initializing the client is simple...

```dart
import 'package:wordpress_client/wordpress_client.dart';

WordpressClient client = WordpressClient(
    'https://www.example.com/wp-json',
    'wp/v2',
);
```

and to send a list posts requests ( get all posts in your website )

```dart
final listPostsResponse = await client.listPost(
    (builder) => builder
        .orderResultsBy(FilterOrder.ASCENDING)
        .withPerPage(20)
        .withPageNumber(1)
        .build(),
  );
```

each response is wrapped inside `ResponseContainer< >` instance. ResponseContainer contains the actual value (List< Post > here), response status code, error message (if any), Time taken for the request to complete as `Duration()`, The headers received in the response, total posts count, total pages count.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

## TODO
* Implement Media operations & interface
* Implement Tag operations & interface
* Implement Comment operations & interface

## NOTE

This library is in no way complete. It has many bugs & it has many pending interfaces to implement. It was initially written to fix authorization and few endpoint support which is non-existent in existing Wordpress libraries.

## License

[MIT](License)

[license]: https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE
[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
