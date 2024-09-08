// ignore_for_file: avoid_slow_async_io

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart';

import '../../../wordpress_client.dart';
import '../../constants.dart';

/// A request class for creating media in WordPress.
///
/// This class provides functionality to create media items in WordPress,
/// supporting both file-based and byte-based media uploads.
final class CreateMediaRequest extends IRequest {
  /// Private constructor for CreateMediaRequest.
  ///
  /// This constructor is used internally by the factory methods.
  CreateMediaRequest._({
    required this.mediaFile,
    required this.fileName,
    this.altText,
    this.caption,
    this.description,
    this.mediaStatus,
    this.post,
    this.title,
    this.authorId,
    this.commentStatus,
    this.pingStatus,
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
    String? altText,
    String? caption,
    String? description,
    String? mediaStatus,
    int? post,
    String? title,
    int? authorId,
    Status? commentStatus,
    Status? pingStatus,
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
      altText: altText,
      caption: caption,
      description: description,
      mediaStatus: mediaStatus,
      post: post,
      title: title,
      authorId: authorId,
      commentStatus: commentStatus,
      pingStatus: pingStatus,
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
    String? altText,
    String? caption,
    String? description,
    String? mediaStatus,
    int? post,
    String? title,
    int? authorId,
    Status? commentStatus,
    Status? pingStatus,
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
      altText: altText,
      caption: caption,
      description: description,
      mediaStatus: mediaStatus,
      post: post,
      title: title,
      authorId: authorId,
      commentStatus: commentStatus,
      pingStatus: pingStatus,
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

  /// Builds the WordPress request for creating media.
  ///
  /// This method prepares the request by creating a MultipartFile from the media,
  /// setting up the necessary headers and body, and returning a WordpressRequest object.
  @override
  Future<WordpressRequest> build(Uri baseUrl) async {
    late MultipartFile multipartFile;
    late String mimeType;

    switch (mediaFile) {
      case final File file:
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
        break;
      case final Uint8List bytes:
        final mediaType = getMIMETypeFromExtension(
          extension(fileName).replaceFirst('.', ''),
        );
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        );
        mimeType = mediaType;
        break;
      default:
        throw ArgumentError(
          'Invalid mediaFile type. Expected File or Uint8List.',
        );
    }

    final body = <String, dynamic>{}
      ..addIfNotNull('alt_text', altText)
      ..addIfNotNull('caption', caption)
      ..addIfNotNull('description', description)
      ..addIfNotNull('status', mediaStatus)
      ..addIfNotNull('post', post)
      ..addIfNotNull('title', title)
      ..addIfNotNull('author_id', authorId)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('file', multipartFile)
      ..addAllIfNotNull(extra);

    final headers = <String, dynamic>{}
      ..addIfNotNull(
        'Content-Disposition',
        'attachment; filename="$fileName"',
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
