// ignore_for_file: constant_identifier_names

/// Represents various error types that can occur in the WordPress client.
enum ErrorType {
  /// Interface does not exist
  interfaceNotExist,

  /// Interface already exists
  interfaceAlreadyExist,

  /// Request failed internally
  requestFailedInternally,

  /// Request failed
  requestFailed,

  /// Client is not ready
  clientNotReady,

  /// Authorization failed
  authorizationFailed,

  /// Bootstrap process failed
  bootstrapFailed,

  /// File doesn't exist
  fileDoesntExist,

  /// Interface does not exist
  interfaceDoNotExist,

  /// Interface exists
  interfaceExist,

  /// Interface is not initialized
  interfaceNotInitialized,

  /// Invalid interface
  invalidInterface,

  /// Discovery is pending
  discoveryPending,

  /// Discovery failed
  discoveryFailed,

  /// Null reference encountered
  nullReference,

  /// Request URI parsing failed
  requestUriParsingFailed,
}

/// Represents specific error types that can occur during a request.
enum RequestErrorType {
  /// No error occurred
  noError,

  /// Unknown error
  unknown,

  /// Internal generic error
  internalGenericError,

  /// Authorization module not found
  authorizationModuleNotFound,

  /// Authorization failed with provided credentials
  authorizationFailedWithProvidedCredentials,

  /// Connection failed
  connectionFailed,

  /// Request was cancelled
  requestCancelled,

  /// Invalid status code received
  invalidStatusCode,

  /// Middleware aborted the request
  middlewareAborted,

  /// Middleware execution failed
  middlewareExecutionFailed,
}

/// Represents different types of search operations.
enum SearchType {
  /// Search for posts
  post,

  /// Search for terms
  term,

  /// Search for post formats
  postFormat,
}

/// Represents the status of an item (e.g., a post or comment).
enum Status {
  /// Item is open
  open,

  /// Item is closed
  closed,
}

/// Represents the status of a comment.
enum CommentStatus {
  /// Comment is to be approved
  approve,

  /// Comment is approved
  approved,

  /// Comment is pending approval
  pending,
}

/// Represents different HTTP methods supported by the client.
enum HttpMethod {
  /// PUT method
  put,

  /// POST method
  post,

  /// GET method
  get,

  /// DELETE method
  delete,

  /// UPDATE method
  update,

  /// HEAD method
  head,

  /// OPTIONS method
  options,

  /// PATCH method
  patch,

  /// TRACE method
  trace,
}

/// Represents the order of results (ascending or descending).
enum Order {
  /// Ascending order
  asc,

  /// Descending order
  desc,
}

/// Represents different criteria for ordering results.
enum OrderBy {
  /// Order by date
  date,

  /// Order by author
  author,

  /// Order by ID
  id,

  /// Order by included items
  include,

  /// Order by modification date
  modified,

  /// Order by parent
  parent,

  /// Order by relevance
  relevance,

  /// Order by slug
  slug,

  /// Order by included slugs
  include_slugs,

  /// Order by title
  title,

  /// Order by email
  email,

  /// Order by URL
  url,

  /// Order by name
  name,

  /// Order by registration date
  registered_date,

  /// Order by term group
  term_group,

  /// Order by description
  description,

  /// Order by count
  count,
}

/// Represents different contexts for a request.
enum RequestContext {
  /// View context
  view,

  /// Embed context
  embed,

  /// Edit context
  edit,
}

/// Represents the status for media filtering.
enum MediaFilterStatus {
  /// Inherit status from parent
  inherit,
}

/// Represents the relation between taxonomy terms.
enum TaxonomyRelation {
  /// AND relation
  and,

  /// OR relation
  or,
}

/// Represents different statuses for content (e.g., posts).
enum ContentStatus {
  /// Published content
  publish,

  /// Scheduled content
  future,

  /// Draft content
  draft,

  /// Pending content
  pending,

  /// Private content
  private,
}

/// Represents different post formats.
enum PostFormat {
  /// Standard post format
  standard,

  /// Aside post format
  aside,

  /// Chat post format
  chat,

  /// Gallery post format
  gallery,

  /// Link post format
  link,

  /// Image post format
  image,

  /// Quote post format
  quote,

  /// Status post format
  status,

  /// Video post format
  video,

  /// Audio post format
  audio,
}

/// Represents different types of authorization.
enum AuthorizationType {
  /// Basic JWT authorization
  basic_jwt,

  /// Useful JWT authorization
  useful_jwt,

  /// Basic authorization
  basic,
}

/// Represents different locales.
enum Locale {
  /// English (United States)
  en_US,
}

/// Represents different types of media.
enum MediaType {
  /// Image media type
  image,

  /// Video media type
  video,

  /// Text media type
  text,

  /// Application media type
  application,

  /// Audio media type
  audio,
}

/// Converts a string value to a [ContentStatus] enum.
///
/// If the value is null or doesn't match any enum value, returns [defaultValue].
ContentStatus getContentStatusFromValue(
  String? value, {
  ContentStatus defaultValue = ContentStatus.pending,
}) {
  if (value == null) {
    return defaultValue;
  }

  return ContentStatus.values.firstWhere(
    (element) => element.name.toLowerCase() == value.toLowerCase(),
    orElse: () => defaultValue,
  );
}

/// Converts a string value to a [CommentStatus] enum.
///
/// If the value is null or doesn't match any enum value, returns [defaultValue].
CommentStatus getCommentStatusFromValue(
  String? value, {
  CommentStatus defaultValue = CommentStatus.pending,
}) {
  if (value == null) {
    return defaultValue;
  }

  return CommentStatus.values.firstWhere(
    (element) => element.name.toLowerCase() == value.toLowerCase(),
    orElse: () => defaultValue,
  );
}

/// Converts a string value to a [MediaFilterStatus] enum.
///
/// If the value is null or doesn't match any enum value, returns [defaultValue].
MediaFilterStatus getMediaFilterStatusFromValue(
  String? value, {
  MediaFilterStatus defaultValue = MediaFilterStatus.inherit,
}) {
  if (value == null) {
    return defaultValue;
  }

  return MediaFilterStatus.values.firstWhere(
    (element) => element.name.toLowerCase() == value.toLowerCase(),
    orElse: () => defaultValue,
  );
}

/// Converts a string value to a [PostFormat] enum.
///
/// If the value is null or doesn't match any enum value, returns [defaultValue].
PostFormat getFormatFromValue(
  String? value, {
  PostFormat defaultValue = PostFormat.standard,
}) {
  if (value == null) {
    return defaultValue;
  }

  return PostFormat.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => defaultValue,
  );
}

/// Converts a string value to a [Status] enum.
///
/// If the value is null, empty, or doesn't match any enum value, returns [defaultValue].
Status getStatusFromValue(String? value, {Status defaultValue = Status.open}) {
  if (value == null || value.isEmpty) {
    return defaultValue;
  }

  return Status.values.firstWhere(
    (element) => element.name.toLowerCase() == value.toLowerCase(),
    orElse: () => defaultValue,
  );
}
