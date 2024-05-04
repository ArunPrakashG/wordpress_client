<div align="center">
  <h1>WordPress Client</h1>

  <p align="center">
    <a href="https://pub.dev/packages/wordpress_client"> 
      <img src="https://img.shields.io/pub/v/wordpress_client?color=blueviolet" alt="Pub Version"/> 
    </a> 
    <br>
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white" alt="WordPress" />
    <br>
    <b>A powerful and easy-to-use WordPress REST API client for Dart & Flutter.
    </b>
</p>
</div>

## ✨ Features

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

## 📖 How to Use

### **1. Setup**

Add `wordpress_client` in your `pubspec.yaml`:

```dart
dependencies:
 wordpress_client: ^8.4.5
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
// or
// final client = WordpressClient.initialize(baseUrl: baseUrl);
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
