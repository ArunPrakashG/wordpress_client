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
