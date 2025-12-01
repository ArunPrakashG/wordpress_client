import '../../responses/wordpress_response.dart';

/// Convenience helpers to extract data or throw on failure.
extension ResponseDataExtensions<T> on WordpressResponse<T> {
  /// Returns data when success or throws a StateError with error info.
  T dataOrThrow() {
    if (this is WordpressSuccessResponse<T>) {
      return (this as WordpressSuccessResponse<T>).data;
    }
    final f = this as WordpressFailureResponse;
    final status = f.error?.status;
    final code = f.error?.code;
    final msg = f.error?.message;
    throw StateError(
      'Request failed${status != null ? ' ($status)' : ''}${code != null ? ' [$code]' : ''}${msg != null ? ': $msg' : ''}',
    );
  }
}
