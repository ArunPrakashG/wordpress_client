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
    <b>A powerful and easy-to-use WordPress REST API client for Dart & Flutter.</b>
  </p>
</div>

## 🚀 Features

- 📦 API discovery support.
- ⏲️ Measures request completion time.
- 📝 Supports all CRUD operations.
- 🌐 Supports all common endpoints.
- 🎨 Custom Requests & Authorization systems.
- 🔐 3 Popular authorization methods.
- 📦 Third party Database integration.
- 🔧 Middlewares for request & response operations.
- 🎣 Events for preprocessing response.
- 🚀 Execute requests in Parallel.
- 🧠 Optional in-memory caching for GET requests.

## Future

If you find any functionality which you require is missing from the package and you are not able to work it out using built in options like raw requests etc, then please share the functionality in details as a comment here: https://github.com/ArunPrakashG/wordpress_client/discussions/55

## 📦 Installation

Add `wordpress_client` to your `pubspec.yaml`:

```dart
dependencies:
 wordpress_client: ^8.5.3
```

> 💡 Ensure you get the [latest version here](https://pub.dev/packages/wordpress_client).

Then run `flutter pub get` to install the package.

## 🔧 Usage

Import the package where you need:

```dart
import 'package:wordpress_client/wordpress_client.dart';
```

### **2. Initialization**

You can initialize `WordpressClient` in two methods:

- Default (Simple Method)
- Advanced (with Bootstrapper for additional configurations)

**Simple Method:**

```dart
final baseUrl = Uri.parse('https://example.com/wp-json/wp/v2');
final client = WordpressClient(baseUrl: baseUrl);
```

> 📘 Learn more about the [Advanced Method here](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage#-advanced-method).

### Enable caching via middleware (optional)

Enable a simple read-through/write-through cache for GET requests by adding the cache middleware:

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

Notes:

- Applies only to GET requests (list/retrieve/custom GET).
- Default store is in-memory. Provide your own by implementing `ICacheManager<WordpressRawResponse>`.
- On successful write operations (POST/PUT/PATCH/DELETE), the cache is cleared by default to avoid stale data (configurable via `clearOnWrite`).

### **3. Sending Requests**

Example to retrieve 20 recent WordPress posts in ascending order:

```dart
final request = ListPostRequest(
  page: 1,
  perPage: 20,
  order = Order.asc,
);

final response = await client.posts.list(request);

// Dart 3 style
switch (response) {
    case WordpressSuccessResponse():
      final data = response.data; // List<Post>
      break;
    case WordpressFailureResponse():
      final error = response.error; // WordpressError
      break;
}

// or
// using map method to handle both success and failure
final result = response.map(
    onSuccess: (response) {
      // response is a WordpressSuccessResponse<List<Post>>

      print(response.message);
      return response.data;
    },
    onFailure: (response) {
      // response is a WordpressFailureResponse
      print(response.error.toString());
      return <Post>[];
    },
);

// or
// you can cast to a state directly; this will throw an error if the response is of the wrong type
final result = response.asSuccess(); // or response.asFailure();
```

Refer to the [documentation](https://github.com/ArunPrakashG/wordpress_client/wiki/Usage) for more request examples.

## 🔒 Supported Authorization

### 1. **AppPasswordAuth** (Recommended)

Native to WordPress 5.6+, this uses Basic auth with an application-specific password. Simple and reliable for server-to-server and mobile apps. [Details](https://make.wordpress.org/core/2020/11/05/application-passwords-integration-guide/)

### 2. **BasicJwtAuth**

Developed by Enrique Chavez, it involves JSON Web Token (JWT) authentication where a token is issued and then used in subsequent requests. [Details](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/)

### 3. **UsefulJwtAuth**

JWT via the actively maintained Useful Team plugin. Supports token validation, refresh via cookies, and optional `device` binding for refresh rotation. We also auto-retry one request on 401 by attempting re-auth/refresh in-flight. [Plugin docs](https://github.com/usefulteam/jwt-auth)

Notes for JWT:

- You must install and configure the plugin on your WordPress site (set `JWT_AUTH_SECRET_KEY`, enable auth header handling).
- Access token is short-lived (default ~10 minutes); refresh token is provided as a cookie. This client captures cookies automatically and refreshes when needed.
- Optional: pass a `device` string to `UsefulJwtAuth` to scope refresh tokens per device.

> For custom authorization, check the [Authorization Wiki](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization).

## 📋 Supported REST Methods

Read = list and/or retrieve; some endpoints are custom actions and are marked under Read.

| Endpoint                 | Create | Read | Update | Delete |
| ------------------------ | :----: | :--: | :----: | :----: |
| Posts                    |   ✅   |  ✅  |   ✅   |   ✅   |
| Comments                 |   ✅   |  ✅  |   ✅   |   ✅   |
| Categories               |   ✅   |  ✅  |   ✅   |   ✅   |
| Tags                     |   ✅   |  ✅  |   ✅   |   ✅   |
| Users                    |   ✅   |  ✅  |   ✅   |   ✅   |
| Me                       |   ✅   |  ✅  |   ✅   |   ✅   |
| Media                    |   ✅   |  ✅  |   ✅   |   ✅   |
| Pages                    |   ✅   |  ✅  |   ✅   |   ✅   |
| Application Passwords    |   ✅   |  ✅  |   ✅   |   ✅   |
| Search                   |   -    |  ✅  |   -    |   -    |
| Post Revisions           |   -    |  ✅  |   -    |   -    |
| Page Revisions           |   -    |  ✅  |   -    |   -    |
| Taxonomies               |   -    |  ✅  |   -    |   -    |
| Post Types               |   -    |  ✅  |   -    |   -    |
| Post Statuses            |   -    |  ✅  |   -    |   -    |
| Settings                 |   -    |  ✅  |   ✅   |   -    |
| Themes                   |   -    |  ✅  |   -    |   -    |
| Blocks                   |   ✅   |  ✅  |   ✅   |   ✅   |
| Block Types              |   -    |  ✅  |   -    |   -    |
| Block Renderer (custom)  |   -    |  ✅  |   -    |   -    |
| Block Directory (search) |   -    |  ✅  |   -    |   -    |
| Templates                |   ✅   |  ✅  |   ✅   |   ✅   |
| Template Parts           |   ✅   |  ✅  |   ✅   |   ✅   |
| Template Revisions       |   -    |  ✅  |   -    |   ✅   |
| Template Part Revisions  |   -    |  ✅  |   -    |   ✅   |
| Navigations              |   ✅   |  ✅  |   ✅   |   ✅   |
| Navigation Revisions     |   -    |  ✅  |   -    |   ✅   |
| Navigation Autosaves     |   ✅   |  ✅  |   -    |   -    |
| Menus (Classic)          |   ✅   |  ✅  |   ✅   |   ✅   |
| Menu Items (Classic)     |   ✅   |  ✅  |   ✅   |   ✅   |
| Menu Locations (Classic) |   -    |  ✅  |   -    |   -    |
| Widgets                  |   ✅   |  ✅  |   ✅   |   ✅   |
| Sidebars                 |   -    |  ✅  |   ✅   |   -    |
| Widget Types             |   -    |  ✅  |   -    |   -    |

## 📢 Custom Response Types

Learn how to implement [Custom Requests here](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests).

### ✨ Quick examples for new endpoints

Below are a few concise examples to get you started with the newly added resources.

Navigation (Site Editor navigation):

```dart
// Create a navigation
final createdNav = await client.navigations.create(
  CreateNavigationRequest(
    title: 'Main Navigation',
    status: PostStatusType.publish,
  ),
);

// List navigations
final navs = await client.navigations.list(
  ListNavigationsRequest(perPage: 10),
);
```

Classic Menus and Menu Items:

```dart
// Create a classic menu
final menu = await client.menus.create(
  CreateNavMenuRequest(
    name: 'Header Menu',
    description: 'Top navigation',
  ),
);

// Add a menu item
final item = await client.menuItems.create(
  CreateNavMenuItemRequest(
    title: 'Home',
    url: Uri.parse('/'),
    menuId: menu.id,
    menuOrder: 1,
  ),
);
```

Widgets and Sidebars:

```dart
// Create a widget in a sidebar
final widget = await client.widgets.create(
  CreateWidgetRequest(
    idBase: 'text', // widget base id, e.g. core/text
    sidebar: 'sidebar-1',
    instance: {
      'title': 'About',
      'text': '<p>Hello from wordpress_client</p>',
    },
  ),
);

// Update a sidebar's widget order
final sidebar = await client.sidebars.update(
  UpdateSidebarRequest(
    id: 'sidebar-1',
    widgets: const ['search-1', 'recent-posts-1', 'text-2'],
  ),
);
```

## 🤝 Feedback & Contributing

- 🐛 For bugs or feature requests, use the [issue tracker][tracker].
- 💡 Contributions are always appreciated. PRs are welcome!

### Request consistency guard (for contributors)

To help keep the codebase consistent, we include a small script that:

- Verifies requests that accept `queryParameters` forward them in `build()`
- Heuristically flags missing `///` doc comments for public fields in `create_*`/`update_*` request classes

Run it locally before sending a PR:

```
dart run tool/check_requests_consistency.dart
```

Contributor checklist for request changes:

- [ ] If the constructor accepts `queryParameters`, ensure `build()` passes them to `WordpressRequest`
- [ ] Add concise `///` doc comments for all public fields in create/update request classes
- [ ] Keep changes additive and non-breaking
- [ ] Run `dart analyze` and the guard script; expect both to be clean

## 📄 License

This project is [MIT](https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE) licensed.

---

<div align="center">
  If you find this package helpful, consider supporting the development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/arunprakashg)

</div>

## 🔁 Automated Releases & Publishing

This repository includes GitHub Actions to automate releasing and publishing to pub.dev.

Setup required on pub.dev:

- Go to your package Admin page on pub.dev and enable “Publishing from GitHub Actions”.
- Set repository: `ArunPrakashG/wordpress_client`.
- Set tag pattern: `v{{version}}`.
- Optionally require a GitHub environment (e.g., `pub.dev`) for extra protection.

Workflows:

- `Release (bump and tag)` (manual): Bumps version in `pubspec.yaml`, commits, tags `vX.Y.Z`, and pushes.
  - Trigger from GitHub Actions using “Run workflow”. Input `bump` as `patch`/`minor`/`major` or explicit version like `8.5.5`.
- `Publish to pub.dev` (auto): Runs on tag push matching `v[0-9]+.[0-9]+.[0-9]+` and publishes using OIDC with the official reusable workflow.

Security tips:

- Use tag protection rules to restrict who can push tags matching `v*`.
- If you required an environment on pub.dev, set the same in the `publish.yml` job under `with: environment: pub.dev`.

[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues
