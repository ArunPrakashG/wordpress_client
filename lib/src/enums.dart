enum Taxonomy { CATEGORY, POST_TAG }
enum Name { WP }
enum Href { HTTPS_API_W_ORG_REL }
enum PostType { POST }
enum Status { OPEN, CLOSED }
enum HttpMethod { PUT, POST, GET, DELETE, UPDATE, HEAD, OPTIONS, PATCH, TRACE }
enum FilterOrder { ASCENDING, DESCENDING }
enum FilterSortOrder { DATE, AUTHOR, ID, INCLUDE, MODIFIED, PARENT, RELEVANCE, SLUG, INCLUDESLUGS, TITLE, EMAIL, URL, NAME }
enum FilterScope { VIEW, EMBED, EDIT }
enum TaxonomyRelation { AND, OR }
enum CommentStatusValue { OPEN, CLOSED }
enum PostStatus { PUBLISH, FUTURE, DRAFT, PENDING, PRIVATE }
enum PostAvailabilityStatus { PUBLISHED, DRAFT, TRASH }
enum PostFormat { STANDARD, ASIDE, CHAT, GALLERY, LINK, IMAGE, QUOTE, STATUS, VIDEO, AUDIO }

extension ParseToString on HttpMethod {
  String toShortString() {
    // ignore: unnecessary_this
    return this.toString().split('.').last;
  }
}
