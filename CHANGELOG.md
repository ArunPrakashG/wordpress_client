## 10.0.0

Retries, auto-pagination, cache revalidation, GraphQL improvements and the Abilities API ship together with the breaking changes below.

Breaking

- **Requests are locked to the client's origin.** An absolute `RequestUrl` is used verbatim only when its scheme, host and port match the base URL; otherwise the request is not sent and the response has `RequestErrorType.originMismatch`. Previously only the host was rewritten. The base URL changes only via a new client or `reconfigure(baseUri: ...)`. (#87)
- **Credentials follow the origin.** `reconfigure(baseUri: ...)` to a different scheme, host or port drops the default authorization and the cached discovery data, so credentials are never sent to a site they were not meant for. Pass the new credentials in the `bootstrapper` of the same call. `clearDefaultAuthorization()` now also survives later `reconfigure` calls, and `BootstrapBuilder.withoutDefaultAuthorization()` was added. Per-request `authorization` is unaffected. (#87)
- **Request metadata is no longer sent as HTTP headers.** The `method`, `request-url` and `request-query` pseudo-headers are gone. Middlewares read them from the new `WordpressRequest.extra` (keys `WordpressRequest.metaMethod`, `metaUrl`, `metaQuery`), which is also copied onto `WordpressRawResponse.extra`. (#85)
- **No more process-wide state.** `CodableMap` decoders/encoders and the endpoint statistics (counts and the `withStatisticDelegate` callback) are now owned by each `WordpressClient`. `CodableMap.getDecoder/getEncoder` are instance methods, and the global `serialize<T>()`/`deserialize<T>()` helpers are removed. Disposing one client no longer clears the codecs of every other client. (#92)
- **Transport errors are classified.** Timeouts, connection errors and cancelled requests used to surface as `internalGenericError` with the stack trace in `message`. They now use `RequestErrorType.timeout`, `connectionFailed` and `requestCancelled`; the exception and stack trace stay in `extra` (`exception` / `stackTrace` on the failure response). Invalid JSON behind a JSON content type is `invalidResponse`. (#93)
- `RequestErrorType` gained `originMismatch`, `invalidResponse` and `timeout` (appended, existing indices unchanged).

Changed

- GraphQL requests now run through the middleware pipeline (`onRequest` / `onResponse`) like REST requests, and transport errors are returned as failures instead of thrown.

Fixed

- `CacheMiddleware` never served a hit because the lookup and store keys differed. Both now come from one function. (#84)
- Cache keys no longer contain the `Authorization` value, only a SHA-256 digest of it. (#89)
- `WordpressRawResponse.duration` now covers the full round trip (it was ~0), including a re-auth retry. (#86)
- A 2xx response whose body cannot be decoded (for example a non-array body for a list endpoint) now returns a `WordpressFailureResponse` with `RequestErrorType.invalidResponse` instead of throwing a cast error. (#88)
- The GraphQL endpoint follows `reconfigure(baseUri: ...)`; a custom `setEndpointPath` survives it.
- The request header map passed in a `WordpressRequest` is no longer mutated.
- `WordpressRawResponse.asResponse` no longer throws on a failure with a null or non-map body.

Added

- **Abilities API** (WordPress 6.9+). `client.abilities` lists and retrieves abilities (`list`, `listAll`, `retrieve`), their categories (`categories`, `category`) and runs them (`run`, `runAbility`), picking `GET` / `DELETE` / `POST` from the ability's `readonly` / `destructive` annotations. Requests go to `/wp-json/wp-abilities/v1` on the client's own origin and always send credentials. New models `Ability` and `AbilityCategory`. (#99)
- **GraphQL improvements.** (#100)
  - `graphql.execute` returns data *and* errors as a `GraphQLResult` (`GraphQLError` with `path`, `locations`, `extensions`), so partial responses are usable. `query` still fails on errors but now exposes them as `extra[GraphQLInterface.errorsKey]`.
  - `query(useGet: true)` sends reads with `GET`, so `CacheMiddleware`, HTTP caches and retries apply. `mutate` is now a real mutation call: it rejects non-mutation documents, always uses `POST` and clears the cache; `POST` queries no longer clear it.
  - `graphql.paginate` / `queryAll` walk a Relay connection (`pageInfo.endCursor`, `nodes` or `edges { node }`).
  - Automatic Persisted Queries (`useAutomaticPersistedQueries`) and query batching (`graphql.batch`).
- **Automatic retries.** `BootstrapBuilder.withRetryPolicy(RetryPolicy.standard())` retries timeouts, connection errors and 429/502/503/504 with exponential backoff and jitter, honouring `Retry-After`. Only idempotent methods are retried by default (never `POST`/`PATCH`), cancelling a request aborts the wait, and `WordpressRequest.retryPolicy` overrides the client policy per request. The number of tries is reported in `extra[WordpressRequest.metaAttempts]`. Off by default. (#96)
- **Auto-pagination.** Every list interface gains `listPages(request)`, a lazy `Stream` with one response per page driven by `X-WP-TotalPages`, and `listAll(request)`, which collects all pages into one response. Both take `perPage` (default 100) and `maxPages`; `listAll` also takes `maxItems`. A failing page ends the walk. (#97)
- **Resource-level cache invalidation.** A successful write now evicts only the cached GET responses of the resource it touched (`CacheInvalidation.resource`, the new default) instead of the whole cache; `CacheInvalidation.all` restores the old behaviour. New `ISelectiveCache.removeWhere` (implemented by `MemoryCacheStore`; other stores fall back to `clear()`), plus `ttlFor` (per-endpoint TTL) and `shouldCache` hooks on `CacheMiddleware` / `withCache`. (#90)
- **ETag / Last-Modified revalidation.** `CacheMiddleware` keeps expired entries that carry a validator for `revalidateWindow` (default 1 hour) and revalidates them with `If-None-Match` / `If-Modified-Since`; a `304` refreshes the cached body without downloading it (`X-Cache: REVALIDATED`). `MiddlewareRawResponse.requestHeaders` lets any middleware add headers from `onExecute`. Only 2xx responses are cached now (3xx used to be). (#98)
- **Typed failures.** `WordpressFailureResponse.failure` returns a sealed `WordpressFailure` (`NetworkFailure`, `AuthFailure`, `ApiFailure`, `DecodeFailure`, `MiddlewareFailure`, `ClientFailure`) that can be switched over exhaustively, each carrying its `cause`, `stackTrace` and relevant details (status code, `WordpressError`, raw body). The existing `code`, `error`, `message` and `exception` accessors are unchanged, and `WordpressFailureResponse.errorType` was added. (#93)
- `package:wordpress_client/testing.dart` with `MockWordpressAdapter`, `MockResponse` and `RecordedRequest` for testing code that uses the client without a live site. (#94, #101)
- `WordpressRequest.extra` for local request metadata.

Internal

- The request executor's six copy-pasted pipelines are one `_pipeline` plus one `_toResponse`. `retrive` is renamed `retrieve` (the old name is a deprecated alias). (#91)
- Offline test suite under `test/offline`; integration tests are tagged `integration` and CI runs `dart test -x integration` with a coverage floor. Integration credentials now come from `WP_*` environment variables first, then `test/test_local.json`. (#94, #95)

## 9.4.0

Added

- **GraphQL Registered Queries**: Register and reuse GraphQL queries throughout your application.
  - New `RegisteredQuery<T>` class to encapsulate query document, parser, default variables, and auth requirements.
  - Registry methods on `GraphQLInterface`:
    - `register()` / `registerAll()` - Add queries to the registry
    - `unregister()` / `clearRegistry()` - Remove queries
    - `isRegistered()` / `registeredQueryNames` / `registeredQueryCount` - Query the registry
    - `getRegistered()` - Retrieve a registered query definition
    - `executeRegistered()` - Execute a registered query by name with optional variable overrides
  - Variables from `defaultVariables` merge with execution-time variables.

Docs

- Wiki GraphQL page updated with Registered Queries section and examples.

## 9.3.0

Added

- Streaming APIs for polling single-resource endpoints:
  - `RetrieveOperation.retrieveStream(...)` for built-in retrieve operations
  - `CustomOperation.requestStream(...)` for custom interfaces
  - Features: configurable interval, emit-on-start, distinct-by-data, optional failure emissions with de-duplication, external CancelToken support, and on-demand `refetchTrigger`.

Fixed

- Middleware execution now maps `MiddlewareRawResponse.body` into `WordpressRawResponse.data`, so decoders receive the actual payload.
- `RequestUrl.relativeParts(...)` now uses forward slashes regardless of OS to avoid Windows path separator issues.

Docs

- README feature list updated; new Wiki page: Streaming and Polling with examples and Riverpod wiring.

## 9.2.0

Added

- GraphQL support via `client.graphql` targeting WPGraphQL endpoint (`/graphql`).
  - query(), mutate(), and raw() helpers.
  - Works with existing authorization (Application Passwords, JWT, etc.).
  - Reuses middlewares, timeouts, and response helpers.
  - Endpoint auto-resolves from REST base and can be overridden via `client.graphql.setEndpointPath()`.

Docs

- README updated with usage examples.
- Wiki updated with a new GraphQL page and links in the sidebar.

## 9.0.0

- New response models: Added typed models for multiple WordPress REST resources

  - Settings (`/wp/v2/settings`)
  - Sidebars (`/wp/v2/sidebars`) including widget handling
  - Taxonomies (e.g., categories, tags)
  - Template Parts (`/wp/v2/template-parts`)
  - Templates (`/wp/v2/templates`)
  - Themes (`/wp/v2/themes`)
  - Widgets (`/wp/v2/widgets`)
  - Widget Types (`/wp/v2/widget-types`)

- Client enhancements: easier initialization and richer ergonomics

  - Added `WordpressClient.forSite` factory to initialize from a site root URL (auto-derives `/wp-json/wp/v2`).
  - Introduced convenience extensions for most interfaces (Posts, Pages, Media, Users, Categories, Tags, Comments, Blocks, Block Types, Templates, Template Parts, Template Revisions, Template Part Revisions, Navigations, Navigation Revisions, Navigation Autosaves, Menus, Menu Items, Menu Locations, Widgets, Sidebars, Widget Types, Post Types, Taxonomies, Post Statuses, Themes, Global Styles, Post Revisions, Page Revisions, Settings).
  - Implemented a raw request API on `WordpressClient` for custom endpoint calls.
  - Added `WordpressAuth` helpers for App Passwords and JWT (Useful/Basic) to simplify setup.
  - Exported new extensions via library exports; example app updated with composite ID samples.

- Parallel requests behavior: configurable error handling

  - Added `failOnError` (default: false) to `ParallelWordpress.list(...)`. When `false`, non-success pages contribute empty results; when `true`, the first non-success response throws `ParallelProcessingException`.

- Discovery and authorization robustness

  - Hardened `WordpressDiscovery.fromJson` to tolerate mixed JSON types (e.g., numeric or string `gmt_offset`; `site_icon`/`site_logo` as int or string) with safe defaults.
  - Updated classic Basic JWT flow to parse the top-level `token` correctly during authorization and simplified token validation.

- Docs & Wiki

  - Added GitHub wiki as a submodule under `/wiki` and started populating advanced docs; README updated with a concise Wiki section and links.

- Fluent queries and interface helpers (non‑breaking)

  - Added a discoverable fluent API via a `query` property on each interface:
    - Example: `client.posts.query.withPage(1).withPerPage(5).withSearch('hello').execute()`
    - No seed class required. The builder auto‑creates the correct request internally (e.g., `ListPostRequest`).
    - Advanced: access/modify the underlying seed via `configureSeed((seed) { ... })` or `seedRequest`.
  - Introduced a dedicated `extensions` property on interfaces to group simple convenience methods:
    - Example: `client.posts.extensions.getById(123)`, `findBySlug('hello-world')`, `listAll(perPage: 100)`
  - Base interface remains minimal and focused on CRUD via operation mixins; fluent and helpers are additive.
  - Note: Some auto‑seeded builders (e.g., revisions/navigation) use placeholder IDs; set them via `configureSeed` before `execute()`.

- New endpoint coverage

  - Pattern Directory Items (`/wp/v2/pattern-directory/patterns`) with fluent support via `client.patternDirectory.query.withSearch('hero').execute()`.

- Local dev and integration testing

  - Added Docker Compose stack (WordPress + MariaDB) and PowerShell helper scripts (`.scripts/wp-up.ps1`, `wp-down.ps1`, `wp-reset.ps1`).
  - Introduced an integration test harness that loads config from `test/test_local.json` (with `test_local.json.example` provided) or environment variables.
  - Wrote grouped integration tests covering posts CRUD (with faker data), comments, media, settings, blocks, search, revisions, templates, and template parts. Tests are tolerant of unauthenticated environments and no-op when missing local config.

- Misc & housekeeping
  - Version bumped to 9.0.0 in `README.md` and `pubspec.yaml`.
  - Minor refactors and stability improvements, including legacy tests and parallel pagination fixes.

## 8.6.0

- Add Global Styles support (interface + retrieve/update requests + response model)
- Themes: add is_block_theme, screenshot, theme_supports fields
- Me endpoint: send DELETE force/reassign via query; add rolesNames (role names array) with legacy roles fallback
- Templates & Template Parts: audit and confirm alignment with REST docs
- Navigation/Menus/Widgets: audit and minor compliance fix (widgets DELETE force as query param)

## 8.5.4

- Added support for creating media from bytes
- Updated documentation

## 8.5.3

- Fix invalid base url on web

## 8.5.2

- Fix versions

## 8.5.1

- Fix dio sendTimeout exception

## 8.5.0

- Added support for initializing the client without a base url.
  - Use the `WordpressClient.generic` constructor to initialize the client without a base url.
  - Use the `reconfigure` method to set the base url after initializing the client.
  - Failure to set the base url will throw an exception when making requests.
- Added `isAuthenticated` method to check if the current instance has a valid authentication.
  - Optionally, pass an instance of `IAuthorization` to check if the client is authenticated with the given authorization.
- 💥 Deprecated `reconfigureClient` method in favour of `reconfigure` method.

## 8.4.10

- Fix bug on clearing middleware list

## 8.4.9

- Downgrade meta package to match flutter meta version

## 8.4.8

- Bug fixes
- 💥 Deprecated `WordpressClient.initialize(...)` ctor and `initialize()` method
- Added `WordpressClient.fromDioInstance(...)` constructor

## 8.4.7

- Bug fixes
- Fix validations for entered `baseUrl`; Supporting sites with custom REST Api paths

## 8.4.6

- Bug fixes
- Added validations for entered `baseUrl`
- 💥 Renamed `executeGuarded` to `guardAsync` and added `guard` method

## 8.4.5

- Bug fixes

## 8.4.4

- Bug fixes

## 8.4.3

- New static method to check if a site is built using WordPress

## 8.4.2

- Bug fixes
- Added static methods to validate base URL and discover a website

## 8.4.1

- Introduce `ParallelWordpress` class to generate and execute parallel requests
- Bug fixes

## 8.4.0

- Added support for Middlewares
- 💥 Removed dependency on `synchronised` package

## 8.3.10

- Bug fixes

## 8.3.9

- Bug fixes
- Iterate over the raw response of the endpoint using [] operator

## 8.3.8

- Renamed retrive -> retrieve. Fix typo

## 8.3.7

- Support for raw requests
- Bug fixes

## 8.3.6

- Bug fixes on enum parsing

## 8.3.5

- Bug fixes on comment list request

## 8.3.4

- Media response model null exception when parsing if media details is empty

## 8.3.3

- Packages downgrade
  - collection 1.18.0 -> 1.17.2

## 8.3.2

- Packages downgrade
  - meta 1.11.0 -> 1.9.1

## 8.3.1

- Packages downgrade
  - test 1.24.8 -> 1.24.5
- Added avatar URLs model class for users response

## 8.3.0

- Supports Application Password endpoint
- Packages update

## 8.2.2

- Bug fixes

## 8.2.1

- Fixed exporting WordPressDiscovery class

## 8.2.0

- Added support for Pages endpoint

## 8.1.0

- Added ability to fetch and cache the discovery endpoint of WordPress REST API

## 8.0.11

- Added `extra` property to all request classes
- Added `addAllIfNotNull(...)` extension method

## 8.0.10

- `featured_media_src_url` key now decodes as expected
- Added `decodeByMultiKeys` method

## 8.0.9

- Added App Password support

## 8.0.8

- Integrated new lint rules and code refactors

## 8.0.7

- Bug fixes
- Introduced `RequestErrorType` for failure responses
- Introduced `mapGuarded(...)` and `executeGuarded(...)` methods
- Usual refactors and improvements

## 8.0.6

- Docs update

## 8.0.5

- Bug fixes and improvements

## 8.0.4

- Bug fixes and improvements

## 8.0.3

- Export response extensions

## 8.0.2

- Downgrade collection version

## 8.0.1

- Docs update

## 8.0.0

- 💥 Several major updates and changes

## 7.0.0

- 💥 Major changes (Please check our documentation for more details)

## 6.3.1

- Implemented search endpoint

## 6.3.0

- Major changes in the API

## 6.2.1-pre

- Misc changes

## 6.2.0-pre

- Refactoring, Request Synchronization, and Debug Mode

## 6.1.7-pre to 6.1.9-pre

- Refactoring & Bug fixes

## 6.1.6-pre

- Support 3xx series responses (Cached Response)

## 6.1.5-pre

- Added Post extension for Media and Author

## 6.1.3-pre & 6.1.4-pre

- Bug fixes

## 6.1.2-pre

- Version fix

## 6.1.1-pre

- Removed test package

## 6.1.0-pre

- Entire API changed
- Fluency maintained using Dart's cascading operator
- Performance and memory consumption improvements

## 5.4.3

- Total pages parsing fix

## 5.4.2

- Packages fix

## 5.4.1

- Null safety fix

## 5.4.0

- Packages update

## 5.3.1

- Response structure fix

## 5.3.0

- Bug fix

## 5.2.9

- Bug Fix

## 5.2.8

- Revert author meta & featured image removal

## 5.2.7

- Bug fix

## 5.2.6

- Experimental Request Caching system

## 5.2.5

- 💥 BREAKING CHANGE: Remove Author Meta & Featured Image URL Fields from Post response

## 5.2.4

- Remove unused package

## 5.2.3

- 💥 BREAKING CHANGE: Request API Change

## 5.1.1

- Formatting changes

## 5.1.0

- 💥 BREAKING CHANGE: Authorization API Change

## 5.0.4

- Fixed Authorization Bugs

## 4.0.0

- Initial version, created by Stagehand
