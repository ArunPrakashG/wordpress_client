import '../../../wordpress_client.dart';

/// Update Global Styles (POST /wp/v2/global-styles/<id>)
final class UpdateGlobalStylesRequest extends IRequest {
  UpdateGlobalStylesRequest({
    required this.id,
    this.styles,
    this.settings,
    this.title,
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

  /// Global Styles ID (theme or variation).
  final String id;

  /// Global styles object to update.
  final Map<String, dynamic>? styles;

  /// Global settings object to update.
  final Map<String, dynamic>? settings;

  /// Title for the global styles variation.
  final String? title;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{
      if (styles != null) 'styles': styles,
      if (settings != null) 'settings': settings,
      if (title != null) 'title': title,
    }..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('global-styles/$id'),
      body: body,
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
