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

### 1. **AppPasswordAuth**

By the WordPress Team, this method uses basic HTTP authentication where credentials are passed with every request. [Details](https://make.wordpress.org/core/2020/11/05/application-passwords-integration-guide/)

### 2. **BasicJwtAuth**

Developed by Enrique Chavez, it involves JSON Web Token (JWT) authentication where a token is issued and then used in subsequent requests. [Details](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/)

### 3. **UsefulJwtAuth**

By Useful Team, this is another implementation using JWT for authentication purposes. [Details](https://github.com/usefulteam/jwt-auth)

> For custom authorization, check the [Authorization Wiki](https://github.com/ArunPrakashG/wordpress_client/wiki/Authorization).

## 📋 Supported REST Methods

| Endpoint              | Create | Read | Update | Delete |
| --------------------- | :----: | :--: | :----: | :----: |
| Posts                 |   ✅   |  ✅  |   ✅   |   ✅   |
| Comments              |   ✅   |  ✅  |   ✅   |   ✅   |
| Categories            |   ✅   |  ✅  |   ✅   |   ✅   |
| Tags                  |   ✅   |  ✅  |   ✅   |   ✅   |
| Users                 |   ✅   |  ✅  |   ✅   |   ✅   |
| Me                    |   ✅   |  ✅  |   ✅   |   ✅   |
| Media                 |   ✅   |  ✅  |   ✅   |   ✅   |
| Pages                 |   ✅   |  ✅  |   ✅   |   ✅   |
| Application Passwords |   ✅   |  ✅  |   ✅   |   ✅   |
| Search                |   -    |  ✅  |   -    |   -    |
| Post Revisions        |   ❌   |  ❌  |   ❌   |   ❌   |
| Taxonomies            |   ❌   |  ❌  |   ❌   |   ❌   |
| Post Types            |   ❌   |  ❌  |   ❌   |   ❌   |
| Post Statuses         |   ❌   |  ❌  |   ❌   |   ❌   |
| Settings              |   ❌   |  ❌  |   ❌   |   ❌   |

## 📢 Custom Response Types

Learn how to implement [Custom Requests here](https://github.com/ArunPrakashG/wordpress_client/wiki/Using-Custom-Requests).

## 🤝 Feedback & Contributing

- 🐛 For bugs or feature requests, use the [issue tracker][tracker].
- 💡 Contributions are always appreciated. PRs are welcome!

## 📄 License

This project is [MIT](https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE) licensed.

---

<div align="center">
  If you find this package helpful, consider supporting the development:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/arunprakashg)

</div>

[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues

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
