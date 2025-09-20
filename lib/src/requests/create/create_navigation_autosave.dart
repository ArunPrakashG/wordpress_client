import '../../../wordpress_client.dart';
// no-op

/// Create a Navigation Autosave (POST /wp/v2/navigation/<id>/autosaves)
final class CreateNavigationAutosaveRequest extends IRequest {
  CreateNavigationAutosaveRequest({
    required this.parent,
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
    super.requireAuth,
    super.sendTimeout,
    super.validator,
    super.extra,
    super.headers,
    super.queryParameters,
  });

  /// The parent Navigation post ID.
  final int parent;

  /// The date the post was published, in the site's timezone.
  final DateTime? date;

  /// The date the post was published, as GMT.
  final DateTime? dateGmt;

  /// An alphanumeric identifier for the post unique to its type.
  final String? slug;

  /// A named status for the post.
  final ContentStatus? status;

  /// A password to protect access to the content and excerpt.
  final String? password;

  /// The title for the post.
  final String? title;

  /// The content for the post.
  final String? content;

  /// The theme file to use to display the post.
  final String? template;

  @override
  WordpressRequest build(Uri baseUrl) {
    final data = <String, dynamic>{
      if (date != null) 'date': date!.toIso8601String(),
      if (dateGmt != null) 'date_gmt': dateGmt!.toIso8601String(),
      if (slug != null) 'slug': slug,
      if (status != null) 'status': status!.name,
      if (password != null) 'password': password,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (template != null) 'template': template,
    }..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('navigation/$parent/autosaves'),
      body: data,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
