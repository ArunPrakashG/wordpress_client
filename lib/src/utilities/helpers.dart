import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../library_exports.dart';
import 'codable_map/codable_map.dart';

/// Parses a date from a JSON object with error handling.
///
/// Returns null if the input is null, not a string, or an empty string.
/// Otherwise, attempts to parse the string as a DateTime.
///
/// [json] The JSON object to parse, expected to be a string representation of a date.
DateTime? parseDateIfNotNull(dynamic json) {
  if (json == null || json is! String || json.isEmpty) {
    return null;
  }

  return DateTime.tryParse(json);
}

/// Maps a JSON object to a Dart object with error handling.
///
/// [mapper] A function that converts a Map<String, dynamic> to type T.
/// [json] The JSON object to map.
///
/// Returns null if the input is null or not a Map<String, dynamic>.
/// If an error occurs during mapping, returns null instead of throwing an exception.
T? mapGuarded<T>({
  required T Function(Map<String, dynamic> json) mapper,
  required dynamic json,
}) {
  if (json == null || json is! Map<String, dynamic>) {
    return null;
  }

  try {
    return mapper(json);
  } catch (_) {
    return null;
  }
}

/// Executes an asynchronous function and handles any errors.
///
/// [function] The asynchronous function to execute.
/// [onError] A callback function to handle any errors that occur.
///
/// Returns the result of [function] if successful, or the result of [onError] if an error occurs.
Future<T> guardAsync<T>({
  required Future<T> Function() function,
  required Future<T> Function(Object error, StackTrace stackTrace) onError,
}) async {
  try {
    return await function();
  } catch (error, stackTrace) {
    return onError(error, stackTrace);
  }
}

/// Executes a synchronous function and handles any errors.
///
/// [function] The function to execute.
/// [onError] A callback function to handle any errors that occur.
///
/// Returns the result of [function] if successful, or the result of [onError] if an error occurs.
T guard<T>({
  required T Function() function,
  required T Function(Object error, StackTrace stackTrace) onError,
}) {
  try {
    return function();
  } catch (error, stackTrace) {
    return onError(error, stackTrace);
  }
}

/// Decodes a value from a map using multiple possible keys.
///
/// [map] The map to search in.
/// [keys] A list of keys to try.
/// [transformer] An optional function to transform the found value.
/// [orElse] An optional function to provide a default value if no key is found.
///
/// Returns the value associated with the first matching key, optionally transformed.
/// If no key is found and [orElse] is provided, returns the result of [orElse].
T? decodeByMultiKeys<T>(
  Map<String, dynamic> map,
  List<String> keys, {
  T? Function(Object value)? transformer,
  T Function()? orElse,
}) {
  for (final key in keys) {
    if (map.containsKey(key)) {
      final value = map[key];
      return transformer != null ? transformer(value) : value as T?;
    }
  }
  return orElse?.call();
}

/// Executes a function with a disposable object and ensures it's disposed afterwards.
///
/// [disposable] The disposable object to use.
/// [delegate] The function to execute with the disposable object.
///
/// Returns the result of [delegate] and ensures [disposable] is disposed, even if an error occurs.
FutureOr<T> using<T, E extends IDisposable>(
  E disposable,
  FutureOr<T> Function(E instance) delegate,
) async {
  try {
    return await delegate(disposable);
  } finally {
    disposable.dispose();
  }
}

/// Casts a dynamic JSON value to a specified type with optional transformation.
///
/// [json] The JSON value to cast.
/// [transformer] An optional function to transform the value if it's not null.
/// [orElse] An optional function to provide a default value if casting fails.
///
/// Returns the cast (and optionally transformed) value, or the result of [orElse] if casting fails.
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

    return json is T ? json : orElse?.call();
  } catch (_) {
    return orElse?.call();
  }
}

/// Checks if a given URI is a valid WordPress REST API URL.
///
/// [uri] The URI to check.
/// [forceHttps] If true, only considers HTTPS URLs as valid.
///
/// Returns true if the URI is a valid WordPress REST API URL, false otherwise.
bool isValidRestApiUrl(Uri uri, {bool forceHttps = false}) {
  if (forceHttps && uri.scheme != 'https') {
    return false;
  }

  return uri.pathSegments.isNotEmpty && uri.pathSegments.contains('wp-json');
}

/// Checks if a given integer is a valid port number.
///
/// [port] The port number to check.
///
/// Returns true if the port is between 0 and 65535, false otherwise.
bool isValidPortNumber(int port) => port >= 0 && port <= 65535;

/// Checks if a string is null or empty.
///
/// [value] The string to check.
///
/// Returns true if the string is null or empty, false otherwise.
bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

/// Checks if a string contains only alphanumeric characters.
///
/// [value] The string to check.
///
/// Returns true if the string contains only alphanumeric characters, false otherwise.
bool isAlphaNumeric(String value) => RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value);

/// Encodes a string to Base64.
///
/// [text] The string to encode.
///
/// Returns the Base64 encoded string, or an empty string if the input is null or empty.
String base64Encode(String text) {
  if (isNullOrEmpty(text)) {
    return '';
  }

  return base64.encode(utf8.encode(text));
}

/// Generates a random string of specified length.
///
/// [len] The length of the random string to generate.
///
/// Returns a Base64 URL-encoded random string of the specified length.
String getRandString(int len) {
  final random = Random.secure();
  final values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

/// Checks if an integer value is within a specified range.
///
/// [value] The integer to check.
/// [min] The minimum value of the range (inclusive).
/// [max] The maximum value of the range (inclusive).
///
/// Returns true if the value is within the range, false otherwise.
bool isInRange(int value, int min, int max) => value >= min && value <= max;

/// Removes HTML tags and entities from a string.
///
/// [htmlString] The HTML string to parse.
///
/// Returns the string with all HTML tags and entities removed.
String parseHtmlString(String htmlString) =>
    htmlString.replaceAll(RegExp('<[^>]*>|&[^;]+;'), ' ');

/// Gets the Type of a generic type parameter.
///
/// Returns the Type of T.
Type typeOf<T>() => T;

/// Deserializes a JSON object to a specified type using CodableMap.
///
/// [object] The JSON object to deserialize.
///
/// Returns the deserialized object of type T.
T deserialize<T>(dynamic object) {
  final decoder = CodableMap.getDecoder<T>();
  return decoder(object);
}

/// Serializes a Dart object to a JSON map using CodableMap.
///
/// [object] The object to serialize.
///
/// Returns the serialized object as a Map<String, dynamic>.
Map<String, dynamic> serialize<T>(T object) {
  final encoder = CodableMap.getEncoder<T>();
  return encoder(object);
}

/// Maps an iterable JSON object to a List of specified type with error checking.
///
/// [json] The JSON object to map.
/// [decoder] A function to decode each element of the iterable.
///
/// Returns a List of type T, or an empty list if the input is invalid.
List<T> mapIterableWithChecks<T>(
  dynamic json,
  T Function(dynamic json) decoder,
) {
  if (json == null || json is! Iterable<dynamic>) {
    return [];
  }

  return json.map<T>((dynamic e) => decoder(e)).toList();
}

/// Maps a JSON object to a specified type without type safety checks.
///
/// [json] The JSON object to map.
/// [decoder] A function to decode the JSON object.
///
/// Returns the decoded object of type T, or null if the input is null.
T? mapToTypeNoSafety<T>(dynamic json, T Function(dynamic json) decoder) {
  if (json == null) {
    return null;
  }

  return decoder(json);
}

/// Maps a JSON object to a specified type with type safety checks.
///
/// [json] The JSON object to map.
/// [decoder] A function to decode the JSON object.
///
/// Returns the decoded object of type T, or null if the input is invalid.
T? mapToType<T>(
  dynamic json,
  T Function(Map<String, dynamic> json) decoder,
) {
  if (json == null || json is! Map<String, dynamic>) {
    return null;
  }

  return decoder(json);
}

/// Returns the MIME type for a given file extension.
///
/// [extension] The file extension to get the MIME type for.
///
/// Returns the corresponding MIME type as a string, or 'text/plain' if unknown.
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
