import '../../../wordpress_client.dart';
// no-op

/// Update a Navigation (POST /wp/v2/navigation/<id>)
final class UpdateNavigationRequest extends IRequest {
  UpdateNavigationRequest({
    required this.id,
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

  /// Numeric navigation post ID to update.
  final int id;
  /// The date of the navigation.
  final DateTime? date;
  /// The date in GMT.
  final DateTime? dateGmt;
  /// Unique slug.
  final String? slug;
  /// Post status.
  final ContentStatus? status;
  /// Password for protected content.
  final String? password;
  /// Title of the navigation.
  final String? title;
  /// Content (serialized blocks).
  final String? content;
  /// Template file to use.
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

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('navigation/$id'),
      body: body,
      queryParameters: queryParameters,
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
