/// A library for interacting with Wordpress REST API with support for Authorization using JWT and Basic Auth.
///
/// All requests are created using a RequestBuilder class which is designed to generate requests in a fluent manner.
/// Responses can contain statistical data such as Time taken for the request to finish as [Duration], Any errors that might have occured, and the raw response from the server.
library wordpress_client;

export 'package:dio/dio.dart';

export 'src/authorization/authorization_export.dart';
export 'src/library_exports.dart';
export 'src/operations/operations_export.dart';
export 'src/requests/requests_export.dart';
export 'src/responses/responses_export.dart';
export 'src/utilities/utility_export.dart';
export 'src/wordpress_client_base.dart';
