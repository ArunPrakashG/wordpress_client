// ignore_for_file: constant_identifier_names

enum ErrorType {
  interfaceNotExist,
  interfaceAlreadyExist,
  requestFailedInternally,
  requestFailed,
  clientNotReady,
  authorizationFailed,
  bootstrapFailed,
  fileDoesntExist,
  interfaceDoNotExist,
  interfaceExist,
  interfaceNotInitialized,
  invalidInterface,
  discoveryPending,
  discoveryFailed,
  nullReference,
  requestUriParsingFailed,
}

enum RequestErrorType {
  noError,
  unknown,
  internalGenericError,
  authorizationModuleNotFound,
  authorizationFailedWithProvidedCredentials,
  connectionFailed,
  requestCancelled,
  invalidStatusCode,
  middlewareAborted,
  middlewareExecutionFailed,
}

enum SearchType {
  post,
  term,
  postFormat,
}

enum Status {
  open,
  closed,
}

enum CommentStatus {
  approve,
  approved,
  pending,
}

/// Different HTTP Methods which is supported by the client.
enum HttpMethod {
  /// Put Method
  put,

  /// Post Method
  post,

  /// Get Method
  get,

  /// Delete Method
  delete,

  /// Update Method
  update,

  /// Head Method
  head,

  /// Options Method
  options,

  /// Patch Method
  patch,

  /// Trace Method
  trace,
}

enum Order {
  asc,
  desc,
}

enum OrderBy {
  date,
  author,
  id,
  include,
  modified,
  parent,
  relevance,
  slug,
  include_slugs,
  title,
  email,
  url,
  name,
  registered_date,
  term_group,
  description,
  count,
}

enum RequestContext {
  view,
  embed,
  edit,
}

enum MediaFilterStatus {
  inherit,
}

enum TaxonomyRelation {
  and,
  or,
}

enum ContentStatus {
  publish,
  future,
  draft,
  pending,
  private,
}

enum PostFormat {
  standard,
  aside,
  chat,
  gallery,
  link,
  image,
  quote,
  status,
  video,
  audio,
}

enum AuthorizationType {
  basic_jwt,
  useful_jwt,
  basic,
}

enum Locale {
  en_US,
}

enum MediaType {
  image,
  video,
  text,
  application,
  audio,
}

ContentStatus getContentStatusFromValue(
  String? value, {
  ContentStatus defaultValue = ContentStatus.pending,
}) {
  if (value == null) {
    return defaultValue;
  }

  return ContentStatus.values
          .where((element) => element.name.toLowerCase() == value.toLowerCase())
          .firstOrNull ??
      defaultValue;
}

CommentStatus getCommentStatusFromValue(
  String? value, {
  CommentStatus defaultValue = CommentStatus.pending,
}) {
  if (value == null) {
    return defaultValue;
  }

  return CommentStatus.values
          .where((element) => element.name.toLowerCase() == value.toLowerCase())
          .firstOrNull ??
      defaultValue;
}

MediaFilterStatus getMediaFilterStatusFromValue(
  String? value, {
  MediaFilterStatus defaultValue = MediaFilterStatus.inherit,
}) {
  if (value == null) {
    return defaultValue;
  }

  return MediaFilterStatus.values
          .where((element) => element.name.toLowerCase() == value.toLowerCase())
          .firstOrNull ??
      defaultValue;
}

PostFormat getFormatFromValue(
  String? value, {
  PostFormat defaultValue = PostFormat.standard,
}) {
  if (value == null) {
    return defaultValue;
  }

  return PostFormat.values
          .where((e) => e.name.toLowerCase() == value.toLowerCase())
          .firstOrNull ??
      defaultValue;
}

Status getStatusFromValue(String? value, {Status defaultValue = Status.open}) {
  if (value == null || value.isEmpty) {
    return defaultValue;
  }

  return Status.values
          .where((element) => element.name.toLowerCase() == value.toLowerCase())
          .firstOrNull ??
      defaultValue;
}
