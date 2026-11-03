/// Stand-in for `dart:io`'s `File` on platforms without file system access.
///
/// Use `CreateMediaRequest.fromBytes` there instead.
abstract interface class File {
  /// The path of the file.
  String get path;

  /// Whether the file exists.
  Future<bool> exists();
}
