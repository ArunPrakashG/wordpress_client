class Callback {
  final Function(Exception) unhandledExceptionCallback;
  final Function(String) responseCallback;
  final Function(RequestStatus) requestCallback;

  Callback({this.unhandledExceptionCallback, this.responseCallback, this.requestCallback});
}

class RequestStatus {
  final bool status;
  final String errorMessage;

  RequestStatus(this.status, this.errorMessage);
}
