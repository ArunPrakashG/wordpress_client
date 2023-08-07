import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../codable_map.dart';

// import 'package:html/parser.dart';

extension MapExtensions on Map<String, dynamic> {
  String toJsonString() {
    return json.encode(this);
  }

  /// Adds the given [value] to the map if the value is not null.
  void addIfNotNull(String key, dynamic value) {
    if (value == null) {
      return;
    }

    this[key] = value?.toString();
  }
}

extension HeaderExtension on Headers {
  /// Gets all the headers as a map.
  Map<String, String> getHeaderMap() {
    return map.map<String, String>((key, value) {
      return MapEntry(key, value.join(';'));
    });
  }
}

DateTime? parseDateIfNotNull(dynamic json) {
  if (json == null) {
    return null;
  }

  if (json is! String) {
    return null;
  }

  final dateString = json;

  if (dateString.isEmpty) {
    return null;
  }

  return DateTime.tryParse(dateString);
}

/// Casts the given dynamic JSON value to the specified type [T].
///
/// Optionally, you can provide a [transformer] function to transform the value manually if it is not null.
///
/// If the value is null, the [orElse] function is called to return a default value.
T? castOrElse<T>(
  dynamic json, {
  T? Function(Object value)? transformer,
  T Function()? orElse,
}) {
  try {
    if (json == null) {
      return orElse?.call();
    }

    if (transformer != null) {
      return transformer(json);
    }

    if (json is! T) {
      return orElse?.call();
    }

    return json;
  } catch (_) {
    return orElse?.call();
  }
}

bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

bool isAlphaNumeric(String value) => RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value);

String base64Encode(String text) {
  if (isNullOrEmpty(text)) {
    return '';
  }

  return base64.encode(utf8.encode(text));
}

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

/// Checks if the provided integer value is in the range of [min] and [max].
bool isInRange(int value, int min, int max) => value >= min && value <= max;

String parseHtmlString(String htmlString) =>
    htmlString.replaceAll(RegExp('<[^>]*>|&[^;]+;'), ' ');

Type typeOf<T>() => T;

/// Deserializes a JSON object by getting its decoder from [CodableMap]
///
/// You will need to initiate your custom interface first in order to deserialize using this method.
T deserialize<T>(dynamic object) {
  final decoder = CodableMap.getDecoder<T>();
  return decoder(object);
}

/// Serializes a Dart object by getting its encoder from [CodableMap]
///
/// You will need to initiate your custom interface first in order to serialize using this method.
Map<String, dynamic> serialize<T>(T object) {
  final encoder = CodableMap.getEncoder<T>();
  return encoder(object);
}

List<T> mapIterableWithChecks<T>(
  dynamic json,
  T Function(dynamic json) decoder,
) {
  if (json == null || json is! Iterable<dynamic>) {
    return [];
  }

  return json.map<T>((dynamic e) => decoder(e)).toList();
}

T? mapToTypeNoSafety<T>(dynamic json, T Function(dynamic json) decoder) {
  if (json == null) {
    return null;
  }

  return decoder(json);
}

T? mapToType<T>(
  dynamic json,
  T Function(Map<String, dynamic> json) decoder,
) {
  if (json == null || json is! Map<String, dynamic>) {
    return null;
  }

  return decoder(json);
}

String getMIMETypeFromExtension(String extension) {
  // list from https://codex.wordpress.org/Function_Reference/get_allowed_mime_types
  switch (extension.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
    case 'jpe':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'png':
      return 'image/png';
    case 'bmp':
      return 'image/bmp';
    case 'tif':
      return 'image/tif';
    case 'ico':
      return 'image/x-icon';

    case 'asf':
    case 'asx':
      return 'video/x-ms-asf';
    case 'wmv':
      return 'video/x-ms-wmv';
    case 'wmx':
      return 'video/x-ms-wmx';
    case 'wm':
      return 'video/x-ms-wm';
    case 'avi':
      return 'video/avi';
    case 'divx':
      return 'video/divx';
    case 'flv':
      return 'video/x-flv';

    case 'mov':
    case 'qt':
      return 'video/quicktime';
    case 'mpeg':
    case 'mpg':
    case 'mpe':
      return 'video/mpeg';
    case 'mp4':
    case 'm4v':
      return 'video/mp4';
    case 'ogv':
      return 'video/ogg';
    case 'webm':
      return 'video/webm';
    case 'mkv':
      return 'video/x-matroska';
    case 'txt':
    case 'asc':
    case 'c':
    case 'cc':
    case 'h':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'tsv':
      return 'text/tab-separated-values';
    case 'ics':
      return 'text/calendar';
    case 'rtx':
      return 'text/richtext';
    case 'css':
      return 'text/css';
    case 'html':
    case 'htm':
      return 'text/html';
    case 'mp3':
    case 'm4a':
    case 'm4b':
      return 'audio/mpeg';
    case 'ra':
    case 'ram':
      return 'audio/x-realaudio';
    case 'wav':
      return 'audio/wav';
    case 'ogg':
    case 'oga':
      return 'audio/ogg';
    case 'mid':
    case 'midi':
      return 'audio/midi';
    case 'wma':
      return 'audio/x-ms-wma';
    case 'wax':
      return 'audio/x-ms-wax';
    case 'mka':
      return 'audio/x-matroska';
    case 'rtf':
      return 'application/rtf';
    case 'js':
      return 'application/javascript';
    case 'pdf':
      return 'application/pdf';
    case 'swf':
      return 'application/x-shockwave-flash';
    case 'class':
      return 'application/java';
    case 'tar':
      return 'application/x-tar';
    case 'zip':
      return 'application/zip';
    case 'gz':
    case 'gzip':
      return 'application/x-gzip';
    case 'rar':
      return 'application/rar';
    case '7z':
      return 'application/x-7z-compressed';
    case 'exe':
      return 'application/x-msdownload';
    case 'doc':
      return 'application/msword';
    case 'pot':
    case 'pps':
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'wri':
      return 'application/vnd.ms-write';
    case 'xla':
    case 'xls':
    case 'xlt':
    case 'xlw':
      return 'application/vnd.ms-excel';
    case 'mdb':
      return 'application/vnd.ms-access';
    case 'mpp':
      return 'application/vnd.ms-project';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'docm':
      return 'application/vnd.ms-word.document.macroEnabled.12';
    case 'dotx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.template';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'xmlsm':
      return 'application/vnd.ms-excel.sheet.macroEnabled.12';
    case 'xlsb':
      return 'application/vnd.ms-excel.sheet.binary.macroEnabled.12';
    case 'xltx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.template';
    case 'xltm':
      return 'application/vnd.ms-excel.template.macroEnabled.12';
    case 'xlam':
      return 'application/vnd.ms-excel.addin.macroEnabled.12';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'pptm':
      return 'application/vnd.ms-powerpoint.presentation.macroEnabled.12';
    case 'ppsx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.slideshow';
    case 'ppsm':
      return 'application/vnd.ms-powerpoint.slideshow.macroEnabled.12';
    case 'potx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.template';
    case 'potm':
      return 'application/vnd.ms-powerpoint.template.macroEnabled.12';
    case 'ppam':
      return 'application/vnd.ms-powerpoint.addin.macroEnabled.12';
    case 'sldx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.slide';
    case 'sldm':
      return 'application/vnd.ms-powerpoint.slide.macroEnabled.12';

    case 'onetoc':
    case 'onetoc2':
    case 'onetmp':
    case 'onepkg':
      return 'application/onenote';
    case 'odt':
      return 'application/vnd.oasis.opendocument.text';
    case 'odp':
      return 'application/vnd.oasis.opendocument.presentation';
    case 'ods':
      return 'application/vnd.oasis.opendocument.spreadsheet';
    case 'odg':
      return 'application/vnd.oasis.opendocument.graphics';
    case 'odc':
      return 'application/vnd.oasis.opendocument.chart';
    case 'odb':
      return 'application/vnd.oasis.opendocument.database';
    case 'odf':
      return 'application/vnd.oasis.opendocument.formula';
    case 'wp':
    case 'wpd':
      return 'application/wordperfect';
    case 'key':
      return 'application/vnd.apple.keynote';
    case 'numbers':
      return 'application/vnd.apple.numbers';
    case 'pages':
      return 'application/vnd.apple.pages';
    case 'kmz':
    case 'kml':
      return 'application/octet-stream';
    default:
      return 'text/plain';
  }
}
