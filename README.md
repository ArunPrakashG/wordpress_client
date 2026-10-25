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
    <b>The modern, strongly‑typed WordPress REST API client for Dart & Flutter — fast, flexible, and production‑ready.</b>
  </p>
</div>

## 🚀 Features

- 📦 API discovery support.
- ⏲️ Measures request completion time.
- 📝 Supports all CRUD operations.
- 🌐 Supports all common REST endpoints.
- 🧩 GraphQL (WPGraphQL) support: `client.graphql.query/mutate/raw()` with auth.
- 🎨 Custom Requests & Authorization systems.
- 🔐 3 Popular authorization methods.
- 🗄️ Third‑party Database integration.
- 🔧 Middlewares for request & response operations.
- 🎣 Events for preprocessing response.
- 🚀 Execute requests in Parallel (with configurable error handling).
- 🧠 Optional in‑memory caching for GET requests.
- 🌊 Polling-based streaming for single-resource retrieve endpoints (works great with Riverpod's StreamProvider).

## 📦 Install

Add `wordpress_client` to your `pubspec.yaml`:

```dart
dependencies:
  wordpress_client: ^9.2.0
```

Then run `flutter pub get` or `dart pub get`.

## 🔧 Quick start

Import and initialize:

```dart
import 'package:wordpress_client/wordpress_client.dart';

final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
  // or: baseUrl via WordpressClient(baseUrl: Uri.parse('.../wp-json/wp/v2'))
);
```

### 🧩 GraphQL (WPGraphQL)

If your site uses the WPGraphQL plugin (canonical), you can send GraphQL operations using the same client and auth.

```dart
final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
  bootstrapper: (b) => b
    .withDefaultAuthorization(
      WordpressAuth.appPassword(user: 'user', appPassword: 'xxxx-xxxx'),
    )
    .build(),
);

// Auto-resolves https://example.com/graphql from the REST base.
final result = await client.graphql.query<List<Map<String, dynamic>>>(
  document: '''
    query Posts($limit: Int!) {
      posts(first: $limit) {
        nodes { id title }
      }
    }
  ''',
  variables: { 'limit': 5 },
  parseData: (data) {
    final nodes = (data['posts']?['nodes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return nodes;
  },
  requireAuth: false, // set true for restricted queries/mutations
);

switch (result) {
  case WordpressSuccessResponse():
    print(result.data);
  case WordpressFailureResponse():
    print('GraphQL error: ${result.error}');
}

// Custom endpoint path if your site exposes a different GraphQL path
client.graphql.setEndpointPath('/custom-graphql');
```

Add an auth quickly (helpers available):

```dart
final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
  bootstrapper: (b) => b
    .withDefaultAuthorization(
      // Built-in helpers
      WordpressAuth.appPassword(user: 'user', appPassword: 'xxxx-xxxx'),
      // or: WordpressAuth.usefulJwt(user: 'user', password: 'pass', device: 'device-id')
      // or: WordpressAuth.basicJwt(user: 'user', password: 'pass')
    )
    .build(),
);
```

Enable caching via middleware (optional):

```dart
final client = WordpressClient(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  bootstrapper: (b) => b
    .withCache(
      ttl: const Duration(minutes: 5),               // optional, default 1 minute
      // cache: MyCustomCacheManager(),              // optional custom store
      // clearOnWrite: false,                        // keep cache after POST/PUT/PATCH/DELETE
      // invalidation: CacheInvalidation.all,        // default evicts only the written resource
      // ttlFor: (url) => url.path.endsWith('/categories') ? Duration(hours: 1) : null,
      // shouldCache: (response) => true,            // veto individual responses
    )
    .build(),
);
```

📝 Notes: applies to GET requests; default store is in-memory (custom stores supported); a write evicts only the cached responses of the resource it touched (for example `posts`) by default; custom stores can implement `ISelectiveCache` to support this, otherwise the whole cache is cleared.

### 📩 Send a request

Retrieve 20 recent posts in ascending order:

```dart
final request = ListPostRequest(
  page: 1,
  perPage: 20,
  order: Order.asc,
);

final response = await client.posts.list(request);

// Dart 3 pattern matching
switch (response) {
  case WordpressSuccessResponse():
    final data = response.data; // List<Post>
    break;
  case WordpressFailureResponse():
    final error = response.error; // WordpressError
    break;
}

// Or use helpers
final posts = (await client.posts.list(ListPostRequest(perPage: 20))).map(
  onSuccess: (s) => s.data,
  onFailure: (f) => <Post>[],
);

final justPosts = (await client.posts.list(ListPostRequest(perPage: 20))).dataOrThrow();
```

Convenience extensions are available under `client.<interface>.extensions` for quick lookups and pagination:

```dart
final post = await client.posts.extensions.getById(123);
final allMedia = await client.media.extensions.listAll(perPage: 100);
```

### 🔁 Retries

Transient failures (timeouts, connection errors, `429`/`502`/`503`/`504`) can be retried with exponential backoff, honouring `Retry-After`. Off by default; only idempotent methods are retried, never `POST`/`PATCH`.

```dart
final client = WordpressClient(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  bootstrapper: (b) => b.withRetryPolicy(const RetryPolicy.standard()).build(),
);
```

### 📄 Fetch every page

```dart
// All items in one response (headers of the first page, so totalCount is the full size)
final all = await client.posts.listAll(ListPostRequest(), maxItems: 1000);

// Or lazily, one response per page; stop listening to stop fetching
await for (final page in client.posts.listPages(ListPostRequest(), perPage: 50)) {
  // ...
}
```

### 🧰 Abilities API (WordPress 6.9+)

```dart
final abilities = await client.abilities.list(category: 'site');
final result = await client.abilities.run('my-plugin/get-user-info', input: {'user_id': 1});
```

Requires an authenticated user; only abilities registered with `show_in_rest` are visible.

### 🧪 Testing your code

`package:wordpress_client/testing.dart` ships a Dio adapter that serves canned responses, so you can test code that uses the client without a live site:

```dart
import 'package:wordpress_client/testing.dart';

final adapter = MockWordpressAdapter()
  ..reply('GET', '/posts', MockResponse.paged([{'id': 1, ...}], total: 1, totalPages: 1))
  ..reply('POST', '/posts', MockResponse.wpError(statusCode: 403, code: 'rest_cannot_create'))
  ..replySequence('GET', '/pages', [MockResponse.timeout(), const MockResponse(body: [])]);

final client = WordpressClient.fromDioInstance(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
  instance: Dio()..httpClientAdapter = adapter,
);

// ... exercise your code, then assert on what was sent:
expect(adapter.callCount(method: 'GET', path: '/posts'), 1);
expect(adapter.lastRequest!.headers['Authorization'], isNotNull);
```

## 📚 Advanced docs (Wiki)

Deep-dives and more examples live in the Wiki:

- 🧭 Getting Started: [Usage](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage)
- 📩 [Sending Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Sending-Requests)
- 🛡 [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization)
- ⚡ [Parallel Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Parallel-Requests)
- 🧠 [Caching](https://github.com/ArunPrakashG/wordpress_client/wiki/Caching)
- 🧩 [GraphQL](https://github.com/ArunPrakashG/wordpress_client/wiki/GraphQL)
- 🔗 [Supported REST Methods](https://github.com/ArunPrakashG/wordpress_client/wiki/Supported-REST-Methods)
- 🧩 [Pattern Directory Items](https://github.com/ArunPrakashG/wordpress_client/wiki/Pattern-Directory-Items)
- 🧰 [Using Custom Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests)
- 🧪 [Raw Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Raw-Requests)
- 🔄 [Middlewares](https://github.com/ArunPrakashG/wordpress_client/wiki/Middlewares)
- 📜 [API Changelog](https://github.com/ArunPrakashG/wordpress_client/wiki/API-Changelog)
- 🌊 [Fluent Queries](https://github.com/ArunPrakashG/wordpress_client/wiki/Fluent-Queries)
- 🔄 [Streaming and Polling](https://github.com/ArunPrakashG/wordpress_client/wiki/Streaming-and-Polling)

## 🤝 Feedback & Contributing

- 🐛 For bugs or feature requests, use the [issue tracker][tracker].
- 💡 Contributions are always appreciated. PRs are welcome!

Contributor tips (scripts, release process, consistency guards) are documented in the Wiki.

## 📄 License

This project is [MIT](https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE) licensed.

---

<div align="center">
  If you find this package helpful, consider supporting the development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/arunprakashg)

</div>

[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
