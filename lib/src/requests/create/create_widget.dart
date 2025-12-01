import '../../../wordpress_client.dart';

/// Create a Widget: POST /wp/v2/widgets
final class CreateWidgetRequest extends IRequest {
  CreateWidgetRequest({
    this.id,
    this.idBase,
    this.sidebar,
    this.instance,
    this.formData,
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

  /// Optional ID of an existing widget to clone.
  final String? id;

  /// The base identifier for the widget type (e.g., 'text').
  final String? idBase;

  /// The sidebar the widget belongs to.
  /// Defaults to 'wp_inactive_widgets' on the server when omitted.
  final String? sidebar; // default wp_inactive_widgets
  /// Widget instance settings as a JSON object.
  final Map<String, dynamic>? instance;

  /// URL-encoded form data, if using a form-based update flow.
  final String? formData; // url-encoded form data

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('id', id)
      ..addIfNotNull('id_base', idBase)
      ..addIfNotNull('sidebar', sidebar)
      ..addIfNotNull('instance', instance)
      ..addIfNotNull('form_data', formData)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      method: HttpMethod.post,
      url: RequestUrl.relative('widgets'),
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
