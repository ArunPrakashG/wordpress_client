import '../../../wordpress_client.dart';

final class UpdateSettingsRequest extends IRequest {
  UpdateSettingsRequest({
    this.title,
    this.description,
    this.url,
    this.email,
    this.timezone,
    this.dateFormat,
    this.timeFormat,
    this.startOfWeek,
    this.language,
    this.useSmilies,
    this.defaultCategory,
    this.defaultPostFormat,
    this.postsPerPage,
    this.showOnFront,
    this.pageOnFront,
    this.pageForPosts,
    this.defaultPingStatus,
    this.defaultCommentStatus,
    this.siteLogo,
    this.siteIcon,
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

  /// Site title.
  String? title;

  /// Site tagline.
  String? description;

  /// Site URL.
  String? url;

  /// This address is used for admin purposes, like new user notification.
  String? email;

  /// A city in the same timezone as you.
  String? timezone;

  /// A date format for all date strings.
  String? dateFormat;

  /// A time format for all time strings.
  String? timeFormat;

  /// A day number of the week that the week should start on.
  int? startOfWeek;

  /// WordPress locale code.
  String? language;

  /// Convert emoticons like :-) and :-P to graphics on display.
  bool? useSmilies;

  /// Default post category.
  int? defaultCategory;

  /// Default post format.
  String? defaultPostFormat;

  /// Blog pages show at most.
  int? postsPerPage;

  /// What to show on the front page.
  String? showOnFront;

  /// ID of the page that should be displayed on the front page.
  int? pageOnFront;

  /// ID of the page that should display posts.
  int? pageForPosts;

  /// Whether to allow link notifications from other blogs (open|closed).
  String? defaultPingStatus; // open|closed
  /// Whether to allow comments (open|closed).
  String? defaultCommentStatus; // open|closed
  /// Site logo media ID.
  int? siteLogo;

  /// Site icon media ID.
  int? siteIcon;

  @override
  WordpressRequest build(Uri baseUrl) {
    final body = <String, dynamic>{}
      ..addIfNotNull('title', title)
      ..addIfNotNull('description', description)
      ..addIfNotNull('url', url)
      ..addIfNotNull('email', email)
      ..addIfNotNull('timezone', timezone)
      ..addIfNotNull('date_format', dateFormat)
      ..addIfNotNull('time_format', timeFormat)
      ..addIfNotNull('start_of_week', startOfWeek)
      ..addIfNotNull('language', language)
      ..addIfNotNull('use_smilies', useSmilies)
      ..addIfNotNull('default_category', defaultCategory)
      ..addIfNotNull('default_post_format', defaultPostFormat)
      ..addIfNotNull('posts_per_page', postsPerPage)
      ..addIfNotNull('show_on_front', showOnFront)
      ..addIfNotNull('page_on_front', pageOnFront)
      ..addIfNotNull('page_for_posts', pageForPosts)
      ..addIfNotNull('default_ping_status', defaultPingStatus)
      ..addIfNotNull('default_comment_status', defaultCommentStatus)
      ..addIfNotNull('site_logo', siteLogo)
      ..addIfNotNull('site_icon', siteIcon)
      ..addAllIfNotNull(extra);

    return WordpressRequest(
      body: body,
      headers: headers,
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('settings'),
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
