enum Status { OPEN, CLOSED }
enum HttpMethod { PUT, POST, GET, DELETE, UPDATE, HEAD, OPTIONS, PATCH, TRACE }
enum FilterOrder { ASCENDING, DESCENDING }
enum FilterPostSortOrder { DATE, AUTHOR, ID, INCLUDE, MODIFIED, PARENT, RELEVANCE, SLUG, INCLUDESLUGS, TITLE, EMAIL, URL, NAME }
enum FilterUserSortOrder { ID, INCLUDE, NAME, REGISTERED_DATE, SLUG, INCLUDE_SLUGS, EMAIL, URL }
enum FilterScope { VIEW, EMBED, EDIT }
enum TaxonomyRelation { AND, OR }
enum ContentStatus { PUBLISH, FUTURE, DRAFT, PENDING, PRIVATE }
enum PostAvailabilityStatus { PUBLISHED, DRAFT, TRASH }
enum PostFormat { STANDARD, ASIDE, CHAT, GALLERY, LINK, IMAGE, QUOTE, STATUS, VIDEO, AUDIO }
enum AuthorizationType { JWT, BASIC }

extension ParseToString on HttpMethod {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

ContentStatus getContentStatusFromValue(String value) {
  if (value == null) {
    return ContentStatus.PENDING;
  }

  return ContentStatus.values.where((element) => element.toString().split('.').last.toLowerCase() == value.toLowerCase()).first;
}

PostFormat getFormatFromValue(String value) {
  if (value == null) {
    return PostFormat.STANDARD;
  }

  return PostFormat.values.where((element) => element.toString().split('.').last.toLowerCase() == value.toLowerCase()).first;
}

Status getStatusFromValue(String value) {
  if (value == null) {
    return Status.OPEN;
  }

  return Status.values.where((element) => element.toString().split('.').last.toLowerCase() == value.toLowerCase()).first;
}
