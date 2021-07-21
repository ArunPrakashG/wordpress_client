import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../../authorization.dart';
import '../../enums.dart';
import '../../exceptions/file_not_exist_exception.dart';
import '../../exceptions/null_reference_exception.dart';
import '../../responses/media_response.dart';
import '../../utilities/callback.dart';
import '../../utilities/helpers.dart';
import '../../utilities/pair.dart';
import '../request.dart';
import '../request_builder_base.dart';

class MediaCreateBuilder implements IQueryBuilder<MediaCreateBuilder, Media> {
  @override
  Authorization authorization;

  @override
  Callback callback;

  @override
  CancelToken cancelToken;

  @override
  String endpoint;

  @override
  List<Pair<String, String>> headers;

  @override
  List<Pair<String, String>> queryParameters;

  @override
  bool Function(Media) responseValidationDelegate;

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

  MediaCreateBuilder withAltText(String altText) {
    _altText = altText;
    return this;
  }

  MediaCreateBuilder withCaption(String caption) {
    _caption = caption;
    return this;
  }

  MediaCreateBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  MediaCreateBuilder withAssociatedPostId(int postId) {
    _associatedPostId = postId;
    return this;
  }

  MediaCreateBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  MediaCreateBuilder withAuthor(int id) {
    _authorId = id;
    return this;
  }

  MediaCreateBuilder withCommandStatus(Status commandStatus) {
    _commandStatus = commandStatus;
    return this;
  }

  MediaCreateBuilder withPingStatus(Status pingStatus) {
    _pingStatus = pingStatus;
    return this;
  }

  MediaCreateBuilder withMediaStatus(ContentStatus status) {
    _mediaStatus = status;
    return this;
  }

  MediaCreateBuilder withFile(String filePath) {
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

    return this;
  }

  @override
  Request<Media> build() {
    return Request<Media>(
      endpoint,
      callback: callback,
      httpMethod: HttpMethod.POST,
      validationDelegate: responseValidationDelegate,
      cancelToken: cancelToken,
      authorization: authorization,
      headers: headers,
      formBody: FormData.fromMap(_parseParameters()),
    );
  }

  Map<String, dynamic> _parseParameters() {
    if (_multipartFile == null) {
      throw NullReferenceException('File cannot be empty or null in a Media Request');
    }

    return {
      if (!isNullOrEmpty(_altText)) 'alt_text': _altText,
      if (!isNullOrEmpty(_title)) 'title': _title,
      if (!isNullOrEmpty(_caption)) 'caption': _caption,
      if (!isNullOrEmpty(_description)) 'description': _description,
      if (_associatedPostId >= 0) 'post': _associatedPostId,
      if (_authorId >= 0) 'author': _authorId,
      'comment_status': _commandStatus.toString().split('.').last,
      'ping_status': _pingStatus.toString().split('.').last,
      'status': _mediaStatus.toString().split('.').last,
      'Content-Type': _multipartFile.contentType.mimeType,
      'Content-Disposition': 'attachment; filename=${_multipartFile.filename}',
      'file': _multipartFile,
    };
  }

  @override
  MediaCreateBuilder initializeWithDefaultValues() {
    _associatedPostId = -1;
    _commandStatus = Status.OPEN;
    _pingStatus = Status.OPEN;
    _authorId = -1;
    _mediaStatus = ContentStatus.PENDING;
    return this;
  }

  @override
  MediaCreateBuilder withAuthorization(Authorization auth) {
    authorization = auth;
    return this;
  }

  @override
  MediaCreateBuilder withCallback(Callback requestCallback) {
    callback = requestCallback;
    return this;
  }

  @override
  MediaCreateBuilder withCancellationToken(CancelToken token) {
    cancelToken = token;
    return this;
  }

  @override
  MediaCreateBuilder withEndpoint(String newEndpoint) {
    endpoint = newEndpoint;
    return this;
  }

  @override
  MediaCreateBuilder withHeaders(Iterable<Pair<String, String>> customHeaders) {
    headers ??= [];
    headers.addAll(customHeaders);
    return this;
  }

  @override
  MediaCreateBuilder withQueryParameters(Iterable<Pair<String, String>> extraQueryParameters) {
    queryParameters ??= [];
    queryParameters.addAll(extraQueryParameters);
    return this;
  }

  @override
  MediaCreateBuilder withResponseValidationOverride(bool Function(Media) responseDelegate) {
    responseValidationDelegate = responseDelegate;
    return this;
  }
}
