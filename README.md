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
- 🌐 Supports all common endpoints.
- 🎨 Custom Requests & Authorization systems.
- 🔐 3 Popular authorization methods.
- 🗄️ Third‑party Database integration.
- 🔧 Middlewares for request & response operations.
- 🎣 Events for preprocessing response.
- 🚀 Execute requests in Parallel (with configurable error handling).
- 🧠 Optional in‑memory caching for GET requests.
  <!-- Fluent queries moved to Wiki to keep the README light. See Advanced docs links below. -->
  <!-- Fluent queries moved to Wiki to keep the README light. See Advanced docs links below. -->
  final client = WordpressClient.forSite(
  siteUrl: Uri.parse('https://example.com'),
- 🌊 [Fluent Queries](https://github.com/ArunPrakashG/wordpress_client/wiki/Fluent-Queries)
  );

````

Or pass the REST base directly:

```dart
final client = WordpressClient(
  baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
);
````

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
    )
    .build(),
);
```

📝 Notes: applies to GET requests; default store is in-memory (custom stores supported); cache clears by default on writes.

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

### 🌊 Fluent queries (no seed required)

Build and send list requests fluently without constructing request classes manually. Each interface exposes a `query` property that auto‑seeds the correct list request type:

```dart
final res = await client.posts.query
  .withPage(1)
  .withPerPage(20)
  .withSearch('welcome')
  .withOrder(Order.desc)
  .execute();

// Advanced: mutate the underlying seed
final res2 = await client.posts.query
  .configureSeed((seed) {
    seed.context = RequestContext.view;
  })
  .execute();

// Or access it directly if you need to inspect/change fields
final builder = client.posts.query;
builder.seedRequest.context = RequestContext.view;
final res3 = await builder.execute();
```

Notes:

- Some auto‑seeded builders (e.g., revisions/navigation) default to placeholder IDs. Set them via `configureSeed` (or `seedRequest`) before `execute()`.
- Fluent helpers like `withPage`, `withPerPage`, `withSearch`, `withOrder`, `withOrderBy`, `withCategories`, `withTags`, and more are available; anything not covered can be set on the seed.

## 📚 Advanced docs (Wiki)

Deep-dives and more examples live in the Wiki:

- 🧭 Getting Started: [Usage](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage)
- 📩 [Sending Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Sending-Requests)
- 🛡 [Authorization](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization)
- ⚡ [Parallel Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Parallel-Requests)
- 🧠 [Caching](https://github.com/ArunPrakashG/wordpress_client/wiki/Caching)
- 🔗 [Supported REST Methods](https://github.com/ArunPrakashG/wordpress_client/wiki/Supported-REST-Methods)
- 🧩 [Pattern Directory Items](https://github.com/ArunPrakashG/wordpress_client/wiki/Pattern-Directory-Items)
- 🧰 [Using Custom Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests)
- 🧪 [Raw Requests](https://github.com/ArunPrakashG/wordpress_client/wiki/Raw-Requests)
- 🔄 [Middlewares](https://github.com/ArunPrakashG/wordpress_client/wiki/Middlewares)
- 🧪 Local Testing & Docker setup (see Wiki: Usage/Testing)
- 📜 [API Changelog](https://github.com/ArunPrakashG/wordpress_client/wiki/API-Changelog)

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
