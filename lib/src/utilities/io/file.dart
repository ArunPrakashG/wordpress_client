// The `File` type used by `CreateMediaRequest.fromFile`.
//
// On platforms with `dart:io` this is `dart:io`'s `File`. Elsewhere (web,
// wasm) it is a stand-in that cannot be created, so the library itself never
// imports `dart:io` and stays wasm compatible.
export 'file_stub.dart' if (dart.library.io) 'file_io.dart';
