class Callback {
  final void Function(Exception) unhandledExceptionCallback;
  final void Function(dynamic) responseCallback;
  final void Function(RequestStatus) requestCallback;

  Callback({this.unhandledExceptionCallback, this.responseCallback, this.requestCallback});
}

class RequestStatus {
  final bool status;
  final String errorMessage;

  RequestStatus(this.status, this.errorMessage);
}
