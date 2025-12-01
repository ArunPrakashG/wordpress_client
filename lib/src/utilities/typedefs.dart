typedef ValidatorCallback = bool Function(dynamic response);
typedef JsonEncoderCallback = Map<String, dynamic> Function(dynamic instance);
typedef JsonDecoderCallback<T> = T Function(dynamic json);
typedef StatisticsCallback = void Function(
  String requestUrl,
  int requestCount,
);
