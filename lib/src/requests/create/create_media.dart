// ignore_for_file: avoid_slow_async_io

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart';

import '../../../wordpress_client.dart';
import '../../constants.dart';

/// Create a Media Item (POST /wp/v2/media).
///
/// Supports file-based and byte-based uploads and optional fields documented in the Handbook.
/// Reference: https://developer.wordpress.org/rest-api/reference/media/#create-a-media-item
final class CreateMediaRequest extends IRequest {
  /// Private constructor for CreateMediaRequest.
  ///
  /// This constructor is used internally by the factory methods.
  CreateMediaRequest._({
    required this.mediaFile,
    required this.fileName,
    this.date,
    this.dateGmt,
    this.slug,
    this.altText,
    this.caption,
    this.description,
    this.mediaStatus,
    this.post,
    this.title,
    this.authorId,
    this.commentStatus,
    this.pingStatus,
    this.meta,
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

  /// Creates a CreateMediaRequest instance from a File.
  ///
  /// Use this factory method when you have a file on the device that you want to upload.
  ///
  /// [file] is the File object representing the media to be uploaded.
  /// Other parameters are optional and correspond to various media attributes and request options.
  factory CreateMediaRequest.fromFile({
    required File file,
    DateTime? date,
    DateTime? dateGmt,
    String? slug,
    String? altText,
    String? caption,
    String? description,
    String? mediaStatus,
    int? post,
    String? title,
    int? authorId,
    Status? commentStatus,
    Status? pingStatus,
    Map<String, dynamic>? meta,
    String? template,
    CancelToken? cancelToken,
    IAuthorization? authorization,
    WordpressEvents? events,
    Duration? receiveTimeout,
    bool? requireAuth,
    Duration? sendTimeout,
    ValidatorCallback? validator,
    Map<String, dynamic>? extra,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    return CreateMediaRequest._(
      mediaFile: file,
      fileName: basename(file.path),
      date: date,
      dateGmt: dateGmt,
      slug: slug,
      altText: altText,
      caption: caption,
      description: description,
      mediaStatus: mediaStatus,
      post: post,
      title: title,
      authorId: authorId,
      commentStatus: commentStatus,
      pingStatus: pingStatus,
      meta: meta,
      template: template,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout ?? DEFAULT_REQUEST_TIMEOUT,
      requireAuth: requireAuth ?? true,
      sendTimeout: sendTimeout ?? DEFAULT_REQUEST_TIMEOUT,
      validator: validator,
      extra: extra,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Creates a CreateMediaRequest instance from bytes.
  ///
  /// Use this factory method when you have the media content as a byte array.
  ///
  /// [bytes] is the Uint8List containing the media data.
  /// [fileName] is the name to be given to the file when uploaded.
  /// Other parameters are optional and correspond to various media attributes and request options.
  factory CreateMediaRequest.fromBytes({
    required Uint8List bytes,
    required String fileName,
    DateTime? date,
    DateTime? dateGmt,
    String? slug,
    String? altText,
    String? caption,
    String? description,
    String? mediaStatus,
    int? post,
    String? title,
    int? authorId,
    Status? commentStatus,
    Status? pingStatus,
    Map<String, dynamic>? meta,
    String? template,
    CancelToken? cancelToken,
    IAuthorization? authorization,
    WordpressEvents? events,
    Duration? receiveTimeout,
    bool? requireAuth,
    Duration? sendTimeout,
    ValidatorCallback? validator,
    Map<String, dynamic>? extra,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    return CreateMediaRequest._(
      mediaFile: bytes,
      fileName: fileName,
      date: date,
      dateGmt: dateGmt,
      slug: slug,
      altText: altText,
      caption: caption,
      description: description,
      mediaStatus: mediaStatus,
      post: post,
      title: title,
      authorId: authorId,
      commentStatus: commentStatus,
      pingStatus: pingStatus,
      meta: meta,
      template: template,
      cancelToken: cancelToken,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout ?? DEFAULT_REQUEST_TIMEOUT,
      requireAuth: requireAuth ?? true,
      sendTimeout: sendTimeout ?? DEFAULT_REQUEST_TIMEOUT,
      validator: validator,
      extra: extra,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// The media file to be uploaded, either as a File or Uint8List.
  final dynamic mediaFile;

  /// The name of the file to be uploaded.
  final String fileName;

  /// The date the item was published, in the site's timezone.
  final DateTime? date;

  /// The date the item was published, as GMT.
  final DateTime? dateGmt;

  /// An alphanumeric identifier unique to its type.
  final String? slug;

  /// Alternative text for the media.
  final String? altText;

  /// Caption for the media.
  final String? caption;

  /// Description of the media.
  final String? description;

  /// Status of the media (e.g., 'publish', 'draft').
  final String? mediaStatus;

  /// ID of the post to which this media is attached.
  final int? post;

  /// Title of the media.
  final String? title;

  /// ID of the author of the media.
  final int? authorId;

  /// Comment status for the media.
  final Status? commentStatus;

  /// Ping status for the media.
  final Status? pingStatus;

  /// Meta fields.
  final Map<String, dynamic>? meta;

  /// The theme file to use to display the attachment.
  final String? template;

  /// Builds the WordPress request for creating media.
  ///
  /// This method prepares the request by creating a MultipartFile from the media,
  /// setting up the necessary headers and body, and returning a WordpressRequest object.
  @override
  Future<WordpressRequest> build(Uri baseUrl) async {
    MultipartFile? multipartFile;
    String? mimeType;

    if (mediaFile is File) {
      final file = mediaFile as File;
      if (!await file.exists()) {
        throw FileDoesntExistException(
          'The file at path "${file.path}" doesn\'t exist.',
        );
      }

      final mediaType = getMIMETypeFromExtension(
        extension(fileName).replaceFirst('.', ''),
      );

      multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: DioMediaType.parse(mediaType),
      );
      mimeType = mediaType;
    } else if (mediaFile is Uint8List) {
      final bytes = mediaFile as Uint8List;

      if (!fileName.contains('.')) {
        throw ArgumentError(
          'The file name must contain a file extension.',
        );
      }

      final mediaType = getMIMETypeFromExtension(
        extension(fileName).replaceFirst('.', ''),
      );
      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: DioMediaType.parse(mediaType),
      );
      mimeType = mediaType;
    } else {
      throw ArgumentError(
        'Invalid content type for the file. Please use the `fromBytes` factory method to upload files with custom content types.',
      );
    }

    final body = <String, dynamic>{}
      ..addIfNotNull('date', date?.toIso8601String())
      ..addIfNotNull('date_gmt', dateGmt?.toIso8601String())
      ..addIfNotNull('slug', slug)
      ..addIfNotNull('alt_text', altText)
      ..addIfNotNull('caption', caption)
      ..addIfNotNull('description', description)
      ..addIfNotNull('status', mediaStatus)
      ..addIfNotNull('post', post)
      ..addIfNotNull('title', title)
      ..addIfNotNull('author_id', authorId)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('meta', meta)
      ..addIfNotNull('template', template)
      ..addIfNotNull('file', multipartFile)
      ..addAllIfNotNull(extra);

    final headers = <String, dynamic>{}
      ..addIfNotNull(
        'Content-Disposition',
        'attachment; filename="${multipartFile.filename}"',
      )
      ..addIfNotNull('Content-Type', mimeType)
      ..addAllIfNotNull(this.headers);

    return WordpressRequest(
      body: FormData.fromMap(body),
      queryParameters: queryParameters,
      method: HttpMethod.post,
      url: RequestUrl.relative('media'),
      requireAuth: requireAuth,
      cancelToken: cancelToken,
      headers: headers,
      authorization: authorization,
      events: events,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      validator: validator,
    );
  }
}
