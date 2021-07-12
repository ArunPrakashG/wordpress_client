import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../../enums.dart';
import '../../exceptions/file_not_exist_exception.dart';
import '../../exceptions/null_reference_exception.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import 'query_builder.dart';
import 'request_builder_base.dart';

class MediaBuilder extends QueryBuilder<MediaBuilder> implements IRequestBuilder<MediaBuilder, Map<String, dynamic>> {
  MultipartFile _multipartFile;
  String _altText;
  String _caption;
  String _description;
  ContentStatus _mediaStatus;
  int _associatedPostId;
  String _title;
  int _authorId;
  Status _commandStatus;
  Status _pingStatus;
  List<Pair<String, String>> _contentHeaders;

  MediaBuilder();

  MediaBuilder withAltText(String altText) {
    _altText = altText;
    return this;
  }

  MediaBuilder withCaption(String caption) {
    _caption = caption;
    return this;
  }

  MediaBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  MediaBuilder withAssociatedPostId(int postId) {
    _associatedPostId = postId;
    return this;
  }

  MediaBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  MediaBuilder withAuthor(int id) {
    _authorId = id;
    return this;
  }

  MediaBuilder withCommandStatus(Status commandStatus) {
    _commandStatus = commandStatus;
    return this;
  }

  MediaBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus;
    return this;
  }

  MediaBuilder withMediaStatus(ContentStatus status) {
    _mediaStatus = status;
    return this;
  }

  MediaBuilder withFile(String filePath) {
    if (isNullOrEmpty(filePath)) {
      throw ArgumentError('File path can not be empty.');
    }

    File file = File(filePath);

    if (!file.existsSync()) {
      throw FileDoesntExistException('The specified file does not exist.');
    }

    final fileName = basename(file.path);
    final mediaType = getMIMETypeFromExtension(fileName);

    _multipartFile = MultipartFile.fromBytes(
      file.readAsBytesSync(),
      filename: fileName,
      contentType: MediaType.parse(mediaType),
    );

    _contentHeaders ??= [];
    _contentHeaders.add(Pair('Content-Type', 'mediaType'));
    _contentHeaders.add(Pair('Content-Disposition', 'attachment; filename=$fileName'));
    return this;
  }

  @override
  Map<String, dynamic> build() {
    if (_multipartFile == null) {
      throw NullReferenceException('File cannot be empty or null in a Media Request');
    }

    return {
      'REQUEST_TYPE': 'media_request',
      if (!isNullOrEmpty(_altText)) 'alt_text': _altText,
      if (!isNullOrEmpty(_title)) 'title': _title,
      if (!isNullOrEmpty(_caption)) 'caption': _caption,
      if (!isNullOrEmpty(_description)) 'description': _description,
      if (_associatedPostId >= 0) 'post': _associatedPostId,
      if (_authorId >= 0) 'author': _authorId,
      'comment_status': _commandStatus.toString().split('.').last,
      'ping_status': _pingStatus.toString().split('.').last,
      'status': _mediaStatus.toString().split('.').last,
      if (_contentHeaders.isNotEmpty && _contentHeaders.elementAt(0) != null) 'Content-Type': _contentHeaders.elementAt(0).b,
      if (_contentHeaders.isNotEmpty && _contentHeaders.elementAt(1) != null)
        'Content-Disposition': 'attachment; filename=${_contentHeaders.elementAt(1).b}',
      'file': _multipartFile,
    };
  }

  @override
  MediaBuilder initializeWithDefaultValues() {
    _associatedPostId = -1;
    _commandStatus = Status.OPEN;
    _pingStatus = Status.OPEN;
    _authorId = -1;
    _mediaStatus = ContentStatus.PENDING;
    return this;
  }
}
