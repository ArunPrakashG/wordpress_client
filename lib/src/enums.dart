enum Taxonomy { CATEGORY, POST_TAG }
enum Name { WP }
enum Href { HTTPS_API_W_ORG_REL }
enum StatusEnum { PUBLISH }
enum PostType { POST }
enum PostFormat { STANDARD, AUDIO, VIDEO }
enum Status { OPEN, CLOSED }
enum HttpMethod { PUT, POST, GET, DELETE, UPDATE, HEAD, OPTIONS, PATCH, TRACE }

extension ParseToString on HttpMethod {
  String toShortString() {
    // ignore: unnecessary_this
    return this.toString().split('.').last;
  }
}
