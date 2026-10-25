<div align="center">
  <h1>WordPress Client</h1>

  <p align="center">
    <a href="https://pub.dev/packages/wordpress_client">
      <img src="https://img.shields.io/pub/v/wordpress_client?color=blueviolet" alt="Pub Version"/>
    </a>
    <a href="https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/ArunPrakashG/wordpress_client?color=blue" alt="License"/>
    </a>
    <a href="https://github.com/ArunPrakashG/wordpress_client/stargazers">
      <img src="https://img.shields.io/github/stars/ArunPrakashG/wordpress_client?style=social" alt="Stars"/>
    </a>
    <br>
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white" alt="WordPress"/>
    <br>
    <b>A strongly typed WordPress client for Dart & Flutter: REST, GraphQL and the Abilities API.</b>
  </p>
</div>

## Features

- **Typed REST client** for 30+ endpoints (posts, pages, media, users, comments, taxonomies, blocks, templates, navigation, widgets, settings, themes, ...) with full CRUD. See [Supported REST Methods](https://github.com/ArunPrakashG/wordpress_client/wiki/Supported-REST-Methods).
- **Typed results**: `WordpressResponse<T>` is a success or a failure; failures classify into a sealed `WordpressFailure`.
- **Auth**: Application Passwords (including the browser "authorize application" flow), JWT (two plugins), or your own `IAuthorization`. Credentials never follow the client to another origin.
- **Resilience**: opt-in retries with backoff and `Retry-After`.
- **Caching**: GET cache with per-resource invalidation and ETag revalidation. Custom stores supported.
- **Pagination**: `listPages` / `listAll`, plus parallel page fetching.
- **GraphQL (WPGraphQL)**: queries, mutations, partial results, GET, pagination, batching, persisted queries.
- **Abilities API** (WordPress 6.9+).
- **Custom post types and plugin routes**: `client.resource<T>('events', decoder: ...)` gives typed CRUD and pagination for any collection.
- **Fewer round trips**: `_embed` / `_fields` helpers, the WordPress batch endpoint (`client.batch`), request de-duplication and a concurrency limit.
- **Offline writes**: `OfflineWriteQueue` keeps writes that fail offline and replays them in order.
- **Extensibility**: middlewares, Dio interceptors, custom endpoints, raw requests, polling streams.
- **Testable**: `MockWordpressAdapter` serves canned responses, no live site needed.

## Install

```yaml
dependencies:
  wordpress_client: ^10.0.0
```

Requires Dart `>=3.0.0`.

## Quick start

```dart
import 'package:wordpress_client/wordpress_client.dart';

// From the site root (resolves <site>/wp-json/wp/v2)
final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
);

// Or from the REST base URL
final same = WordpressClient(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
);

final response = await client.posts.list(ListPostRequest(perPage: 10));

switch (response) {
  case WordpressSuccessResponse():
    print(response.data.map((p) => p.title?.rendered)); // List<Post>
  case WordpressFailureResponse():
    print('${response.code}: ${response.message}');
}
```

Create the client once and reuse it. Call `client.dispose()` when done.

## Configure

```dart
final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
  bootstrapper: (b) => b
      .withDefaultAuthorization(
        WordpressAuth.appPassword(user: 'admin', appPassword: 'xxxx xxxx xxxx'),
      )
      .withRequestTimeout(const Duration(seconds: 20))
      .withRetryPolicy(const RetryPolicy.standard())
      .withCache(ttl: const Duration(minutes: 5))
      .withRequestDeduplication()         // identical concurrent GETs share one call
      .withMaxConcurrentRequests(6)       // queue the rest
      .withDefaultUserAgent('my-app/1.0')
      .build(),
);
```

More: [Bootstrap and Configuration](https://github.com/ArunPrakashG/wordpress_client/wiki/Bootstrap-and-Configuration), [Request De-duplication and Concurrency](https://github.com/ArunPrakashG/wordpress_client/wiki/Request-Deduplication-and-Concurrency), [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization).

## Sign in with the browser

Let the user approve your app on their own site (WordPress 5.6+). No password is ever typed into your app.

```dart
await client.discover();
final flow = AppPasswordFlow.fromDiscovery(
  client.discovery,
  appName: 'My App',
  successUrl: Uri.parse('myapp://wp-callback'),
  rejectUrl: Uri.parse('myapp://wp-rejected'),
);
// open flow.authorizeUrl in the system browser, then on the redirect:
final result = flow.parseCallback(callbackUri);
if (result is AppPasswordGranted) {
  client.reconfigure(
    bootstrapper: (b) => b.withDefaultAuthorization(result.toAuthorization()).build(),
  );
}
```

More: [Browser Sign-In](https://github.com/ArunPrakashG/wordpress_client/wiki/Browser-Sign-In), [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization).

## Read, create, update, delete

```dart
final post = (await client.posts.retrieve(RetrievePostRequest(id: 1))).dataOrThrow();

await client.posts.create(CreatePostRequest(
  title: 'Hello',
  content: '<p>First post</p>',
  status: 'draft',
));

await client.posts.update(UpdatePostRequest(id: 1, title: 'Renamed'));
await client.posts.delete(DeletePostRequest(id: 1, force: true));
```

Write requests need credentials (`withDefaultAuthorization`, or `authorization:` on the request).

## Handle results

```dart
final r = await client.posts.list(ListPostRequest());

final posts = r.dataOrThrow();                         // throws on failure
final safe = r.dataOrNull();                           // null on failure
final count = r.map(onSuccess: (s) => s.data.length, onFailure: (_) => 0);

if (r case WordpressFailureResponse(:final failure)) {
  switch (failure) {
    case NetworkFailure(:final kind): print('network: $kind');       // timeout, connection, cancelled
    case AuthFailure(:final reason):  print('auth: $reason');
    case ApiFailure(:final statusCode, :final error): print('$statusCode ${error?.code}');
    case DecodeFailure():             print('bad response body');
    case MiddlewareFailure():         print('a middleware aborted it');
    case ClientFailure(:final type):  print('client: $type');
  }
}
```

More: [Error Handling and Responses](https://github.com/ArunPrakashG/wordpress_client/wiki/Error-Handling-and-Responses).

## Query fluently

```dart
final res = await client.posts.query
    .withSearch('flutter')
    .withCategories([3, 7])
    .withOrder(Order.desc)
    .withPerPage(20)
    .execute();

final bySlug = await client.pages.extensions.findBySlug('about'); // Page?

// One request instead of three: embed the author and featured image
final embedded = await client.posts.query.withEmbed(['author', 'wp:featuredmedia']).execute();
final post = embedded.dataOrThrow().first;
print(post.embedded.author?.name);          // also post.embedded.featuredMedia
final lean = await client.posts.query.withFields(['id', 'title', 'link']).execute();
```

More: [Fluent Queries](https://github.com/ArunPrakashG/wordpress_client/wiki/Fluent-Queries), [Embed and Fields](https://github.com/ArunPrakashG/wordpress_client/wiki/Embed-and-Fields), [Interfaces and Extensions](https://github.com/ArunPrakashG/wordpress_client/wiki/Interfaces-and-Extensions).

## Paginate

```dart
// Everything in one response (use maxItems to cap it)
final all = await client.posts.listAll(ListPostRequest(), maxItems: 1000);

// Lazily, one response per page
await for (final page in client.posts.listPages(ListPostRequest(), perPage: 50)) {
  // page is a WordpressResponse<List<Post>>; a failing page ends the stream
}

// Pages in parallel
final merged = await client.parallel
    .list<Post, ListPostRequest>(
      interface: client.posts,
      requestBuilder: () => [
        for (var p = 1; p <= 10; p++)
          ParallelRequest(page: p, request: ListPostRequest(page: p, perPage: 50)),
      ],
    )
    .merge();
```

More: [Pagination and Finders](https://github.com/ArunPrakashG/wordpress_client/wiki/Pagination-and-Finders), [Parallel Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Parallel-Requests).

## Retries

Off by default. Retries timeouts, connection errors and `429/502/503/504`, only for idempotent methods (never `POST`/`PATCH`).

```dart
b.withRetryPolicy(const RetryPolicy(maxAttempts: 4, baseDelay: Duration(seconds: 1)))

// override for one raw request
client.raw(WordpressRequest(
  method: HttpMethod.get,
  url: RequestUrl.relative('posts'),
  retryPolicy: RetryPolicy.none,
));
```

More: [Retries](https://github.com/ArunPrakashG/wordpress_client/wiki/Retries).

## Cache

```dart
b.withCache(
  ttl: const Duration(minutes: 5),
  ttlFor: (url) => url.path.endsWith('/categories') ? const Duration(hours: 1) : null,
)
```

GET responses are cached per URL, query and credential. A write evicts only the resource it touched. Expired entries with an `ETag` are revalidated with a `304`. More: [Caching](https://github.com/ArunPrakashG/wordpress_client/wiki/Caching).

## GraphQL (WPGraphQL)

```dart
final res = await client.graphql.query<List<Map<String, dynamic>>>(
  document: r'query($n: Int!) { posts(first: $n) { nodes { id title } } }',
  variables: {'n': 5},
  parseData: (d) => (d['posts']['nodes'] as List).cast<Map<String, dynamic>>(),
);

// Keep data and errors together (partial results)
final result = await client.graphql.execute<Map<String, dynamic>>(
  document: '{ viewer { name } }',
  parseData: (d) => d,
  requireAuth: true,
);
if (result case WordpressSuccessResponse(:final data)) {
  print(data.data); print(data.errors);
}
```

Also `mutate`, `useGet`, `paginate` / `queryAll`, `batch`, persisted queries and registered queries. More: [GraphQL](https://github.com/ArunPrakashG/wordpress_client/wiki/GraphQL).

## Custom post types and plugin routes

```dart
class Event {
  Event(this.id, this.title);
  factory Event.fromJson(Map<String, dynamic> j) => Event(j['id'] as int, j['title'] as String);
  final int id;
  final String title;
  Map<String, dynamic> toJson() => {'title': title};
}

final events = client.resource<Event>('events', decoder: Event.fromJson, encoder: (e) => e.toJson());
final all = (await events.listAll()).dataOrThrow();
final one = (await events.retrieve(7)).dataOrThrow();
await events.create(Event(0, 'Launch'));

// A plugin namespace instead of wp/v2
final orders = client.resource<Order>('orders', namespace: 'my-shop/v1', decoder: Order.fromJson);
```

More: [Custom Post Types](https://github.com/ArunPrakashG/wordpress_client/wiki/Custom-Post-Types).

## Batch writes

```dart
final result = (await client.batch.run([
  const BatchOperation.create('posts', body: {'title': 'A', 'status': 'draft'}),
  BatchOperation.update('posts', 12, body: {'title': 'B'}),
  BatchOperation.delete('posts', 13, force: true),
])).dataOrThrow();

print('${result.succeeded.length} ok, ${result.failures.length} failed');
```

Sent to `/wp-json/batch/v1` (WordPress 5.6+), 25 per call; longer lists are split for you. More: [Batch Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Batch-Requests).

## Offline writes

```dart
final queue = OfflineWriteQueue(store: MemoryWriteQueueStore()); // implement WriteQueueStore to persist
final client = WordpressClient.forSite(
  siteUrl: siteUrl,
  bootstrapper: (b) => b.withMiddleware(queue).withDefaultAuthorization(auth).build(),
);

final r = await client.posts.create(CreatePostRequest(title: 'Hi'));
if (r.wasQueued) showSnack('Saved, will sync when online');

final sync = await queue.flush(client);          // when connectivity returns
print('${sync.sent.length} sent, ${sync.rejected.length} refused, ${sync.remaining} left');
```

Only JSON writes that failed to connect are queued (timeouts only with `queueOnTimeout: true`, because the server may have processed them).

More: [Offline Write Queue](https://github.com/ArunPrakashG/wordpress_client/wiki/Offline-Write-Queue), [Middlewares](https://github.com/ArunPrakashG/wordpress_client/wiki/Middlewares).

## Abilities API (WordPress 6.9+)

```dart
final abilities = (await client.abilities.list(category: 'site')).dataOrThrow();
final out = await client.abilities.run('my-plugin/get-user-info', input: {'user_id': 1});
```

Requires an authenticated user. More: [Abilities](https://github.com/ArunPrakashG/wordpress_client/wiki/Abilities).

## Middlewares

```dart
client.registerMiddleware(
  DelegatedMiddleware(
    onRequestDelegate: (req) async {
      print('-> ${req.method.name} ${req.extra[WordpressRequest.metaUrl]}');
      return req;
    },
    onResponseDelegate: (res) async {
      print('<- ${res.code} in ${res.duration.inMilliseconds}ms');
      return res;
    },
  ),
);
```

`LoggingMiddleware(sink: print)` logs one line per request with credentials redacted ([Logging](https://github.com/ArunPrakashG/wordpress_client/wiki/Logging)), and `CacheMiddleware` / `OfflineWriteQueue` are middlewares too.

More: [Middlewares](https://github.com/ArunPrakashG/wordpress_client/wiki/Middlewares).

## Custom endpoints and raw requests

```dart
// Any URL on the client's origin, untyped
final raw = await client.raw(WordpressRequest(
  method: HttpMethod.get,
  url: RequestUrl.relative('posts'),
  queryParameters: {'per_page': 1},
));
print(raw.code); print(raw.data);
```

Typed custom endpoints: [Using Custom Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests). Polling streams: [Streaming and Polling](https://github.com/ArunPrakashG/wordpress_client/wiki/Streaming-and-Polling).

## Test your code

```dart
import 'package:dio/dio.dart';
import 'package:wordpress_client/testing.dart';
import 'package:wordpress_client/wordpress_client.dart';

final adapter = MockWordpressAdapter()
  ..reply('GET', '/posts', MockResponse.paged([{'id': 1}], total: 1, totalPages: 1))
  ..reply('POST', '/posts', MockResponse.wpError(statusCode: 403, code: 'rest_cannot_create'));

final client = WordpressClient.fromDioInstance(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  instance: Dio()..httpClientAdapter = adapter,
);

expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
```

More: [Testing](https://github.com/ArunPrakashG/wordpress_client/wiki/Testing).

## Security notes

- A request is only sent to the client's own origin (scheme, host and port). Anything else fails with `RequestErrorType.originMismatch`.
- `reconfigure(baseUri: ...)` to a different origin drops the default credentials and discovery data. Pass new credentials in the same call.
- Cache keys hold a SHA-256 digest of the `Authorization` header, never the header itself.

## Documentation

Everything is in the [Wiki](https://github.com/ArunPrakashG/wordpress_client/wiki):

| Start | Requests | Behaviour | Extend |
| --- | --- | --- | --- |
| [Usage](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage) | [Sending Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Sending-Requests) | [Retries](https://github.com/ArunPrakashG/wordpress_client/wiki/Retries) | [Middlewares](https://github.com/ArunPrakashG/wordpress_client/wiki/Middlewares) |
| [Bootstrap and Configuration](https://github.com/ArunPrakashG/wordpress_client/wiki/Bootstrap-and-Configuration) | [Fluent Queries](https://github.com/ArunPrakashG/wordpress_client/wiki/Fluent-Queries) | [Caching](https://github.com/ArunPrakashG/wordpress_client/wiki/Caching) | [Using Custom Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests) |
| [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization) | [Pagination and Finders](https://github.com/ArunPrakashG/wordpress_client/wiki/Pagination-and-Finders) | [Error Handling and Responses](https://github.com/ArunPrakashG/wordpress_client/wiki/Error-Handling-and-Responses) | [Raw Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Raw-Requests) |
| [Supported REST Methods](https://github.com/ArunPrakashG/wordpress_client/wiki/Supported-REST-Methods) | [Parallel Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Parallel-Requests) | [Events and Statistics](https://github.com/ArunPrakashG/wordpress_client/wiki/Events-and-Statistics) | [Integration with Storage Packages](https://github.com/ArunPrakashG/wordpress_client/wiki/Integration-with-Storage-Packages) |
| [API Changelog](https://github.com/ArunPrakashG/wordpress_client/wiki/API-Changelog) | [GraphQL](https://github.com/ArunPrakashG/wordpress_client/wiki/GraphQL), [Abilities](https://github.com/ArunPrakashG/wordpress_client/wiki/Abilities) | [Streaming and Polling](https://github.com/ArunPrakashG/wordpress_client/wiki/Streaming-and-Polling) | [Testing](https://github.com/ArunPrakashG/wordpress_client/wiki/Testing) |

## Contributing

Bugs and feature requests go to the [issue tracker][tracker]. PRs are welcome.

## License

[MIT](https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE)

---

<div align="center">
  If this package helps you, consider supporting its development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/arunprakashg)

</div>

[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
