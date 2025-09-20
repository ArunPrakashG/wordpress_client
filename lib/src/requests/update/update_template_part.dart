import '../../../wordpress_client.dart';

/// Update a Template Part (POST /wp/v2/template-parts/<id>)
final class UpdateTemplatePartRequest extends IRequest {
  UpdateTemplatePartRequest({
    required this.id,
    this.slug,
    this.theme,
    this.type,
    this.content,
    this.title,
    this.description,
    this.status,
    this.author,
    this.area,
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

  /// Template part ID.
  final String id;

  /// Unique slug identifying the template part.
  final String? slug;

  /// Theme identifier for the template part.
  final String? theme;

  /// Type of template part.
  final String? type;

  /// Content of template part (string or HTML/serialized blocks).
  final String? content;

  /// Title of template part.
  final String? title;

  /// Description of template part.
  final String? description;

  /// Status of template part.
  final ContentStatus? status;

  /// Author user ID for template part.
  final int? author;

  /// Template part area (for example: header, footer).
  final String? area;

  @override
  WordpressRequest build(Uri baseUrl) {
    final payload = <String, dynamic>{
      if (slug != null) 'slug': slug,
      if (theme != null) 'theme': theme,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status!.name,
      if (author != null) 'author': author,
      if (area != null) 'area': area,
    }..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('template-parts/$id'),
      body: payload,
      queryParameters: queryParameters,
      headers: headers,
      requireAuth: true,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
