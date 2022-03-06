// ignore_for_file: constant_identifier_names

enum Status {
  open,
  closed,
}

enum CommentStatus {
  approved,
  pending,
}

enum HttpMethod {
  put,
  post,
  get,
  delete,
  update,
  head,
  options,
  patch,
  trace,
}

enum FilterOrder {
  ascending,
  descending,
}

enum FilterPostSortOrder {
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
}

enum FilterUserSortOrder {
  id,
  include,
  name,
  registered_date,
  slug,
  include_slugs,
  email,
  url,
}
enum FilterContext {
  view,
  embed,
  edit,
}

enum FilterCategoryTagSortOrder {
  id,
  include,
  name,
  slug,
  include_slugs,
  term_group,
  description,
  count,
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

enum PostAvailabilityStatus {
  published,
  draft,
  trash,
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

enum FilterMediaType {
  image,
  video,
  text,
  application,
  audio,
}

ContentStatus getContentStatusFromValue(String? value) {
  if (value == null) {
    return ContentStatus.pending;
  }

  return ContentStatus.values
      .where((element) =>
          element.toString().split('.').last.toLowerCase() ==
          value.toLowerCase())
      .first;
}

CommentStatus getCommentStatusFromValue(String? value) {
  if (value == null) {
    return CommentStatus.pending;
  }

  return CommentStatus.values
      .where((element) =>
          element.toString().split('.').last.toLowerCase() ==
          value.toLowerCase())
      .first;
}

MediaFilterStatus getMediaFilterStatusFromValue(String? value) {
  if (value == null) {
    return MediaFilterStatus.inherit;
  }

  return MediaFilterStatus.values
      .where((element) =>
          element.toString().split('.').last.toLowerCase() ==
          value.toLowerCase())
      .first;
}

PostFormat getFormatFromValue(String? value) {
  if (value == null) {
    return PostFormat.standard;
  }

  return PostFormat.values
      .where((element) =>
          element.toString().split('.').last.toLowerCase() ==
          value.toLowerCase())
      .first;
}

Status getStatusFromValue(String? value) {
  if (value == null) {
    return Status.open;
  }

  return Status.values
      .where((element) =>
          element.toString().split('.').last.toLowerCase() ==
          value.toLowerCase())
      .first;
}
