<div align="center">
  <h1>wordpress_client</h1>

  <p align="center">
    <img src="https://img.shields.io/pub/v/wordpress_client?color=blueviolet" alt="Pub Version" />  <br>
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white" alt="WordPress" />
    <br>
    Easily interact with the Wordpress REST API. Get support for most common endpoints & CRUD operations.
</p>
</div>

## 🚀 Features

- 🛡️ 3 Popular authorization methods.
- 🎣 Events for preprocessing response operations.
- ⏲️ Measures request completion time.
- 🎨 Custom Requests & Authorization systems.
- 🔄 Request Synchronization.
- ✨ And much more!

## 📖 How to Use

### **1. Setup**

Add `wordpress_client` in your `pubspec.yaml`:

```dart
dependencies:
 wordpress_client: ^8.0.7
```

> 💡 Ensure you get the [latest version here](https://pub.dev/packages/wordpress_client).

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

client.initialize();
```

> 📘 Learn more about the [Advanced Method here](https://github.com/ArunPrakashG/wordpress_client/wiki/%F0%9F%93%9A-Usage#-advanced-method).

### **3. Sending Requests**

Example to retrieve 20 recent WordPress posts in ascending order:

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

Refer to the [documentation](https://github.com/ArunPrakashG/wordpress_client/wiki/%F0%9F%93%9A-Usage) for more request examples.

## 🔒 Supported Authorization

### 1. **AppPasswordAuth**

By the WordPress Team, this method uses basic HTTP authentication where credentials are passed with every request. [Details](https://make.wordpress.org/core/2020/11/05/application-passwords-integration-guide/)

### 2. **BasicJwtAuth**

Developed by Enrique Chavez, it involves JSON Web Token (JWT) authentication where a token is issued and then used in subsequent requests. [Details](https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/)

### 3. **UsefulJwtAuth**

By Useful Team, this is another implementation using JWT for authentication purposes. [Details](https://github.com/usefulteam/jwt-auth)

> For custom authorization, check the [Authorization Wiki](https://github.com/ArunPrakashG/wordpress_client/wiki/%F0%9F%9B%A1-Authorization).

## 📋 Supported REST Methods

| Endpoint       | Create | Read | Update | Delete |
| -------------- | :----: | :--: | :----: | :----: |
| Posts          |   ✅   |  ✅  |   ✅   |   ✅   |
| Comments       |   ✅   |  ✅  |   ✅   |   ✅   |
| Categories     |   ✅   |  ✅  |   ✅   |   ✅   |
| Tags           |   ✅   |  ✅  |   ✅   |   ✅   |
| Users          |   ✅   |  ✅  |   ✅   |   ✅   |
| Me             |   ✅   |  ✅  |   ✅   |   ✅   |
| Media          |   ✅   |  ✅  |   ✅   |   ✅   |
| Search         |   ❌   |  ✅  |   ❌   |   ❌   |
| Post Revisions |   ❌   |  ❌  |   ❌   |   ❌   |
| Pages          |   ❌   |  ❌  |   ❌   |   ❌   |
| Taxonomies     |   ❌   |  ❌  |   ❌   |   ❌   |
| Post Types     |   ❌   |  ❌  |   ❌   |   ❌   |
| Post Statuses  |   ❌   |  ❌  |   ❌   |   ❌   |
| Settings       |   ❌   |  ❌  |   ❌   |   ❌   |

## 📢 Custom Response Types

Learn how to implement [Custom Requests here](https://github.com/ArunPrakashG/wordpress_client/wiki/%F0%9F%9A%80-Using-Custom-Requests).

## 📣 Feedback

- 🐛 For bugs or feature requests, use the [issue tracker][tracker].
- 💡 Contributions are always appreciated. PRs are welcome!

## 📜 License

Licensed under [MIT](https://github.com/ArunPrakashG/wordpress_client/blob/master/LICENSE).

[tracker]: https://github.com/ArunPrakashG/wordpress_client/issues

---

<div align="center">
    
Support Me:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/arunprakashg)

</div>
