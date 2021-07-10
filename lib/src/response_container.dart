class ResponseContainer<T> {
  final T value;
  final int responseCode;
  final bool status;
  final List<Pair<String, String>> responseHeaders;
  final Duration duration;
  final Exception exception;
  final String errorMessage;

  ResponseContainer(this.value, {this.responseCode, this.status = false, this.responseHeaders, this.duration, this.exception, this.errorMessage});

  ResponseContainer.success(this.value, {this.responseCode = 200, this.status = true, this.responseHeaders, this.duration, this.exception, this.errorMessage = ''});

  ResponseContainer.failed(this.value, {this.responseCode, this.status, this.responseHeaders, this.duration, this.exception, this.errorMessage});
}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}
