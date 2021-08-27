/// A library for interacting with Wordpress REST API with support for Authorization using JWT and Basic Auth.
///
/// All requests are created using a RequestBuilder class which is designed to generate requests in a fluent manner.
/// Responses can contain statistical data such as Time taken for the request to finish as [Duration], Any errors that might have occured, and the raw response from the server.
library wordpress_client;

// Authorization
export 'src/authorization/authorization_base.dart' show IAuthorization;
export 'src/authorization/authorization_builder.dart' show AuthorizationBuilder;
export 'src/authorization/authorization_methods/basic_auth.dart' show BasicAuth;
export 'src/authorization/authorization_methods/basic_jwt.dart' show BasicJwtAuth;
export 'src/authorization/authorization_methods/useful_jwt.dart' show UsefulJwtAuth;

// Requests
export 'src/builders/request.dart';
export 'src/interface/interface_base.dart';
export 'src/builders/request_builder_base.dart';

// Operations
export 'src/operations/create.dart';
export 'src/operations/delete.dart';
export 'src/operations/update.dart';
export 'src/operations/list.dart';
export 'src/operations/retrive.dart';

// Enums
export 'src/enums.dart';

// Responses
export 'src/responses_import.dart';
export 'package:dio/src/cancel_token.dart';
export 'src/utilities/pair.dart';

// Callback
export 'src/utilities/callback.dart';
export 'src/utilities/serializable_instance.dart';

// Core files
export 'src/wordpress_client_base.dart' show WordpressClient;
export 'src/internal_requester.dart' show InternalRequester;
