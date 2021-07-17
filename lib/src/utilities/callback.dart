import 'package:wordpress_client/src/responses/error_response.dart';

class Callback {
  final void Function(Exception) unhandledExceptionCallback;
  final void Function(dynamic) responseCallback;
  final void Function(RequestStatus) requestCallback;
  final void Function(int, int) progressCallback;

  Callback({
    this.unhandledExceptionCallback,
    this.responseCallback,
    this.requestCallback,
    this.progressCallback,
  });
}

class RequestStatus {
  final bool status;
  final String errorMessage;

  RequestStatus(this.status, this.errorMessage);
}
