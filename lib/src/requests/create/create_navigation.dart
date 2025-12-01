import '../../../wordpress_client.dart';
// no-op

/// Create a Navigation (POST /wp/v2/navigation)
/// Fields: date, date_gmt, slug, status, password, title, content, template
final class CreateNavigationRequest extends IRequest {
  CreateNavigationRequest({
    this.date,
    this.dateGmt,
    this.slug,
    this.status,
    this.password,
    this.title,
    this.content,
    this.template,
    super.cancelToken,
    super.authorization,
    super.events,
    super.receiveTimeout,
    super.requireAuth = true,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// Post publish date in site timezone.
  final DateTime? date;

  /// Post publish date in GMT.
  final DateTime? dateGmt;

  /// An alphanumeric identifier for the navigation post unique to its type.
  final String? slug;

  /// Status of the object (publish, draft, pending, private).
  final ContentStatus? status;

  /// A password to protect access to the content.
  final String? password;

  /// The title for the object.
  final String? title;

  /// The content for the object.
  final String? content;

  /// The theme file to use to display the object.
  final String? template;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{
      if (date != null) 'date': date!.toIso8601String(),
      if (dateGmt != null) 'date_gmt': dateGmt!.toIso8601String(),
      if (slug != null) 'slug': slug,
      if (status != null) 'status': status!.name,
      if (password != null) 'password': password,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (template != null) 'template': template,
    }..addAllIfNotNull(extra);

    final query = <String, dynamic>{}..addAllIfNotNull(queryParameters);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('navigation'),
      body: body,
      queryParameters: query,
      headers: headers,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      requireAuth: requireAuth,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
