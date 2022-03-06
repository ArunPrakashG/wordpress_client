/// A library for interacting with Wordpress REST API with support for Authorization using JWT and Basic Auth.
///
/// All requests are created using a RequestBuilder class which is designed to generate requests in a fluent manner.
/// Responses can contain statistical data such as Time taken for the request to finish as [Duration], Any errors that might have occured, and the raw response from the server.
library wordpress_client;

// Authorization
export 'src/authorization/authorization_base.dart' show IAuthorization;
export 'src/authorization/authorization_builder.dart' show AuthorizationBuilder;
export 'src/authorization/authorization_methods/basic_auth.dart' show BasicAuth;
export 'src/authorization/authorization_methods/basic_jwt.dart'
    show BasicJwtAuth;
export 'src/authorization/authorization_methods/useful_jwt.dart'
    show UsefulJwtAuth;

// Requests
export 'src/interface/interface_base.dart';

// Operations
export 'src/operations/create.dart';
export 'src/operations/delete.dart';
export 'src/operations/update.dart';
export 'src/operations/list.dart';
export 'src/operations/retrieve.dart';
export 'src/operations/custom.dart';

// Enums
export 'src/enums.dart';

// Responses
export 'src/responses_export.dart';
export 'package:dio/src/dio_error.dart';
export 'package:dio/src/form_data.dart';
export 'package:dio/src/interceptors/log.dart';
export 'package:dio/src/multipart_file.dart';
export 'package:dio/src/cancel_token.dart';
export 'package:dio/src/dio_mixin.dart';

// Callback
export 'src/utilities/callback.dart';

// Core files
export 'src/wordpress_client_base.dart' show WordpressClient;
