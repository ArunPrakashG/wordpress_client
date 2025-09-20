import '../../../wordpress_client.dart';

/// Update a Template (POST /wp/v2/templates/<id>)
final class UpdateTemplateRequest extends IRequest {
  UpdateTemplateRequest({
    required this.id,
    this.slug,
    this.theme,
    this.type,
    this.content,
    this.title,
    this.description,
    this.status,
    this.author,
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

  /// The template identifier used in the REST path.
  final String id;

  /// Unique slug identifying the template.
  final String? slug;

  /// Theme identifier for the template.
  final String? theme;

  /// Type of template.
  final String? type;

  /// Content of template (string or HTML/serialized blocks).
  final String? content;

  /// Title of template.
  final String? title;

  /// Description of template.
  final String? description;

  /// Status of template.
  final ContentStatus? status;

  /// The ID for the author of the template.
  final int? author;

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
    }..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('templates/$id'),
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
