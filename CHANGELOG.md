## 🎉 4.0.0

- 🚀 Initial version, created by Stagehand

## 🐛 5.0.4

- 🔒 Fixed Authorization Bugs

## 💥 5.1.0

- 🔄 BREAKING CHANGE: Authorization API Change.

## 🛠 5.1.1

- 📝 Formatting changes.

## 💥 5.2.3

- 🔄 BREAKING CHANGE: Request API Change.

## 🛠 5.2.4

- 🗑️ Remove unused package

## 💥 5.2.5

- 🔄 BREAKING CHANGE: Remove Author Meta & Featured Image Url Fields from Post response.

## 🧪 5.2.6

- ⚙️ Experimental Request Caching system

## 🐛 5.2.7

- 🩹 Bug fix

## 🛠 5.2.8

- 🔄 Revert author meta & featured image removal

## 🐛 5.2.9

- 🩹 Bug Fix

## 🐛 5.3.0

- 🩹 Bug fix

## 🛠 5.3.1

- 📜 Response structure fix

## 🛠 5.4.0

- 📦 Packages update

## 🛠 5.4.1

- 🔒 Null safety fix

## 🛠 5.4.2

- 📦 Packages fix

## 🛠 5.4.3

- 📜 Total pages parsing fix

## 🎉 6.1.0-pre

- 🚀 Entire API changed. (Please bear with us!)
- 🌊 Fluency is maintained by using Dart's cascading operator.
- ⚡ Performance and memory consumption improvements.

## 🛠 6.1.1-pre

- 🗑️ Removed test package

## 🛠 6.1.2-pre

- 📌 Version fix

## 🐛 6.1.3-pre & 6.1.4-pre

- 🩹 Bug fixes

## 🎉 6.1.5-pre

- ➕ Added Post extension for Media and Author

## 🛠 6.1.6-pre

- 🔗 Support 3xx series responses (Cached Response)

## 🛠 6.1.7-pre to 6.1.9-pre

- 🔧 Refactoring & 🩹 Bug fixes

## 🎉 6.2.0-pre

- 🔧 Refactoring, 🔄 Request Synchronization, and 🐛 Debug Mode

## 🛠 6.2.1-pre

- 🧪 Misc changes

## 🎉 6.3.0

- 🚀 Major changes in the API. (Please check our wiki for setup and usage)

## 🎉 6.3.1

- 🔍 Implemented search endpoint

## 🐛 6.3.4

- 🩹 Bug fix with media endpoint

## 🎉 7.0.0

- 💥 Major changes (Please check our documentation for more details)

## 🎉 8.0.0

- 💥 Several major updates and changes. (Please refer to our wiki for setup and usage)

## 📖 8.0.1

- 📚 Docs update

## 🛠 8.0.2

- 🔽 Downgrade collection version

## 🎉 8.0.3

- 📤 Export response extensions

## 🐛 8.0.4 & 8.0.5

- 🩹 Bug fixes and improvements

## 📖 8.0.6

- 📚 Docs update

## 📖 8.0.7

- 🐛 Bug fixes
- ➕ Introduced `RequestErrorType` for failure responses and optional `exception` & `stackTrace` properties
- ➕ Introduced `mapGuarded(...)` method to safely map a list of objects
- ➕ Introduced `executeGuarded(...)` method to safely execute a function
- 🔧 Usual amounts of refactors and improvements

## 📖 8.0.8

- 🔧 Integrated new lint rules and code refactors

## 📖 8.0.9

- ➕ Added App Password support

## 📖 8.0.10

- 🛠 `featured_media_src_url` key now decodes as expected
- ➕ Added a new `decodeByMultiKeys` method to decode a value from JSON by matching aganist multiple keys. Any of the key matchs, the value is returned

## 📖 8.0.11

- ➕ Added `extra` property to all request classes. Now you can append (or override) custom fields into the request.
- ➕ Added `addAllIfNotNull(...)` extension method to append valid key-values (not null) to existing map from another map.

## 🎉 8.1.0

- 🎉 Added the ability to fetch the discovery endpoint of Wordpress REST API and cache the response.
  - This allows to access the site's identity details such as description and logo url, along with all the available endpoints and other details.

## 🎉 8.2.0

- 🎉 Added support for Pages endpoint

## 🛠 8.2.1

- 🛠 Fixed exporting WordpressDiscovery class.

## 🛠 8.2.2

- 🛠 Bug fixes

## 🎉 8.3.0

- 🎉 Supports Application Password endpoint
- Packages update
  - dio 5.3.2 -> 5.3.3
  - collection 1.17.1 -> 1.18.0
  - meta 1.9.1 -> 1.11.0
  - test 1.24.5 -> 1.24.8

## 🐛 8.3.1

- Packages downgrade
  - test 1.24.8 -> 1.24.5
- Added avatar urls model class for users response

## 🐛 8.3.2

- Packages downgrade

  - meta 1.11.0 -> 1.9.1

## 🐛 8.3.3

- Packages downgrade
  - collection 1.18.0 -> 1.17.2

## 🐛 8.3.4

- Media response model null exception when parsing if media details is empty. (while using embed=true)

## 🐛 8.3.5

- 🩹 Bug fixes on comment list request.

## 🐛 8.3.6

- 🩹 Bug fixes on enum parsing.

## 🐛 8.3.7

- 🎉 Support for raw requests
  - Allows you to send requests but skip the parsing process. You can parse the response manually.
  - This allows to integrate the package along with other database packages such as drift, hive etc by allowing you to create a custom model class and integrate for the response.
- 🛠 Bug fixes

## 🐛 8.3.8

- 🐛 Renamed retrive -> retrieve. Fix the typo

## 🐛 8.3.9

- 🩹 Bug fixes
- 🎉 Iterate over the raw response of the endpoint from the final success or failure response model using [] operator.

## 🐛 8.3.10

- 🩹 Bug fixes

## 🎉 8.4.0

- 🎉 Added support for Middlewares!
  - You can now create custom middlewares to intercept the request and response.
  - The middleware can be used to modify the request, response or abort the process entirely by directly throwing an exception in their processing block.
  - You can create multiple middlewares and add them to the client.
  - The middlewares are executed in the order they are added to the client.
  - Added `DelegatedMiddleware` if you do not wish to create a separate class for the middleware but just need to modify the request or response.
- 💥 Removed dependency on `synchronised` package.
  - This package was used to synchronise the request and response processing. This now needs to be handled by the user itself.
  - it didn't make sense to restrict the requesting processing inside the library itself.

## 🐛 8.4.1

- 🎉 Introduce `ParallelWordpress` class to generate requests and execute them in parallel, at the same time receive responses sorted using their page number.
- 🛠 Bug fixes

## 🐛 8.4.2

- 🩹 Bug fixes
- 🎉 Added static methods to validate base url and to discovery a website.

## 🐛 8.4.3

- 🎉 New static method to check if a site is built using wordpress.

## 🐛 8.4.4

- 🩹 Bug fixes

## 🐛 8.4.5

- 🩹 Bug fixes

## 🐛 8.4.6

- 🩹 Bug fixes
- 🛠 Added validations for entered `baseUrl`.
- 💥Renamed `executeGuarded` to `guardAsync` and added a new `guard` method to guard synchronous functions.

## 🐛 8.4.7

- 🩹 Bug fixes
- 🛠 Fix validations for entered `baseUrl`; Supporting sites with custom REST Api paths

## 🐛 8.4.8

- 🩹 Bug fixes
- 💥 Deprecated `WordpressClient.initialize(...)` ctor and `initialize()` method.
  - Use `WordpressClient(baseUrl: 'https://example.com')` instead. This will automatically initialize the client.
- 🎉 Added `WordpressClient.fromDioInstance(...)` constructor to allow developers to pass a custom `Dio` instance to be used inside the client.
  - Note that, the `BaseOptions` in this custom dio instance will be overwritten by the client's default options and those which are required by the libraries requests.

## Legend

- 🎉 New features or major changes
- 🐛 Bug fixes
- 🛠 Minor fixes or tweaks
- 💥 Breaking changes
- 🔄 Changes that revert or modify previous functionality
- 📦 Package updates
- 🔒 Security updates
- 📝 Documentation or formatting updates
- 🧪 Experimental features
- ⚙️ System or backend changes
- 🗑️ Removals
- 🔧 Refactoring
- 📚 Documentation updates
- 🔍 New search features or updates
- 📤 Exporting features or updates
- 🔽 Downgrades or rollbacks
- 📌 Versioning fixes or updates
- 🌊 Flow or fluency updates
- ⚡ Performance improvements
- 📜 Parsing or data structure changes
- ➕ Additions of new functionalities
- 🔗 Linking or response changes
