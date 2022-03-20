import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart';

import '../../enums.dart' show Status, HttpMethod;
import '../../exceptions/file_not_exist_exception.dart';
import '../../utilities/helpers.dart';
import '../request_content.dart';
import '../request_interface.dart';

class CreateMediaRequest implements IRequest {
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
  void build(RequestContent requestContent) {
    final file = File(mediaFilePath);

    if (!file.existsSync()) {
      throw FileDoesntExistException(
        'The file at path "$mediaFilePath" doesn\'t exist.',
      );
    }

    final fileName = basename(file.path);
    final mediaType = getMIMETypeFromExtension(fileName);
    final multipartFile = MultipartFile.fromBytes(
      file.readAsBytesSync(),
      filename: fileName,
      contentType: MediaType.parse(mediaType),
    );

    requestContent.body
      ..addIfNotNull('alt_text', altText)
      ..addIfNotNull('caption', caption)
      ..addIfNotNull('description', description)
      ..addIfNotNull('status', mediaStatus)
      ..addIfNotNull('post', post)
      ..addIfNotNull('title', title)
      ..addIfNotNull('author_id', authorId)
      ..addIfNotNull('comment_status', commentStatus?.name)
      ..addIfNotNull('ping_status', pingStatus?.name)
      ..addIfNotNull('Content-Type', multipartFile.contentType!.mimeType)
      ..addIfNotNull('Content-Disposition',
          'attachment; filename=${multipartFile.filename}')
      ..addIfNotNull('file', multipartFile);

    requestContent.endpoint = 'media';
    requestContent.method = HttpMethod.post;
  }
}
