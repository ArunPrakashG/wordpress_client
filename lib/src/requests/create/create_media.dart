// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart';

import '../../enums.dart' show Status, HttpMethod;
import '../../exceptions/file_not_exist_exception.dart';
import '../../utilities/extensions/map_extensions.dart';
import '../../utilities/helpers.dart';
import '../../utilities/request_url.dart';
import '../request_interface.dart';
import '../wordpress_request.dart';

final class CreateMediaRequest extends IRequest {
  CreateMediaRequest({
    required this.mediaFilePath,
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
  });

  String mediaFilePath;
  String? altText;
  String? caption;
  String? description;
  String? mediaStatus;
  int? post;
  String? title;
  int? authorId;
  Status? commentStatus;
  Status? pingStatus;

  @override
  Future<WordpressRequest> build(Uri baseUrl) async {
    final file = File(mediaFilePath);

    if (!await file.exists()) {
      throw FileDoesntExistException(
        'The file at path "$mediaFilePath" doesn\'t exist.',
      );
    }

    final fileName = basename(file.path);
    final mediaType = getMIMETypeFromExtension(
      extension(fileName).replaceFirst('.', ''),
    );

    final multipartFile = MultipartFile.fromBytes(
      await file.readAsBytes(),
      filename: fileName,
      contentType: MediaType.parse(mediaType),
    );

    final mimeType = multipartFile.contentType!.mimeType;

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
      ..addIfNotNull('file', multipartFile);

    final headers = <String, dynamic>{}
      ..addIfNotNull(
        'Content-Disposition',
        'attachment; filename="${multipartFile.filename}"',
      )
      ..addIfNotNull('Content-Type', mimeType);

    return WordpressRequest(
      body: FormData.fromMap(body),
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
