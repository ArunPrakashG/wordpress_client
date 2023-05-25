typedef JsonEncoderCallback = Map<String, dynamic> Function(dynamic instance);
typedef JsonDecoderCallback<T> = T Function(Map<String, dynamic> json);
typedef StatisticsCallback = void Function(
  String baseUrl,
  String endpoint,
  int requestCount,
);
